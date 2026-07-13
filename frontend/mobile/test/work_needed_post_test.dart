import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/work_needed_post_models.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:connect_app/src/features/work_needed_posts/work_needed_post_controller.dart';
import 'package:connect_app/src/features/work_needed_posts/work_needed_post_form_screen.dart';
import 'package:connect_app/src/features/work_needed_posts/work_needed_post_owner_list.dart';
import 'package:connect_app/src/features/work_needed_posts/work_needed_post_repository.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('work-needed response preserves searchable fields and lifecycle', () {
    final post = WorkNeededPostResult.fromJson({
      'id': 'post-1',
      'profile_id': 'profile-1',
      'status': 'active',
      'title': 'Flat hemming',
      'category_id': 'category-1',
      'category_name': 'Stitching',
      'work_name_id': 'work-name-1',
      'work_name': 'Flat hemming',
      'product_type_ids': ['product-1'],
      'custom_product_texts': <String>[],
      'product_types': ['Dupatta'],
      'description': 'Need clean flat hemming for dupattas',
      'photo_count': 1,
      'photos': [
        {
          'id': 'media-1',
          'media_kind': 'image',
          'visibility': 'public',
          'upload_status': 'ready',
          'sort_order': 0,
          'url': 'https://media.test/needed.jpg',
        },
      ],
      'last_activity_at': '2026-07-13T09:00:00Z',
      'closed_at': null,
      'created_at': '2026-07-13T08:00:00Z',
      'updated_at': '2026-07-13T09:00:00Z',
    });

    expect(post.displayWorkName, 'Flat hemming');
    expect(post.displayCategory, 'Stitching');
    expect(post.productTypes, ['Dupatta']);
    expect(post.photos.single.id, 'media-1');
    expect(post.closedAt, isNull);
  });

  test(
    'controller publishes, pauses, resumes, closes and deletes a post',
    () async {
      final repository = _FakeWorkNeededPostRepository()
        ..posts.add(_post(id: 'post-1'));
      final container = ProviderContainer(
        overrides: [
          workNeededPostRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        workNeededPostControllerProvider.notifier,
      );
      await controller.load();
      expect(
        container.read(workNeededPostControllerProvider).posts,
        hasLength(1),
      );

      expect(
        await controller.saveAndPublish(
          id: 'post-1',
          fields: const WorkNeededPostUpsert(
            categoryId: 'category-1',
            workNameId: 'work-name-1',
            productTypeIds: ['product-1'],
            customProductTexts: [],
            description: 'Need a clean finish',
          ),
          publish: true,
        ),
        isTrue,
      );
      var post = controller.find('post-1')!;
      expect(post.status, 'active');

      expect(await controller.pause(post), isTrue);
      post = controller.find('post-1')!;
      expect(post.status, 'paused');

      expect(await controller.resume(post), isTrue);
      post = controller.find('post-1')!;
      expect(post.status, 'active');

      expect(await controller.close(post), isTrue);
      post = controller.find('post-1')!;
      expect(post.status, 'closed_by_user');

      expect(await controller.delete(post), isTrue);
      expect(container.read(workNeededPostControllerProvider).posts, isEmpty);
    },
  );

  testWidgets('empty owner post list shows the posting prompt', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workNeededPostRepositoryProvider.overrideWithValue(
            _FakeWorkNeededPostRepository(),
          ),
        ],
        child: MaterialApp(
          theme: buildConnectTheme(),
          home: const Scaffold(
            body: SingleChildScrollView(child: WorkNeededPostOwnerList()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Find work by posting'), findsOneWidget);
  });

  testWidgets('add post creates a draft and shows the complete long form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeWorkNeededPostRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workNeededPostRepositoryProvider.overrideWithValue(repository),
          mediaPickerProvider.overrideWithValue(_NoopMediaPicker()),
        ],
        child: MaterialApp(
          theme: buildConnectTheme(),
          home: const WorkNeededPostFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.createCount, 1);
    expect(find.text('Add Work Needed'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Work name'), findsOneWidget);
    expect(find.text('Product type'), findsOneWidget);
    expect(find.text('Photos of work needed'), findsOneWidget);
    expect(find.text('Minimum 3 photos required'), findsOneWidget);
    expect(find.text('Save and Publish'), findsOneWidget);

    await tester.tap(find.text('Save and Publish'));
    await tester.pump();
    expect(find.text('Select a category'), findsOneWidget);
    expect(find.text('Select a work name'), findsOneWidget);
    expect(find.text('Select at least one product type'), findsOneWidget);
  });
}

class _FakeWorkNeededPostRepository implements WorkNeededPostRepository {
  final List<WorkNeededPostResult> posts = [];
  int createCount = 0;

  @override
  Future<WorkNeededPostResult> close(String id) async {
    return _replaceStatus(id, 'closed_by_user');
  }

  @override
  Future<WorkNeededPostResult> createDraft({
    required String idempotencyKey,
  }) async {
    createCount += 1;
    final post = _post(id: 'post-$createCount');
    posts.insert(0, post);
    return post;
  }

  @override
  Future<void> delete(String id) async {
    posts.removeWhere((post) => post.id == id);
  }

  @override
  Future<List<WorkNeededPostResult>> list() async => List.of(posts);

  @override
  Future<WorkNeededPostResult> pause(String id) async {
    return _replaceStatus(id, 'paused');
  }

  @override
  Future<WorkNeededPostResult> publish(String id) async {
    return _replaceStatus(id, 'active');
  }

  @override
  Future<WorkNeededPostResult> resume(String id) async {
    return _replaceStatus(id, 'active');
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
  Future<WorkNeededPostResult> update(
    String id,
    WorkNeededPostUpsert fields,
  ) async {
    final current = posts.firstWhere((post) => post.id == id);
    final updated = _copyPost(
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

  WorkNeededPostResult _replaceStatus(String id, String status) {
    final post = posts.firstWhere((item) => item.id == id);
    final updated = _copyPost(post, status: status);
    _replace(updated);
    return updated;
  }

  void _replace(WorkNeededPostResult post) {
    posts[posts.indexWhere((item) => item.id == post.id)] = post;
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

WorkNeededPostResult _post({required String id}) {
  final now = DateTime(2026, 7, 13);
  return WorkNeededPostResult(
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

WorkNeededPostResult _copyPost(
  WorkNeededPostResult post, {
  String? status,
  String? categoryId,
  String? categoryName,
  String? workNameId,
  String? workName,
  List<String>? productTypeIds,
  List<String>? productTypes,
  String? description,
}) {
  return WorkNeededPostResult(
    id: post.id,
    profileId: post.profileId,
    status: status ?? post.status,
    title: workName ?? post.title,
    categoryId: categoryId ?? post.categoryId,
    categoryName: categoryName ?? post.categoryName,
    workNameId: workNameId ?? post.workNameId,
    workName: workName ?? post.workName,
    productTypeIds: productTypeIds ?? post.productTypeIds,
    customProductTexts: post.customProductTexts,
    productTypes: productTypes ?? post.productTypes,
    description: description ?? post.description,
    photoCount: post.photoCount,
    photos: post.photos,
    closedAt: status == 'closed_by_user' ? DateTime(2026, 7, 13, 11) : null,
    createdAt: post.createdAt,
    updatedAt: DateTime(2026, 7, 13, 10),
  );
}
