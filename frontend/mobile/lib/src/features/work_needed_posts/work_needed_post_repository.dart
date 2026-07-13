import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/work_needed_post_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workNeededPostRepositoryProvider = Provider<WorkNeededPostRepository>((
  ref,
) {
  return ApiWorkNeededPostRepository(ref.watch(connectApiProvider));
});

abstract class WorkNeededPostRepository {
  Future<List<WorkNeededPostResult>> list();

  Future<WorkNeededPostResult> createDraft({required String idempotencyKey});

  Future<WorkNeededPostResult> update(String id, WorkNeededPostUpsert fields);

  Future<WorkNeededPostResult> publish(String id);

  Future<WorkNeededPostResult> pause(String id);

  Future<WorkNeededPostResult> resume(String id);

  Future<WorkNeededPostResult> close(String id);

  Future<void> delete(String id);

  Future<List<CategoryOption>> taxonomy(String categoryType);
}

class ApiWorkNeededPostRepository implements WorkNeededPostRepository {
  const ApiWorkNeededPostRepository(this._api);

  final ConnectApi _api;

  @override
  Future<List<WorkNeededPostResult>> list() => _api.workNeededPosts();

  @override
  Future<WorkNeededPostResult> createDraft({required String idempotencyKey}) {
    return _api.createWorkNeededPost(
      const WorkNeededPostUpsert(),
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<WorkNeededPostResult> update(String id, WorkNeededPostUpsert fields) {
    return _api.updateWorkNeededPost(id, fields);
  }

  @override
  Future<WorkNeededPostResult> publish(String id) {
    return _api.publishWorkNeededPost(id);
  }

  @override
  Future<WorkNeededPostResult> pause(String id) {
    return _api.pauseWorkNeededPost(id);
  }

  @override
  Future<WorkNeededPostResult> resume(String id) {
    return _api.resumeWorkNeededPost(id);
  }

  @override
  Future<WorkNeededPostResult> close(String id) {
    return _api.closeWorkNeededPost(id);
  }

  @override
  Future<void> delete(String id) => _api.deleteWorkNeededPost(id);

  @override
  Future<List<CategoryOption>> taxonomy(String categoryType) {
    return _api.categories(categoryType: categoryType);
  }
}
