# 🔄 Supabase Veritabanı Sıfırlama Kılavuzu

## 📋 Genel Bakış

Bu rehber, Ayakkabı Kataloğu uygulamasının Supabase veritabanını **tamamen sıfırlayıp yeniden kurma** işlemini açıklar.

## 🎯 Yapılacaklar

1. ✅ Tüm mevcut veriler temizlendi
2. ✅ RLS politikaları kapatıldı (development için)
3. ✅ Tüm veriler doğru path'lerle eklendi
4. ✅ Foreign key ilişkileri kontrol edildi
5. ✅ Asset path'leri fiziksel dosyalarla eşleştirildi

## 📊 Veri Özeti

### Tablolar ve Kayıt Sayıları

| Tablo | Kayıt Sayısı | Açıklama |
|-------|--------------|----------|
| **genders** | 3 | Kadın, Erkek, Çocuk |
| **categories** | 8 | 4 aktif (Spor, Bebe, Patik, Filet), 4 pasif |
| **brands** | 8 | Nike, Adidas, Puma, Converse, vb. |
| **colors** | 10 | Beyaz, Siyah, Kırmızı, Mavi, vb. |
| **products** | 44 | Tümü aktif |
| **product_images** | 44 | Her ürün için 1 görsel |
| **carousel_slides** | 4 | Ana sayfa carousel |
| **explore_sections** | 5 | Ana sayfa keşfet bölümü |
| **gender_categories** | 5 | Cinsiyet-kategori ilişkileri |

### Ürün Dağılımı

#### Cinsiyete Göre
- 👩 **Kadın**: 19 ürün
  - Nike Air Force 1 (6 renk)
  - Converse Chuck Taylor (2 renk)
  - Converse One Star (2 renk)
  - Puma RS-X 36-40 (3 renk)
  - Puma RS-X 40-44 (3 renk)
  - Adidas Superstar (3 renk)

- 👨 **Erkek**: 19 ürün
  - Nike Air Force 1 (6 renk)
  - Converse Chuck Taylor (2 renk)
  - Converse One Star (2 renk)
  - Puma RS-X 36-40 (3 renk)
  - Puma RS-X 40-44 (3 renk)
  - Adidas Superstar (3 renk)

- 👶 **Çocuk**: 6 ürün
  - Adidas Labubu Bebe (2 renk: mavi, siyah)
  - Adidas Labubu Patik (2 renk: mavi, siyah)
  - Adidas Labubu Filet (2 renk: mavi, siyah)

#### Markaya Göre
- **Nike**: 12 ürün
- **Adidas**: 12 ürün
- **Puma**: 12 ürün
- **Converse**: 8 ürün

## 🚀 Kurulum Adımları

### 1. Supabase Dashboard'a Giriş
1. [https://supabase.com/dashboard](https://supabase.com/dashboard) adresine gidin
2. Projenizi seçin: `rrmlbqhykyimojfblojy`

### 2. SQL Editor'ü Açın
1. Sol menüden **SQL Editor** seçeneğine tıklayın
2. **+ New query** butonuna tıklayın

### 3. Script'i Çalıştırın
1. `supabase_complete_reset.sql` dosyasını açın
2. **Tüm içeriği kopyalayın** (Ctrl+A, Ctrl+C)
3. SQL Editor'e yapıştırın (Ctrl+V)
4. **RUN** butonuna tıklayın (veya Ctrl+Enter)

### 4. Sonuçları Kontrol Edin
Script çalıştıktan sonra en altta 3 tablo göreceksiniz:

#### Tablo 1: Genel İstatistikler
```
tablo                          | kayit_sayisi
-------------------------------|-------------
Cinsiyetler                    | 3
Kategoriler                    | 8
Markalar                       | 8
Renkler                        | 10
Ürünler (Toplam)               | 44
Ürünler (Aktif)                | 44
Ürün Görselleri                | 44
Carousel Slides                | 4
Explore Sections               | 5
Gender-Category İlişkileri     | 5
```

#### Tablo 2: Cinsiyet Bazında Ürün Dağılımı
```
cinsiyet | urun_sayisi
---------|------------
Kadın    | 19
Erkek    | 19
Çocuk    | 6
```

#### Tablo 3: Marka Bazında Ürün Dağılımı
```
marka      | urun_sayisi
-----------|------------
Adidas     | 12
Nike       | 12
Puma       | 12
Converse   | 8
```

## ✅ Doğrulama

### Manuel Kontrol
SQL Editor'de şu sorguları çalıştırabilirsiniz:

```sql
-- RLS durumunu kontrol et
SELECT schemaname, tablename, rowsecurity
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Politikaları kontrol et
SELECT tablename, policyname, cmd, permissive
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Kadın Spor ayakkabılarını göster
SELECT p.name, b.name as brand, c.name as color, p.size_range
FROM products p
JOIN brands b ON p.brand_id = b.id
JOIN colors c ON p.color_id = c.id
JOIN genders g ON p.gender_id = g.id
WHERE g.slug = 'kadin' AND p.is_active = true
ORDER BY b.name, c.name;

-- Çocuk ürünlerini göster
SELECT p.name, cat.name as category, c.name as color
FROM products p
JOIN categories cat ON p.category_id = cat.id
JOIN colors c ON p.color_id = c.id
JOIN genders g ON p.gender_id = g.id
WHERE g.slug = 'cocuk' AND p.is_active = true
ORDER BY cat.name, c.name;

-- Görsel path'lerini kontrol et
SELECT p.name, pi.image_url
FROM products p
JOIN product_images pi ON p.id = pi.product_id
WHERE p.is_active = true
ORDER BY p.name;
```

## 📝 Önemli Notlar

### Image Path Formatı
Veritabanındaki `image_url` alanları:
```
kadin/spor/nike_airforce1_36-40/beyaz.jpg
```

Uygulama tarafında `assets/images/` ön eki eklenir:
```dart
// shoe_model.dart içinde
static String _toAssetPath(String path) {
  if (path.startsWith('http')) return path;
  if (path.startsWith('assets/')) return path;
  if (path.isEmpty) return '';
  return 'assets/images/$path';
}
```

Final path:
```
assets/images/kadin/spor/nike_airforce1_36-40/beyaz.jpg
```

### RLS (Row Level Security)
Production için **aktifleştirildi** ve şu politikalar uygulandı:

**Okuma (SELECT) İzinleri:**
```sql
-- Herkes aktif kayıtları okuyabilir (anon, authenticated)
CREATE POLICY "Public read access" ON products
  FOR SELECT USING (is_active = true);
```

**Yazma (INSERT/UPDATE/DELETE) İzinleri:**
```sql
-- Şimdilik kapalı - Auth ekleyince aktif edilecek
-- CREATE POLICY "Admin write access" ON products
--   FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
```

**İleride Auth eklenince:**
1. `supabase_admin_setup.sql` script'ini çalıştırın
2. Supabase Dashboard > Authentication'ı aktifleştirin
3. İlk admin kullanıcısını oluşturun:
   - Email: `admin@yourdomain.com`
   - User Metadata: `{"role": "admin"}`
4. Admin yazma politikaları otomatik aktif olur

**Şu anki güvenlik:**
- ✅ Herkes sadece `is_active=true` kayıtları görebilir
- ✅ Kimse veri ekleyemez/değiştiremez/silemez (RLS aktif, yazma politikası yok)
- ✅ Supabase API keys ile kontrol
- ⏳ Admin panel için auth eklenecek

### Veri Tutarlılığı
- ✅ Tüm `product_images` kayıtları mevcut ürünlere bağlı
- ✅ Tüm `products` kayıtları mevcut gender, category, brand, color'a bağlı
- ✅ Tüm `gender_categories` kayıtları mevcut cinsiyet ve kategorilere bağlı
- ✅ Foreign key constraints aktif
- ✅ `is_active = true` olmayan kayıt yok

## 🔍 Sorun Giderme

### Problem: Script hata veriyor
**Çözüm**: Script'i satır satır çalıştırın. Her `DELETE` komutundan sonra bekleyin.

### Problem: Ürünler uygulamada görünmüyor
**Çözüm 1**: Flutter'ı yeniden başlatın
```bash
flutter run -d chrome
```

**Çözüm 2**: DataProvider'ı yeniden yükleyin (uygulama içinde pull-to-refresh)

**Çözüm 3**: Browser cache'ini temizleyin
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Problem: Görseller yüklenmiyor
**Kontrol 1**: Fiziksel dosyaların varlığını kontrol edin
```bash
dir assets\images\kadin\spor\nike_airforce1_36-40\
```

**Kontrol 2**: Database path'lerini kontrol edin
```sql
SELECT image_url FROM product_images LIMIT 5;
```

**Kontrol 3**: `pubspec.yaml`'da asset tanımlarını kontrol edin
```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/kadin/
    - assets/images/erkek/
    - assets/images/cocuk/
```

## 🎉 Tamamlandı!

Artık veritabanınız:
- ✅ Temiz ve tutarlı
- ✅ Fiziksel dosyalarla uyumlu
- ✅ Foreign key ilişkileri doğru
- ✅ is_active filtreleri çalışıyor
- ✅ 44 ürün, 44 görsel, tümü aktif
- 🔒 **RLS güvenliği aktif** - Sadece okuma izni var
- 🔒 Yazma işlemleri için admin auth gerekli (ileride)

## 📚 Ek Dosyalar

- **[supabase_admin_setup.sql](supabase_admin_setup.sql)**: Admin yetkilendirme ve yazma politikaları (auth eklenince kullanın)

Uygulamanızı çalıştırıp test edebilirsiniz! 🚀
