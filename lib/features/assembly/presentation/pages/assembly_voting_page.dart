import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/assembly/presentation/controllers/assembly_controller.dart';
import 'package:ascesa/features/assembly/domain/entities/assembly.dart';
import 'package:ascesa/features/assembly/domain/entities/agenda_item.dart';
import 'package:ascesa/features/assembly/domain/entities/slate.dart';

class AssemblyVotingPage extends StatefulWidget {
  final AssemblyController controller;
  final Assembly assembly;

  const AssemblyVotingPage({
    super.key,
    required this.controller,
    required this.assembly,
  });

  @override
  State<AssemblyVotingPage> createState() => _AssemblyVotingPageState();
}

class _AssemblyVotingPageState extends State<AssemblyVotingPage> {
  @override
  Widget build(BuildContext context) {
    final bool isElectoral = widget.assembly.type == AssemblyType.extraordinary && 
                             widget.assembly.extraordinaryMode == ExtraordinaryMode.electoral;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greenDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.assembly.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final isLoading = widget.controller.isLoading;
          
          // Encontra a versão mais recente da assembleia no controlador (após votos)
          final allVotings = widget.controller.availableVotings?.all ?? [];
          final currentAssembly = allVotings.firstWhere(
            (a) => a.id == widget.assembly.id,
            orElse: () => widget.assembly,
          );

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isElectoral)
                      _buildElectoralView(currentAssembly)
                    else
                      _buildAgendaView(currentAssembly),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.greenPrimary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAgendaView(Assembly assembly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Itens da Pauta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Vote em cada item separadamente selecionando uma das opções abaixo.',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        ...assembly.agendaItems.map((item) => _buildAgendaItemCard(assembly.id, item, assembly.type)),
      ],
    );
  }

  Widget _buildAgendaItemCard(String assemblyId, AgendaItem item, AssemblyType type) {
    final bool isApproved = item.myDecision == 'APPROVED';
    final bool isNotApproved = item.myDecision == 'NOT_APPROVED';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.greenDark,
            ),
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildVoteButton(
                  label: 'Aprovar',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  isSelected: isApproved,
                  onTap: () => widget.controller.castAgendaVote(
                    assemblyId: assemblyId,
                    agendaItemId: item.id,
                    decision: 'APPROVED',
                    type: type,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVoteButton(
                  label: 'Rejeitar',
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                  isSelected: isNotApproved,
                  onTap: () => widget.controller.castAgendaVote(
                    assemblyId: assemblyId,
                    agendaItemId: item.id,
                    decision: 'NOT_APPROVED',
                    type: type,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElectoralView(Assembly assembly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chapas Candidatas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selecione uma das chapas abaixo para registrar seu voto único.',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        ...assembly.slates.map((slate) => _buildSlateCard(assembly.id, slate, assembly.mySlateId)),
      ],
    );
  }

  Widget _buildSlateCard(String assemblyId, Slate slate, String? mySlateId) {
    final bool isSelected = mySlateId == slate.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.greenPrimary : AppColors.border.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => widget.controller.castSlateVote(
            assemblyId: assemblyId,
            slateId: slate.id,
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _parseColor(slate.color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      slate.number.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _parseColor(slate.color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slate.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greenDark,
                        ),
                      ),
                      if (slate.slogan.isNotEmpty)
                        Text(
                          slate.slogan,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.greenPrimary, size: 28)
                else
                  const Icon(Icons.radio_button_off, color: AppColors.border, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoteButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.greenPrimary;
    }
  }
}
