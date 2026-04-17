import 'package:flutter/material.dart';
import 'package:ascesa/features/support/domain/repositories/support_repository.dart';
import 'package:ascesa/features/support/data/services/support_socket_service.dart';
import 'package:ascesa/features/support/domain/entities/support_message.dart';
import 'package:ascesa/features/support/domain/entities/support_ticket.dart';
import 'package:ascesa/features/support/data/models/support_message_model.dart';
import 'package:ascesa/features/support/data/models/support_ticket_model.dart';

class SupportController extends ChangeNotifier {
  final SupportRepository repository;
  final SupportSocketService socketService;

  List<SupportMessage> _messages = [];
  SupportTicket? _ticket;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  int _unreadCount = 0;

  SupportController({
    required this.repository,
    required this.socketService,
  });

  List<SupportMessage> get messages => _messages;
  SupportTicket? get ticket => _ticket;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> init() async {
    if (_isLoading) return;
    
    debugPrint('[SupportController] Iniciar inicialização...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[SupportController] Buscando conversa...');
      final data = await repository.getConversation();
      _ticket = data['ticket'];
      _messages = data['messages'];
      debugPrint('[SupportController] Conversa carregada: ${_messages.length} mensagens');
      
      _connectSocket();
    } catch (e) {
      debugPrint('[SupportController] Erro na inicialização: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('[SupportController] Inicialização concluída');
    }
  }

  void _connectSocket() {
    socketService.connect(
      onMessageCreated: (message) {
        _messages.add(message);
        if (message.sender.type == SupportSenderType.admin) {
           _unreadCount++;
        }
        notifyListeners();
      },
      onTicketUpsert: (ticket) {
        _ticket = ticket;
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _isSending = true;
    notifyListeners();

    try {
      final data = await repository.sendMessage(content);
      // O socket já vai emitir a mensagem que acabamos de enviar, 
      // mas podemos adicionar localmente para feedback mais rápido se quisermos.
      // Aqui, o backend resolve.
      _ticket = data['ticket'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void markAsRead() {
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose();
  }

  Map<String, List<SupportMessage>> get groupedMessages {
    final Map<String, List<SupportMessage>> groups = {};
    final now = DateTime.now();

    for (var msg in _messages) {
      final date = msg.createdAt;
      String label;
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        label = 'Hoje';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        label = 'Ontem';
      } else {
        label = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      }

      if (!groups.containsKey(label)) {
        groups[label] = [];
      }
      groups[label]!.add(msg);
    }
    return groups;
  }
}
