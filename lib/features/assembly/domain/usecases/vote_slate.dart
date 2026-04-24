import 'package:ascesa/features/assembly/domain/repositories/assembly_repository.dart';

class VoteSlate {
  final AssemblyRepository repository;

  VoteSlate(this.repository);

  Future<void> call({
    required String assemblyId,
    required String slateId,
  }) async {
    await repository.voteExtraordinarySlate(assemblyId, slateId);
  }
}
