class HomePlanModel {
  final String id;
  final String childId;
  final String therapistId;
  final List<HomePlanTask> tasks;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const HomePlanModel({
    required this.id,
    required this.childId,
    required this.therapistId,
    required this.tasks,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory HomePlanModel.fromJson(Map<String, dynamic> j) => HomePlanModel(
        id:          j['_id'] as String? ?? '',
        childId:     j['child_id'] as String? ?? '',
        therapistId: j['therapist_id'] as String? ?? '',
        tasks:       (j['tasks'] as List<dynamic>?)
                         ?.map((t) => HomePlanTask.fromJson(t as Map<String, dynamic>))
                         .toList() ?? [],
        startDate:   DateTime.tryParse(j['start_date'] as String? ?? '') ?? DateTime.now(),
        endDate:     DateTime.tryParse(j['end_date'] as String? ?? '') ?? DateTime.now(),
        isActive:    j['is_active'] as bool? ?? true,
      );

  List<HomePlanTask> get morningTasks =>
      tasks.where((t) => t.timeOfDay == 'morning').toList();
  List<HomePlanTask> get afternoonTasks =>
      tasks.where((t) => t.timeOfDay == 'afternoon').toList();
  List<HomePlanTask> get eveningTasks =>
      tasks.where((t) => t.timeOfDay == 'evening').toList();
}

class HomePlanTask {
  final String taskId;
  final String title;
  final String description;
  final String icon;
  final String timeOfDay;   // morning | afternoon | evening
  final int durationMin;
  final String frequency;   // daily | weekly
  final int targetCount;

  const HomePlanTask({
    required this.taskId,
    required this.title,
    required this.description,
    required this.icon,
    required this.timeOfDay,
    required this.durationMin,
    required this.frequency,
    required this.targetCount,
  });

  factory HomePlanTask.fromJson(Map<String, dynamic> j) => HomePlanTask(
        taskId:      j['task_id'] as String? ?? '',
        title:       j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        icon:        j['icon'] as String? ?? '✅',
        timeOfDay:   j['time_of_day'] as String? ?? 'morning',
        durationMin: j['duration_min'] as int? ?? 15,
        frequency:   j['frequency'] as String? ?? 'daily',
        targetCount: j['target_count'] as int? ?? 1,
      );
}
