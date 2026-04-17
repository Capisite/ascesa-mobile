abstract class SupportRepository {
  Future<Map<String, dynamic>> getConversation({int page = 1, int limit = 50});
  Future<Map<String, dynamic>> sendMessage(String content);
}
