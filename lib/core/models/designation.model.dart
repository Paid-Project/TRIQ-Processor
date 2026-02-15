class DesignationModel {
  final String id;
  final String name;

  DesignationModel({
    required this.id,
    required this.name,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }
}