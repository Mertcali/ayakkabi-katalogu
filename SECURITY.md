# 🔒 GÜVENLIK REHBERİ

## ⚠️ ACİL: Eski Credentials'ı Rotate Edin!

Supabase credentials daha önce public repo'da açıktı. Güvenlik için **MUTLAKA** şunları yapın:

### 1. Supabase Anon Key'i Yenileyin

1. https://supabase.com/dashboard adresine gidin
2. Projenizi seçin: `rrmlbqhykyimojfblojy`
3. **Settings** → **API** → **Reset** butonuna tıklayın
4. Yeni **anon key**'i kopyalayın
5. `.env` dosyasındaki `SUPABASE_ANON_KEY` değerini yeni key ile değiştirin

### 2. RLS (Row Level Security) Aktif Edin

RLS kapalı olduğu için herkes database'e yazabilir! Acilen aktifleştirin:

```bash
# supabase_enable_rls_security.sql dosyasını Supabase SQL Editor'de çalıştırın
```

Bu script:
- ✅ Tüm tablolar için RLS'i aktifleştirir
- ✅ Public okuma izni verir (herkes okur, kimse yazmaz)
- ✅ Admin panel için sonra özel politika ekleyebilirsiniz

### 3. Git History'den Credentials'ı Silin (Opsiyonel ama Önerilen)

#### Yöntem 1: BFG Repo-Cleaner (Önerilen)
```bash
# BFG'yi indirin: https://rtyley.github.io/bfg-repo-cleaner/
java -jar bfg.jar --replace-text passwords.txt

# passwords.txt içeriği:
# rrmlbqhykyimojfblojy.supabase.co==>REMOVED
# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...==>REMOVED

git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

#### Yöntem 2: Yeni Repo (En Kolay)
```bash
# 1. Yeni private repo oluşturun
# 2. Mevcut kodu (history olmadan) yeni repo'ya pushlayın
cd Ayakkabi_katalogu-main
rm -rf .git
git init
git add .
git commit -m "Initial commit with secure setup"
git remote add origin <yeni-repo-url>
git push -u origin main
```

## 📋 Güncel Güvenlik Durumu

### ✅ Düzeltildi:
- [x] `.env` dosyası oluşturuldu
- [x] Credentials `.env`'e taşındı
- [x] `.env` gitignore'da (commit edilmez)
- [x] `.env.example` template oluşturuldu
- [x] `flutter_dotenv` paketi eklendi
- [x] Kod `dotenv`'den okuyacak şekilde güncellendi
- [x] RLS setup script hazırlandı

### ⚠️ Yapılması Gereken:
- [ ] Supabase anon key rotate edilmeli
- [ ] RLS aktifleştirilmeli (`supabase_enable_rls_security.sql`)
- [ ] Git history temizlenmeli (veya yeni repo)
- [ ] Repo **private** yapılmalı (veya en azından RLS aktif olmalı)

## 🔐 Gelecek İçin Best Practices

1. **Asla credentials'ı commit etmeyin**
   - `.env` dosyasını kullanın
   - `.env.example` ile template paylaşın

2. **RLS her zaman aktif olmalı**
   - Public data için okuma izni
   - Admin için özel politikalar

3. **Repo private tutun**
   - Public repo için RLS şart
   - Private repo daha güvenli

4. **Regular security audits**
   - Supabase dashboard'u kontrol edin
   - Anormal activity takip edin

5. **Credentials rotation**
   - 6 ayda bir key'leri yenileyin
   - Şüpheli durumlarda hemen rotate edin

## 📞 Acil Durum

Eğer database'e yetkisiz erişim tespit ederseniz:

1. **Hemen** Supabase'de API key'leri reset edin
2. RLS'i aktifleştirin
3. Şüpheli kayıtları kontrol edin
4. Gerekirse database'i backup'tan geri yükleyin

## 🎯 Sonraki Adımlar

1. `flutter pub get` - Yeni paketi yükleyin
2. `.env` dosyasını kontrol edin
3. `flutter run` - Test edin
4. Supabase'de key rotate edin
5. `supabase_enable_rls_security.sql` çalıştırın
6. Git history temizleyin
7. Yeni commit: "feat: secure credentials with dotenv and enable RLS"
