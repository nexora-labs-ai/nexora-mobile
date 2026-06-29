class ItineraryModel {
  final String id;
  final String groupId;
  final String createdBy;
  final String title;
  final String? description;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<ItineraryItemModel> items;

  const ItineraryModel({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.items,
  });

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      createdBy: json['createdBy'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ItineraryItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class ItineraryItemModel {
  final String id;
  final String itineraryId;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final double? estimatedCost;
  final int orderNo;
  final String? notes;

  const ItineraryItemModel({
    required this.id,
    required this.itineraryId,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.estimatedCost,
    required this.orderNo,
    this.notes,
  });

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    return ItineraryItemModel(
      id: json['id'] as String,
      itineraryId: json['itineraryId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      estimatedCost: json['estimatedCost'] != null
          ? double.tryParse(json['estimatedCost'].toString())
          : null,
      orderNo: json['orderNo'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'estimatedCost': estimatedCost,
      'orderNo': orderNo,
      'notes': notes,
    };
  }

  ItineraryItemModel copyWith({
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    double? estimatedCost,
    int? orderNo,
    String? notes,
  }) {
    return ItineraryItemModel(
      id: id,
      itineraryId: itineraryId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      orderNo: orderNo ?? this.orderNo,
      notes: notes ?? this.notes,
    );
  }
}
