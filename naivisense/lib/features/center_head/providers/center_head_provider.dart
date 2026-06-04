import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/alerts_repository.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/repositories/diet_plans_repository.dart';
import '../../../data/repositories/home_plans_repository.dart';
import '../../../data/repositories/sessions_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/error_handler_service.dart';

final centerChildrenProvider = FutureProvider<List<ChildModel>>(
  (ref) => ref.read(childrenRepositoryProvider).getChildren(),
);

final adminChildSessionsProvider =
    FutureProvider.family<List<SessionModel>, String>(
  (ref, childId) =>
      ref.read(sessionsRepositoryProvider).getSessions(childId: childId),
);

final adminChildPlanProvider =
    FutureProvider.family<HomePlanModel?, String>(
  (ref, childId) =>
      ref.read(homePlansRepositoryProvider).getActivePlan(childId),
);

final adminChildDietPlanProvider =
    FutureProvider.family<DietPlanModel?, String>(
  (ref, childId) =>
      ref.read(dietPlansRepositoryProvider).getActivePlan(childId),
);

final adminChildAlertsProvider =
    FutureProvider.family<List<AlertModel>, String>(
  (ref, childId) =>
      ref.read(alertsRepositoryProvider).getAlerts(childId),
);

final adminUserProvider = FutureProvider.family<UserModel, String>(
  (ref, userId) async {
    try {
      final api = ref.read(apiServiceProvider);
      final res = await api.get('/users/$userId');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  },
);
