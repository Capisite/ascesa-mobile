import 'package:ascesa/features/assembly/domain/entities/assembly.dart';
import 'agenda_item_model.dart';
import 'slate_model.dart';

class AssemblyModel extends Assembly {
  const AssemblyModel({
    required super.id,
    required super.name,
    required super.type,
    required super.extraordinaryMode,
    required super.startDate,
    super.endDate,
    super.agendaItems,
    super.slates,
    super.mySlateId,
  });

  factory AssemblyModel.fromJson(Map<String, dynamic> json, {AssemblyType? forcedType, ExtraordinaryMode? forcedMode}) {
    return AssemblyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: forcedType ?? _parseType(json['type'] as String?),
      extraordinaryMode: forcedMode ?? _parseMode(json['extraordinaryMode'] as String?),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      agendaItems: (json['agendaItems'] as List<dynamic>?)
          ?.map((e) => AgendaItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      slates: (json['slates'] as List<dynamic>?)
          ?.map((e) => SlateModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      mySlateId: json['mySlateId'] as String?,
    );
  }

  static AssemblyType _parseType(String? type) {
    if (type == 'ORDINARY') return AssemblyType.ordinary;
    return AssemblyType.extraordinary;
  }

  static ExtraordinaryMode _parseMode(String? mode) {
    if (mode == 'ELECTORAL') return ExtraordinaryMode.electoral;
    return ExtraordinaryMode.agenda;
  }
}
