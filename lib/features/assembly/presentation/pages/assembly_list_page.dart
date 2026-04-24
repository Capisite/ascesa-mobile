import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/assembly/presentation/controllers/assembly_controller.dart';
import 'package:ascesa/features/assembly/domain/entities/assembly.dart';
import 'package:ascesa/features/assembly/presentation/pages/assembly_voting_page.dart';
import 'package:intl/intl.dart';

class AssemblyListPage extends StatefulWidget {
  final AssemblyController controller;

  const AssemblyListPage({super.key, required this.controller});

  @override
  State<AssemblyListPage> createState() => _AssemblyListPageState();
}

class _AssemblyListPageState extends State<AssemblyListPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchVotings();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Votações / Assembleias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          if (widget.controller.isLoading && widget.controller.availableVotings == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.greenPrimary));
          }

          if (widget.controller.errorMessage != null && widget.controller.availableVotings == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(widget.controller.errorMessage!),
                  TextButton(
                    onPressed: () => widget.controller.fetchVotings(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final allVotings = widget.controller.availableVotings?.all ?? [];

          if (allVotings.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => widget.controller.fetchVotings(),
              color: AppColors.greenPrimary,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'Nenhuma votação disponível no momento.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => widget.controller.fetchVotings(),
            color: AppColors.greenPrimary,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: allVotings.length,
              itemBuilder: (context, index) {
                final assembly = allVotings[index];
                return _buildAssemblyCard(assembly);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssemblyCard(Assembly assembly) {
    final bool isElectoral = assembly.type == AssemblyType.extraordinary && 
                             assembly.extraordinaryMode == ExtraordinaryMode.electoral;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssemblyVotingPage(
                  controller: widget.controller,
                  assembly: assembly,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.greenPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        assembly.type == AssemblyType.ordinary ? 'Ordinária' : 'Extraordinária',
                        style: const TextStyle(
                          color: AppColors.greenPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isElectoral)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Eleitoral',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  assembly.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      'Início: ${DateFormat('dd/MM/yyyy HH:mm').format(assembly.startDate)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                if (assembly.endDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        'Fim: ${DateFormat('dd/MM/yyyy HH:mm').format(assembly.endDate!)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Participar',
                      style: TextStyle(
                        color: AppColors.greenPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 16, color: AppColors.greenPrimary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
