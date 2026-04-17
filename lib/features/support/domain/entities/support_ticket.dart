import 'package:equatable/equatable.dart';

enum SupportTicketStatus { open, closed }

class SupportTicket extends Equatable {
  final String id;
  final SupportTicketStatus status;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicket({
    required this.id,
    required this.status,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, status, lastMessageAt, createdAt, updatedAt];
}
