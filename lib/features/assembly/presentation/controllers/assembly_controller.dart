import 'package:flutter/material.dart';
import 'package:ascesa/features/assembly/domain/entities/available_votings.dart';
import 'package:ascesa/features/assembly/domain/entities/assembly.dart';
import 'package:ascesa/features/assembly/domain/usecases/get_available_votings.dart';
import 'package:ascesa/features/assembly/domain/usecases/vote_agenda_item.dart';
import 'package:ascesa/features/assembly/domain/usecases/vote_slate.dart';

class AssemblyController extends ChangeNotifier {
  final GetAvailableVotings getAvailableVotingsUseCase;
  final VoteAgendaItem voteAgendaItemUseCase;
  final VoteSlate voteSlateUseCase;

  AvailableVotings? _availableVotings;
  bool _isLoading = false;
  String? _errorMessage;

  AssemblyController({
    required this.getAvailableVotingsUseCase,
    required this.voteAgendaItemUseCase,
    required this.voteSlateUseCase,
  });

  AvailableVotings? get availableVotings => _availableVotings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVotings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableVotings = await getAvailableVotingsUseCase.call();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> castAgendaVote({
    required String assemblyId,
    required String agendaItemId,
    required String decision,
    required AssemblyType type,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await voteAgendaItemUseCase.call(
        assemblyId: assemblyId,
        agendaItemId: agendaItemId,
        decision: decision,
        type: type,
      );
      // Refresh to update myDecision
      await fetchVotings();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> castSlateVote({
    required String assemblyId,
    required String slateId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await voteSlateUseCase.call(
        assemblyId: assemblyId,
        slateId: slateId,
      );
      // Refresh to update mySlateId
      await fetchVotings();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}
