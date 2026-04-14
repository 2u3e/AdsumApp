import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Widget'i goruntu olarak yakalayip paylasim servisleri
class ShareService {
  ShareService._();

  /// RepaintBoundary'yi PNG olarak yakala
  /// [boundary] RepaintBoundary.currentContext.findRenderObject() ile alinir
  static Future<Uint8List?> captureWidget(RenderRepaintBoundary boundary,
      {double pixelRatio = 3.0}) async {
    try {
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// PNG bytes'i temp dizine kaydet
  static Future<File> saveTempImage(Uint8List bytes, {String name = 'adsum_rapor'}) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${name}_$timestamp.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Goruntuyu paylas (WhatsApp, Telegram, vs)
  static Future<ShareResult> shareImage(File imageFile, {String? text, String? subject}) async {
    return await Share.shareXFiles(
      [XFile(imageFile.path)],
      text: text,
      subject: subject,
    );
  }

  /// Tum akis: widget yakala + kaydet + paylas
  static Future<bool> captureAndShare(
    RenderRepaintBoundary boundary, {
    String? text,
    String? subject,
    String fileName = 'adsum_rapor',
  }) async {
    final bytes = await captureWidget(boundary);
    if (bytes == null) return false;

    final file = await saveTempImage(bytes, name: fileName);
    final result = await shareImage(file, text: text, subject: subject);

    return result.status == ShareResultStatus.success ||
        result.status == ShareResultStatus.dismissed;
  }
}
