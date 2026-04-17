import 'package:ascesa/features/support/domain/entities/support_ticket.dart';

class SupportTicketModel extends SupportTicket {
  const SupportTicketModel({
    required super.id,
    required super.status,
    super.lastMessageAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'],
      status: json['status'] == 'OPEN' ? SupportTicketStatus.open : SupportTicketStatus.closed,
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status == SupportTicketStatus.open ? 'OPEN' : 'CLOSED',
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
