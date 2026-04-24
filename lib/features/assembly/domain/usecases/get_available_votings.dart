import 'package:ascesa/features/assembly/domain/entities/available_votings.dart';
import 'package:ascesa/features/assembly/domain/repositories/assembly_repository.dart';

class GetAvailableVotings {
  final AssemblyRepository repository;

  GetAvailableVotings(this.repository);

  Future<AvailableVotings> call() async {
    return await repository.getAvailableVotings();
  }
}
