import 'package:equatable/equatable.dart';

class Slate extends Equatable {
  final String id;
  final int number;
  final String name;
  final String slogan;
  final String color;
  final List<SlateParticipant>? participants;

  const Slate({
    required this.id,
    required this.number,
    required this.name,
    required this.slogan,
    required this.color,
    this.participants,
  });

  @override
  List<Object?> get props => [id, number, name, slogan, color, participants];
}

class SlateParticipant extends Equatable {
  final String name;
  final String photoUrl;

  const SlateParticipant({
    required this.name,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [name, photoUrl];
}
