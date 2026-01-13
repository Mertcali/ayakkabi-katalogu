import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase yapılandırma dosyası
/// Değerler .env dosyasından okunur (GÜVENLİ)
///
/// Kurulum:
/// 1. .env.example dosyasını kopyalayın ve .env olarak kaydedin
/// 2. Kendi Supabase bilgilerinizi .env dosyasına yazın
/// 3. .env dosyası asla git'e commit edilmez (.gitignore'da)

class SupabaseConfig {
  // Supabase Project URL
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  // Supabase Anon Key (public)
  // Bu anahtar client-side kullanım için güvenlidir (RLS ile korunur)
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Storage bucket adı (görseller için)
  static String get storageBucket =>
      dotenv.env['SUPABASE_STORAGE_BUCKET'] ?? 'product-images';

  // Varsayılan görsel URL'leri için base path
  static String get storageUrl =>
      '$supabaseUrl/storage/v1/object/public/$storageBucket';
}
