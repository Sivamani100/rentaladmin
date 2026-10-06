class Env {
  static const String openRouterApiKey =
      String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
      
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
      
  static const String googleMapsApiKey2 =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY_2', defaultValue: '');
}
