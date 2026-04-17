import 'package:equatable/equatable.dart';

enum SupportSenderType { admin, user }

class SupportMessage extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;
  final SupportSender sender;

  const SupportMessage({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.sender,
  });

  @override
  List<Object?> get props => [id, content, createdAt, sender];
}

class SupportSender extends Equatable {
  final String id;
  final String name;
  final String email;
  final SupportSenderType type;

  const SupportSender({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, email, type];
}
