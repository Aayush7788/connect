import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/work_card_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workCardRepositoryProvider = Provider<WorkCardRepository>((ref) {
  return ApiWorkCardRepository(ref.watch(connectApiProvider));
});

abstract class WorkCardRepository {
  Future<List<WorkCardResult>> list();

  Future<WorkCardResult> createDraft({required String idempotencyKey});

  Future<WorkCardResult> update(String id, WorkCardUpsert fields);

  Future<WorkCardResult> publish(String id);

  Future<WorkCardResult> hide(String id);

  Future<WorkCardResult> show(String id);

  Future<void> delete(String id);

  Future<List<CategoryOption>> taxonomy(String categoryType);
}

class ApiWorkCardRepository implements WorkCardRepository {
  const ApiWorkCardRepository(this._api);

  final ConnectApi _api;

  @override
  Future<List<WorkCardResult>> list() => _api.workCards();

  @override
  Future<WorkCardResult> createDraft({required String idempotencyKey}) {
    return _api.createWorkCard(
      const WorkCardUpsert(),
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<WorkCardResult> update(String id, WorkCardUpsert fields) {
    return _api.updateWorkCard(id, fields);
  }

  @override
  Future<WorkCardResult> publish(String id) => _api.publishWorkCard(id);

  @override
  Future<WorkCardResult> hide(String id) => _api.hideWorkCard(id);

  @override
  Future<WorkCardResult> show(String id) => _api.showWorkCard(id);

  @override
  Future<void> delete(String id) => _api.deleteWorkCard(id);

  @override
  Future<List<CategoryOption>> taxonomy(String categoryType) {
    return _api.categories(categoryType: categoryType);
  }
}
