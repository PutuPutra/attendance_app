// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Selamat Datang';

  @override
  String get attendance => 'Kehadiran';

  @override
  String get companyName => 'Masuk ke akun Anda';

  @override
  String get employee => 'Karyawan';

  @override
  String get attendanceRecord => 'Kehadiran';

  @override
  String get checkIn => 'Masuk';

  @override
  String get breakTime => 'Istirahat';

  @override
  String get returnToWork => 'Kembali';

  @override
  String get checkOut => 'Pulang';

  @override
  String get leave => 'Cuti';

  @override
  String get settings => 'Pengaturan';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get changePassword => 'Ubah Kata Sandi';

  @override
  String get faceSaved => 'Wajah Tersimpan';

  @override
  String get noFaceDataSaved => 'Tidak ada data wajah tersimpan.';

  @override
  String faceFeaturesCount(Object count) {
    return 'Fitur wajah: $count nilai';
  }

  @override
  String get getPersonalFaceData => 'Dapatkan Data Wajah Pribadi';

  @override
  String get clearAllFaceData => 'Hapus Semua Data Wajah';

  @override
  String get language => 'Bahasa';

  @override
  String get logout => 'Keluar';

  @override
  String get version => 'Versi 1.0.0';

  @override
  String get confirmLogout => 'Apakah Anda yakin ingin keluar?';

  @override
  String get cancel => 'Batal';

  @override
  String get ok => 'OK';

  @override
  String get delete => 'Hapus';

  @override
  String get confirmDelete =>
      'Apakah Anda yakin ingin menghapus semua data wajah?';

  @override
  String get dataDeleted => 'Data wajah telah dihapus.';

  @override
  String get notImplemented => 'Fitur ini belum diimplementasikan.';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Terang';

  @override
  String get darkTheme => 'Gelap';

  @override
  String get systemTheme => 'Sistem';

  @override
  String get attendanceHistory => 'Riwayat Kehadiran';

  @override
  String get liveAttendance => 'Kehadiran Langsung';

  @override
  String get officeHours => 'Jam Kerja';

  @override
  String get officeHoursTime => '08:00 - 17:00';

  @override
  String faceScanTitle(String type) {
    return 'Scan Wajah untuk $type';
  }

  @override
  String get pointCameraToFace => 'Arahkan kamera ke wajah Anda';

  @override
  String get noCameraAvailable => 'Tidak ada kamera tersedia.';

  @override
  String cameraInitFailed(String error) {
    return 'Gagal inisialisasi kamera: $error';
  }

  @override
  String faceDetectedSuccess(String type) {
    return 'Wajah terdeteksi! Proses $type berhasil.';
  }

  @override
  String get noFaceDetected => 'Tidak ada wajah terdeteksi. Coba lagi.';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get scanFace => 'Scan Wajah';

  @override
  String get faceDataSection => 'Data Wajah';

  @override
  String get getSelectedFaceData => 'Dapatkan Data Wajah Terpilih';

  @override
  String get personalizationSection => 'Personalisasi';

  @override
  String get themeLabel => 'Tema';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get generalSection => 'Umum';

  @override
  String get passwordOrBiometric => 'Masuk dengan biometrik';

  @override
  String get selectTheme => 'Pilih Tema';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get login => 'Masuk';

  @override
  String get username => 'Nama Pengguna';

  @override
  String get password => 'Kata Sandi';

  @override
  String get forgotPassword => 'Lupa Kata Sandi';

  @override
  String get oldPassword => 'Kata Sandi Lama';

  @override
  String get newPassword => 'Kata Sandi Baru';

  @override
  String get confirmNewPassword => 'Konfirmasi Kata Sandi Baru';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get passwordChangedSuccessfully => 'Kata sandi berhasil diubah';

  @override
  String get incorrectOldPassword => 'Kata sandi lama salah';

  @override
  String get pleaseEnterUsernameAndPassword =>
      'Silakan masukkan nama pengguna dan kata sandi';

  @override
  String get invalidUsernameOrPassword =>
      'Nama pengguna atau kata sandi tidak valid';

  @override
  String loginFailed(String error) {
    return 'Login gagal: $error';
  }

  @override
  String get userManagement => 'Manajemen Pengguna';

  @override
  String get manageUsers => 'Kelola Pengguna';

  @override
  String get deleteUser => 'Hapus Pengguna';

  @override
  String confirmDeleteUser(String username) {
    return 'Apakah Anda yakin ingin menghapus $username?';
  }

  @override
  String get editUser => 'Edit Pengguna';

  @override
  String get addUser => 'Tambah Pengguna';

  @override
  String get employeeId => 'ID Karyawan';

  @override
  String get email => 'Email';

  @override
  String get role => 'Peran';

  @override
  String get admin => 'Admin';

  @override
  String get karyawan => 'Karyawan';

  @override
  String get update => 'Perbarui';

  @override
  String get allEmployeeHistory => 'Riwayat Semua Karyawan';

  @override
  String get fontStyle => 'Gaya Font';

  @override
  String get systemFont => 'Sistem';

  @override
  String get appFont => 'Bawaan Aplikasi';

  @override
  String get selectDateRangeTitle =>
      'Pilih Rentang Waktu untuk Menampilkan Riwayat kehadiran';

  @override
  String get selectStartDate => 'Pilih Tanggal Mulai';

  @override
  String get selectEndDate => 'Pilih Tanggal Akhir';

  @override
  String get startLabel => 'Mulai: ';

  @override
  String get endLabel => 'Akhir: ';

  @override
  String get pleaseSelectBothDates => 'Silakan pilih tanggal mulai dan akhir';

  @override
  String get apply => 'Terapkan';

  @override
  String get lookStraight => 'Lihat lurus ke kamera';

  @override
  String get turnRight => 'Putar kepala ke kanan';

  @override
  String get turnLeft => 'Putar kepala ke kiri';

  @override
  String get lookDown => 'Lihat ke bawah';

  @override
  String get lookUp => 'Lihat ke atas';

  @override
  String get positionCorrect => 'Posisi benar, menangkap...';

  @override
  String get enterFaceName => 'Masukkan nama untuk wajah ini';

  @override
  String get faceName => 'Nama Wajah';

  @override
  String get save => 'Simpan';

  @override
  String belumWaktunya(String type) {
    return 'Belum waktunya untuk $type';
  }

  @override
  String get proceedAnyway => 'Lanjutkan Saja';
}
