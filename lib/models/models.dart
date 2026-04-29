class Activity {
  final int id;
  final String name;
  final int? projectId;
  final int durationMinutes;
  final int energyLevel;
  final String status;

  Activity({required this.id, required this.name, this.projectId, required this.durationMinutes, required this.energyLevel, required this.status});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      projectId: json['project_id'],
      durationMinutes: json['duration_minutes'],
      energyLevel: json['energy_level'],
      status: json['status'],
    );
  }
}

class Project {
  final int id;
  final String name;

  Project({required this.id, required this.name});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
    );
  }
}
