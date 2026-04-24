import 'package:ascesa/features/assembly/domain/entities/agenda_item.dart';

class AgendaItemModel extends AgendaItem {
  const AgendaItemModel({
    required super.id,
    required super.title,
    super.description,
    required super.displayOrder,
    super.myDecision,
  });

  factory AgendaItemModel.fromJson(Map<String, dynamic> json) {
    return AgendaItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      myDecision: json['myDecision'] as String?,
    );
  }
}
