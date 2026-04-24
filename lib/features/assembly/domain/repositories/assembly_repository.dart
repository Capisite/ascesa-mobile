import 'package:ascesa/features/assembly/domain/entities/available_votings.dart';

abstract class AssemblyRepository {
  Future<AvailableVotings> getAvailableVotings();
  Future<void> voteOrdinaryAgendaItem(String assemblyId, String agendaItemId, String decision);
  Future<void> voteExtraordinaryAgendaItem(String assemblyId, String agendaItemId, String decision);
  Future<void> voteExtraordinarySlate(String assemblyId, String slateId);
}
