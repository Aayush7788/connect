import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/work_card_models.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:connect_app/src/features/work_cards/work_card_controller.dart';
import 'package:connect_app/src/features/work_cards/work_card_form_screen.dart';
import 'package:connect_app/src/features/work_cards/work_card_owner_list.dart';
import 'package:connect_app/src/features/work_cards/work_card_repository.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('work card response preserves searchable fields and photos', () {
    final card = WorkCardResult.fromJson({
      'id': 'work-1',
      'profile_id': 'profile-1',
      'status': 'published',
      'title': 'Flat hemming',
      'category_id': 'category-1',
      'category_name': 'Stitching',
      'work_name_id': 'work-name-1',
      'work_name': 'Flat hemming',
      'product_type_ids': ['product-1'],
      'custom_product_texts': <String>[],
      'product_types': ['Dupatta'],
      'description': 'Clean flat hemming for dupattas',
      'photo_count': 1,
      'photos': [
        {
          'id': 'media-1',
          'media_kind': 'image',
          'visibility': 'public',
          'upload_status': 'ready',
          'sort_order': 0,
          'url': 'https://media.test/work.jpg',
        },
      ],
      'created_at': '2026-07-13T08:00:00Z',
      'updated_at': '2026-07-13T09:00:00Z',
    });

    expect(card.displayWorkName, 'Flat hemming');
    expect(card.displayCategory, 'Stitching');
    expect(card.productTypes, ['Dupatta']);
    expect(card.photos.single.id, 'media-1');
  });

  test(
    'controller loads, publishes, hides, shows and deletes owner work',
    () async {
      final repository = _FakeWorkCardRepository()
        ..cards.add(_card(id: 'work-1'));
      final container = ProviderContainer(
        overrides: [
          workCardRepositoryProvider.overrideWithValue(repository),
          workCardProfileRefreshProvider.overrideWithValue(() async {}),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(workCardControllerProvider.notifier);
      await controller.load();
      expect(container.read(workCardControllerProvider).cards, hasLength(1));

      expect(
        await controller.saveAndPublish(
          id: 'work-1',
          fields: const WorkCardUpsert(
            categoryId: 'category-1',
            workNameId: 'work-name-1',
            productTypeIds: ['product-1'],
            customProductTexts: [],
            description: 'Clean finish',
          ),
          publish: true,
        ),
        isTrue,
      );
      var card = controller.find('work-1')!;
      expect(card.status, 'published');

      expect(await controller.setHidden(card, true), isTrue);
      card = controller.find('work-1')!;
      expect(card.status, 'hidden_by_user');

      expect(await controller.setHidden(card, false), isTrue);
      card = controller.find('work-1')!;
      expect(card.status, 'published');

      expect(await controller.delete(card), isTrue);
      expect(container.read(workCardControllerProvider).cards, isEmpty);
    },
  );

  testWidgets('empty owner work list shows the exact first-work prompt', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workCardRepositoryProvider.overrideWithValue(
            _FakeWorkCardRepository(),
          ),
        ],
        child: MaterialApp(
          theme: buildConnectTheme(),
          home: const Scaffold(
            body: SingleChildScrollView(child: WorkCardOwnerList()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Add your first work to appear in search'),
      findsOneWidget,
    );
  });

  testWidgets('add work creates a draft and shows the complete long form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeWorkCardRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workCardRepositoryProvider.overrideWithValue(repository),
          workCardProfileRefreshProvider.overrideWithValue(() async {}),
          mediaPickerProvider.overrideWithValue(_NoopMediaPicker()),
        ],
        child: MaterialApp(
          theme: buildConnectTheme(),
          home: const WorkCardFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.createCount, 1);
    expect(find.text('Add Work'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Work name'), findsOneWidget);
    expect(find.text('Product type'), findsOneWidget);
    expect(find.text('Work photos'), findsOneWidget);
    expect(find.text('Minimum 3 photos required'), findsOneWidget);
    expect(find.text('Save and Publish'), findsOneWidget);

    await tester.tap(find.text('Save and Publish'));
    await tester.pump();
    expect(find.text('Select a category'), findsOneWidget);
    expect(find.text('Select a work name'), findsOneWidget);
    expect(find.text('Select at least one product type'), findsOneWidget);
  });
}

class _FakeWorkCardRepository implements WorkCardRepository {
  final List<WorkCardResult> cards = [];
  int createCount = 0;

  @override
  Future<WorkCardResult> createDraft({required String idempotencyKey}) async {
    createCount += 1;
    final card = _card(id: 'work-$createCount');
    cards.insert(0, card);
    return card;
  }

  @override
  Future<void> delete(String id) async {
    cards.removeWhere((card) => card.id == id);
  }

  @override
  Future<WorkCardResult> hide(String id) async {
    return _replaceStatus(id, 'hidden_by_user');
  }

  @override
  Future<List<WorkCardResult>> list() async => List.of(cards);

  @override
  Future<WorkCardResult> publish(String id) async {
    return _replaceStatus(id, 'published');
  }

  @override
  Future<WorkCardResult> show(String id) async {
    return _replaceStatus(id, 'published');
  }

  @override
  Future<List<CategoryOption>> taxonomy(String categoryType) async {
    return switch (categoryType) {
      'work_category' => const [
        CategoryOption(
          id: 'category-1',
          categoryType: 'work_category',
          name: 'Stitching',
        ),
      ],
      'work_name' => const [
        CategoryOption(
          id: 'work-name-1',
          parentId: 'category-1',
          categoryType: 'work_name',
          name: 'Flat hemming',
        ),
      ],
      _ => const [
        CategoryOption(
          id: 'product-1',
          categoryType: 'product_type',
          name: 'Dupatta',
        ),
      ],
    };
  }

  @override
  Future<WorkCardResult> update(String id, WorkCardUpsert fields) async {
    final current = cards.firstWhere((card) => card.id == id);
    final updated = _copyCard(
      current,
      categoryId: fields.categoryId,
      categoryName: fields.categoryId == null ? null : 'Stitching',
      workNameId: fields.workNameId,
      workName: fields.workNameId == null ? null : 'Flat hemming',
      productTypeIds: fields.productTypeIds ?? const [],
      productTypes: fields.productTypeIds?.isEmpty == false
          ? const ['Dupatta']
          : const [],
      description: fields.description,
    );
    _replace(updated);
    return updated;
  }

  WorkCardResult _replaceStatus(String id, String status) {
    final card = cards.firstWhere((item) => item.id == id);
    final updated = _copyCard(card, status: status);
    _replace(updated);
    return updated;
  }

  void _replace(WorkCardResult card) {
    cards[cards.indexWhere((item) => item.id == card.id)] = card;
  }
}

class _NoopMediaPicker implements MediaPickerGateway {
  @override
  Future<List<SelectedMediaImage>> pickImages({required int limit}) async {
    return const [];
  }

  @override
  Future<List<SelectedMediaImage>> recoverLostImages() async => const [];
}

WorkCardResult _card({required String id}) {
  final now = DateTime(2026, 7, 13);
  return WorkCardResult(
    id: id,
    profileId: 'profile-1',
    status: 'draft',
    title: '',
    productTypeIds: const [],
    customProductTexts: const [],
    productTypes: const [],
    photoCount: 0,
    photos: const [],
    createdAt: now,
    updatedAt: now,
  );
}

WorkCardResult _copyCard(
  WorkCardResult card, {
  String? status,
  String? categoryId,
  String? categoryName,
  String? workNameId,
  String? workName,
  List<String>? productTypeIds,
  List<String>? productTypes,
  String? description,
}) {
  return WorkCardResult(
    id: card.id,
    profileId: card.profileId,
    status: status ?? card.status,
    title: workName ?? card.title,
    categoryId: categoryId ?? card.categoryId,
    categoryName: categoryName ?? card.categoryName,
    workNameId: workNameId ?? card.workNameId,
    workName: workName ?? card.workName,
    productTypeIds: productTypeIds ?? card.productTypeIds,
    customProductTexts: card.customProductTexts,
    productTypes: productTypes ?? card.productTypes,
    description: description ?? card.description,
    photoCount: card.photoCount,
    photos: card.photos,
    createdAt: card.createdAt,
    updatedAt: DateTime(2026, 7, 13, 10),
  );
}
