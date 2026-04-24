import 'package:equatable/equatable.dart';
import 'agenda_item.dart';
import 'slate.dart';

enum AssemblyType { ordinary, extraordinary }
enum ExtraordinaryMode { electoral, agenda }

class Assembly extends Equatable {
  final String id;
  final String name;
  final AssemblyType type;
  final ExtraordinaryMode extraordinaryMode;
  final DateTime startDate;
  final DateTime? endDate;
  final List<AgendaItem> agendaItems;
  final List<Slate> slates;
  final String? mySlateId;

  const Assembly({
    required this.id,
    required this.name,
    required this.type,
    required this.extraordinaryMode,
    required this.startDate,
    this.endDate,
    this.agendaItems = const [],
    this.slates = const [],
    this.mySlateId,
  });

  bool get isActive {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        extraordinaryMode,
        startDate,
        endDate,
        agendaItems,
        slates,
        mySlateId,
      ];
}
