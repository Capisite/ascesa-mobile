import 'package:equatable/equatable.dart';

class Faq extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String? category;
  final int displayOrder;
  final bool isActive;

  const Faq({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    required this.displayOrder,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, question, answer, category, displayOrder, isActive];
}
