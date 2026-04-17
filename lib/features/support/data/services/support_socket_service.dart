import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/features/support/data/models/support_message_model.dart';
import 'package:ascesa/features/support/data/models/support_ticket_model.dart';

class SupportSocketService {
  io.Socket? _socket;
  final String token;

  SupportSocketService({required this.token});

  void connect({
    Function(SupportMessageModel)? onMessageCreated,
    Function(SupportTicketModel)? onTicketUpsert,
  }) {
    // Retira o trailing slash e adiciona o namespace
    final baseUrl = ApiConstants.baseUrl.replaceAll(RegExp(r'/$'), '');
    
    _socket = io.io('$baseUrl/support-chat', {
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket!.connect();

    _socket!.onConnect((_) => print('Connected to support-chat socket'));
    _socket!.onDisconnect((_) => print('Disconnected from support-chat socket'));

    if (onMessageCreated != null) {
      _socket!.on('support:message-created', (data) {
        if (data != null && data['message'] != null) {
          onMessageCreated(SupportMessageModel.fromJson(data['message']));
        }
      });
    }

    if (onTicketUpsert != null) {
      _socket!.on('support:ticket-upsert', (data) {
        if (data != null) {
          onTicketUpsert(SupportTicketModel.fromJson(data));
        }
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  bool get isConnected => _socket?.connected ?? false;
}
