class DietPlanModel {
  final String id;
  final String childId;
  final String therapistId;
  final List<Meal> meals;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? notes;

  const DietPlanModel({
    required this.id,
    required this.childId,
    required this.therapistId,
    required this.meals,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.notes,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> j) => DietPlanModel(
        id:        j['_id'] as String? ?? '',
        childId:   j['child_id'] as String? ?? '',
        therapistId: j['therapist_id'] as String? ?? '',
        meals:     (j['meals'] as List<dynamic>?)
            ?.map((m) => Meal.fromJson(m as Map<String, dynamic>))
            .toList() ?? [],
        startDate: DateTime.tryParse(j['start_date'] as String? ?? '') ?? DateTime.now(),
        endDate:   DateTime.tryParse(j['end_date'] as String? ?? '') ?? DateTime.now(),
        isActive:  j['is_active'] as bool? ?? true,
        notes:     j['notes'] as String?,
      );

  // Grouped helpers
  List<Meal> get breakfast => meals.where((m) => m.mealTime == 'breakfast').toList();
  List<Meal> get lunch     => meals.where((m) => m.mealTime == 'lunch').toList();
  List<Meal> get dinner    => meals.where((m) => m.mealTime == 'dinner').toList();
  List<Meal> get snacks    => meals.where((m) => m.mealTime == 'snack').toList();
}

class Meal {
  final String mealId;
  final String name;
  final String? description;
  final String mealTime; // breakfast | lunch | dinner | snack
  final int caloriesApprox;
  final List<String> ingredients;
  final String? instructions;
  final String frequency; // daily | weekly

  const Meal({
    required this.mealId,
    required this.name,
    this.description,
    required this.mealTime,
    required this.caloriesApprox,
    required this.ingredients,
    this.instructions,
    required this.frequency,
  });

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        mealId:          j['meal_id'] as String? ?? '',
        name:            j['name'] as String? ?? '',
        description:     j['description'] as String?,
        mealTime:        j['meal_time'] as String? ?? 'breakfast',
        caloriesApprox:  j['calories_approx'] as int? ?? 0,
        ingredients:     (j['ingredients'] as List<dynamic>?)
                            ?.map((e) => e.toString()).toList() ?? [],
        instructions:    j['instructions'] as String?,
        frequency:       j['frequency'] as String? ?? 'daily',
      );
}
