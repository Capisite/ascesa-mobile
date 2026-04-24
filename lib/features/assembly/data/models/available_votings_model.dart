import 'package:ascesa/features/assembly/domain/entities/available_votings.dart';
import 'package:ascesa/features/assembly/domain/entities/assembly.dart';
import 'assembly_model.dart';

class AvailableVotingsModel extends AvailableVotings {
  const AvailableVotingsModel({
    required super.ordinaryAssemblies,
    required super.extraordinaryAssemblies,
    required super.extraordinaryAgendaAssemblies,
  });

  factory AvailableVotingsModel.fromJson(Map<String, dynamic> json) {
    return AvailableVotingsModel(
      ordinaryAssemblies: (json['ordinaryAssemblies'] as List<dynamic>?)
          ?.map((e) => AssemblyModel.fromJson(e as Map<String, dynamic>, forcedType: AssemblyType.ordinary))
          .toList() ?? [],
      extraordinaryAssemblies: (json['extraordinaryAssemblies'] as List<dynamic>?)
          ?.map((e) => AssemblyModel.fromJson(e as Map<String, dynamic>, forcedType: AssemblyType.extraordinary, forcedMode: ExtraordinaryMode.electoral))
          .toList() ?? [],
      extraordinaryAgendaAssemblies: (json['extraordinaryAgendaAssemblies'] as List<dynamic>?)
          ?.map((e) => AssemblyModel.fromJson(e as Map<String, dynamic>, forcedType: AssemblyType.extraordinary, forcedMode: ExtraordinaryMode.agenda))
          .toList() ?? [],
    );
  }
}
