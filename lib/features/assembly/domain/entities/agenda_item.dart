import 'package:equatable/equatable.dart';

class AgendaItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int displayOrder;
  final String? myDecision; // 'APPROVED', 'NOT_APPROVED' or null

  const AgendaItem({
    required this.id,
    required this.title,
    this.description,
    required this.displayOrder,
    this.myDecision,
  });

  @override
  List<Object?> get props => [id, title, description, displayOrder, myDecision];
}
