class ApiConstants {
  // Use http://10.0.2.2:5000 para Android Emulator
  // Use http://localhost:5000 para iOS ou Web
  static const String baseUrl = 'https://api.ascesa.com.br';
  static const String loginEndpoint = '/auth/login';
  static const String updateUserEndpoint = '/users/me';
  static const String updatePasswordEndpoint = '/users/me/password';
  static const String registerEndpoint = '/auth/register';
  static const String categoriesEndpoint = '/allya/categories';
  static const String publicInfoEndpoint = '/allya/public-info';
  static const String publicInfoMapEndpoint = '/allya/public-info/map';
  static const String newsEndpoint = '/news';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String dependentsEndpoint = '/dependents';
  static const String supportConversationEndpoint = '/support-chat/my-conversation';
  static const String supportMessageEndpoint = '/support-chat/messages';
  static const String supportUnreadCountEndpoint = '/support-chat/my-conversation/unread-count';
  static const String supportMarkAsReadEndpoint = '/support-chat/my-conversation/read';
  static const String faqEndpoint = '/faq';
  static const String vitrineEndpoint = '/virtual-showcase';
  static const String blogEndpoint = '/blogs';

  static String partnerAccessEndpoint(String partnerId) =>

      '/allya/partners/$partnerId/access';
}
