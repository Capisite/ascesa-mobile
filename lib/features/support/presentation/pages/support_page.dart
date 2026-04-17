import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/support/presentation/controllers/support_controller.dart';
import 'package:ascesa/features/support/presentation/widgets/chat_bubble.dart';
import 'package:ascesa/features/support/domain/entities/support_message.dart';
import 'package:intl/intl.dart';

class SupportPage extends StatefulWidget {
  final SupportController controller;
  final String userId;

  const SupportPage({
    super.key,
    required this.controller,
    required this.userId,
  });

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    // Inicializa carregando dados e conectando socket
    widget.controller.init();
    widget.controller.markAsRead();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_msgController.text.trim().isEmpty) return;
    widget.controller.sendMessage(_msgController.text);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F3),
      appBar: AppBar(
        backgroundColor: AppColors.greenDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Suporte ASCESA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (widget.controller.ticket != null)
              Text(
                widget.controller.ticket!.status.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 4,
              backgroundColor: Colors.greenAccent,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.greenPrimary))
                : _buildMessageList(),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final groups = widget.controller.groupedMessages;
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textLight.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              '👋 Olá! Como podemos ajudar hoje?',
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: groups.keys.length,
      itemBuilder: (context, index) {
        final label = groups.keys.elementAt(index);
        final messages = groups[label]!;

        return Column(
          children: [
            _buildDateSeparator(label),
            ...messages.map((m) => ChatBubble(
                  message: m,
                  isMe: m.sender.id == widget.userId,
                )),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5F3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgController,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.controller.isSending ? null : _handleSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.greenDark,
                shape: BoxShape.circle,
              ),
              child: widget.controller.isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
