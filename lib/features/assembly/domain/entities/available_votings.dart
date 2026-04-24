import 'package:equatable/equatable.dart';
import 'assembly.dart';

class AvailableVotings extends Equatable {
  final List<Assembly> ordinaryAssemblies;
  final List<Assembly> extraordinaryAssemblies;
  final List<Assembly> extraordinaryAgendaAssemblies;

  const AvailableVotings({
    required this.ordinaryAssemblies,
    required this.extraordinaryAssemblies,
    required this.extraordinaryAgendaAssemblies,
  });

  List<Assembly> get all {
    return [
      ...ordinaryAssemblies,
      ...extraordinaryAssemblies,
      ...extraordinaryAgendaAssemblies,
    ];
  }

  @override
  List<Object?> get props => [
        ordinaryAssemblies,
        extraordinaryAssemblies,
        extraordinaryAgendaAssemblies,
      ];
}
