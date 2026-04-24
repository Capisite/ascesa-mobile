import 'package:ascesa/features/assembly/domain/repositories/assembly_repository.dart';
import 'package:ascesa/features/assembly/domain/entities/assembly.dart';

class VoteAgendaItem {
  final AssemblyRepository repository;

  VoteAgendaItem(this.repository);

  Future<void> call({
    required String assemblyId,
    required String agendaItemId,
    required String decision,
    required AssemblyType type,
  }) async {
    if (type == AssemblyType.ordinary) {
      await repository.voteOrdinaryAgendaItem(assemblyId, agendaItemId, decision);
    } else {
      await repository.voteExtraordinaryAgendaItem(assemblyId, agendaItemId, decision);
    }
  }
}
