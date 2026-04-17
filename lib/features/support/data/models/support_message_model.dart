import 'package:ascesa/features/support/domain/entities/support_message.dart';

class SupportMessageModel extends SupportMessage {
  const SupportMessageModel({
    required super.id,
    required super.content,
    required super.createdAt,
    required super.sender,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      sender: SupportSenderModel.fromJson(json['sender']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'sender': (sender as SupportSenderModel).toJson(),
    };
  }
}

class SupportSenderModel extends SupportSender {
  const SupportSenderModel({
    required super.id,
    required super.name,
    required super.email,
    required super.type,
  });

  factory SupportSenderModel.fromJson(Map<String, dynamic> json) {
    return SupportSenderModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: json['type'] == 'ADMIN' ? SupportSenderType.admin : SupportSenderType.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type == SupportSenderType.admin ? 'ADMIN' : 'USER',
    };
  }
}
