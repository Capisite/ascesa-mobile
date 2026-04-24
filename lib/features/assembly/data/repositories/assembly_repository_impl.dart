import 'package:ascesa/features/assembly/domain/entities/available_votings.dart';
import 'package:ascesa/features/assembly/domain/repositories/assembly_repository.dart';
import 'package:ascesa/features/assembly/data/datasources/assembly_remote_data_source.dart';

class AssemblyRepositoryImpl implements AssemblyRepository {
  final AssemblyRemoteDataSource remoteDataSource;

  AssemblyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AvailableVotings> getAvailableVotings() async {
    return await remoteDataSource.getAvailableVotings();
  }

  @override
  Future<void> voteOrdinaryAgendaItem(String assemblyId, String agendaItemId, String decision) async {
    await remoteDataSource.voteOrdinaryAgendaItem(assemblyId, agendaItemId, decision);
  }

  @override
  Future<void> voteExtraordinaryAgendaItem(String assemblyId, String agendaItemId, String decision) async {
    await remoteDataSource.voteExtraordinaryAgendaItem(assemblyId, agendaItemId, decision);
  }

  @override
  Future<void> voteExtraordinarySlate(String assemblyId, String slateId) async {
    await remoteDataSource.voteExtraordinarySlate(assemblyId, slateId);
  }
}
