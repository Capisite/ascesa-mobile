class ApiConstants {
  // Use http://10.0.2.2:5000 para Android Emulator
  // Use http://localhost:5000 para iOS ou Web
  static const String baseUrl = 'https://ascesa-back.onrender.com';
  static const String loginEndpoint = '/auth/login';
  static const String updateUserEndpoint = '/users/me';
  static const String registerEndpoint = '/auth/register';
  static const String categoriesEndpoint = '/allya/categories';
  static const String partnersEndpoint = '/allya/partners';
  static const String newsEndpoint = '/news';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String dependentsEndpoint = '/dependents';
  static const String supportConversationEndpoint = '/support-chat/my-conversation';
  static const String supportMessageEndpoint = '/support-chat/messages';
  static const String faqEndpoint = '/faq';
  static const String vitrineEndpoint = '/virtual-showcase';

  static String partnerAccessEndpoint(String partnerId) =>
      '/allya/partners/$partnerId/access';
}
