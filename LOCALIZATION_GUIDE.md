# Panduan Lokalisasi dan Pengaturan Tema

## 📱 Fitur yang Tersedia

### 1. Multi-Bahasa (Localization)

Aplikasi mendukung 2 bahasa:

- 🇮🇩 **Bahasa Indonesia** (default)
- 🇬🇧 **English**

### 2. Tema (Theme)

Aplikasi mendukung 3 mode tema:

- 🌐 **System** - Mengikuti pengaturan sistem
- ☀️ **Light** - Tema terang
- 🌙 **Dark** - Tema gelap

## 💾 Penyimpanan Pengaturan

### Cara Kerja

Aplikasi menggunakan **SharedPreferences** untuk menyimpan pengaturan pengguna secara permanen di perangkat.

#### Lokasi Penyimpanan:

- **Tema**: Disimpan dengan key `'themeMode'` sebagai integer (0=System, 1=Light, 2=Dark)
- **Bahasa**: Disimpan dengan key `'language'` sebagai string ('id' atau 'en')

#### Proses Penyimpanan:

1. **Saat Aplikasi Dibuka:**

   ```dart
   Future<void> _loadSettings() async {
     final prefs = await SharedPreferences.getInstance();
     final themeIndex = prefs.getInt('themeMode') ?? 0;
     final language = prefs.getString('language') ?? 'id';

     setState(() {
       _themeMode = ThemeMode.values[themeIndex];
       _locale = Locale(language);
     });
   }
   ```

   - Settings dimuat **PERTAMA KALI** sebelum UI dirender
   - Jika tidak ada pengaturan tersimpan, gunakan default (Indonesian, System theme)

2. **Saat Pengguna Mengubah Tema:**

   ```dart
   Future<void> _saveThemeMode(ThemeMode mode) async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setInt('themeMode', mode.index);
     setState(() {
       _themeMode = mode;
     });
   }
   ```

   - Pengaturan langsung disimpan ke SharedPreferences
   - UI langsung diupdate dengan `setState()`

3. **Saat Pengguna Mengubah Bahasa:**
   ```dart
   Future<void> _saveLanguage(String language) async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setString('language', language);
     setState(() {
       _locale = Locale(language);
     });
   }
   ```

   - Pengaturan langsung disimpan ke SharedPreferences
   - UI langsung diupdate dengan `setState()`

## ✅ Jaminan Persistensi

### Pengaturan AKAN TERSIMPAN dan DIMUAT KEMBALI:

✅ Setelah aplikasi ditutup dan dibuka kembali
✅ Setelah restart perangkat
✅ Setelah update aplikasi (selama tidak uninstall)

### Pengaturan AKAN HILANG jika:

❌ Aplikasi di-uninstall
❌ Data aplikasi dihapus dari pengaturan sistem
❌ Clear app data/cache dari pengaturan sistem

## 🔄 Urutan Inisialisasi

```
1. main() → WidgetsFlutterBinding.ensureInitialized()
2. MyApp → initState()
3. _initApp()
   ├─ 3.1. _loadSettings() ← LOAD TEMA & BAHASA DARI STORAGE
   ├─ 3.2. _initCameras()
   └─ 3.3. setState({ _isLoading = false })
4. build() → Render UI dengan tema & bahasa yang tersimpan
```

## 🧪 Cara Testing

### Test Penyimpanan Tema:

1. Buka aplikasi (default: System theme)
2. Buka Settings → Ubah tema ke "Light"
3. **Tutup aplikasi sepenuhnya**
4. Buka aplikasi lagi
5. ✅ Tema harus tetap "Light"

### Test Penyimpanan Bahasa:

1. Buka aplikasi (default: Bahasa Indonesia)
2. Buka Settings → Ubah bahasa ke "English"
3. Verifikasi semua teks berubah ke English
4. **Tutup aplikasi sepenuhnya**
5. Buka aplikasi lagi
6. ✅ Bahasa harus tetap "English"

### Test Kombinasi:

1. Ubah tema ke "Dark" dan bahasa ke "English"
2. Tutup aplikasi
3. Buka aplikasi lagi
4. ✅ Tema tetap "Dark" DAN bahasa tetap "English"

## 📝 Catatan Teknis

### File yang Terlibat:

- `lib/main.dart` - Logika penyimpanan dan loading settings
- `lib/settings_screen.dart` - UI untuk mengubah settings
- `lib/l10n/app_en.arb` - Terjemahan bahasa Inggris
- `lib/l10n/app_id.arb` - Terjemahan bahasa Indonesia

### Dependencies:

```yaml
dependencies:
  shared_preferences: ^2.0.0 # Untuk penyimpanan lokal
  flutter_localizations: # Untuk multi-bahasa
    sdk: flutter
```

## 🎯 Kesimpulan

Sistem penyimpanan pengaturan sudah **BERFUNGSI DENGAN BAIK**:

- ✅ Tema tersimpan otomatis saat diubah
- ✅ Bahasa tersimpan otomatis saat diubah
- ✅ Settings dimuat saat aplikasi dibuka
- ✅ Settings persisten setelah aplikasi ditutup
- ✅ Tidak perlu action tambahan dari pengguna

**Pengaturan akan selalu kembali ke pilihan terakhir pengguna!** 🎉
