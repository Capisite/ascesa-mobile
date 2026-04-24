import 'package:ascesa/features/assembly/domain/entities/slate.dart';

class SlateModel extends Slate {
  const SlateModel({
    required super.id,
    required super.number,
    required super.name,
    required super.slogan,
    required super.color,
    super.participants,
  });

  factory SlateModel.fromJson(Map<String, dynamic> json) {
    return SlateModel(
      id: json['id'] as String,
      number: json['number'] as int,
      name: json['name'] as String,
      slogan: json['slogan'] as String? ?? '',
      color: json['color'] as String? ?? '#000000',
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => SlateParticipantModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SlateParticipantModel extends SlateParticipant {
  const SlateParticipantModel({
    required super.name,
    required super.photoUrl,
  });

  factory SlateParticipantModel.fromJson(Map<String, dynamic> json) {
    return SlateParticipantModel(
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }
}
