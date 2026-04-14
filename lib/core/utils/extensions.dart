import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String extension'lari
extension StringExtension on String {
  /// Ilk harfi buyuk yapar
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Bos veya null kontrolu
  bool get isNullOrEmpty => isEmpty;

  /// Gecerli email mi
  bool get isValidEmail =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
}

/// String? extension'lari
extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

/// DateTime extension'lari
extension DateTimeExtension on DateTime {
  /// "14 Nis 2026" formatinda
  String get formatted => DateFormat('dd MMM yyyy', 'tr_TR').format(this);

  /// "14 Nis 2026, 09:30" formatinda
  String get formattedWithTime =>
      DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(this);

  /// "2 saat önce", "3 gün önce" gibi relatif format
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} hafta önce';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ay önce';
    return '${(diff.inDays / 365).floor()} yıl önce';
  }

  /// Bugun mu
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

/// BuildContext extension'lari
extension ContextExtension on BuildContext {
  /// Tema kisa yollari
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Ekran boyutlari
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// Karanlik tema mi
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// SnackBar goster
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Num extension'lari
extension NumExtension on num {
  /// SizedBox height kisa yolu
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// SizedBox width kisa yolu
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}
