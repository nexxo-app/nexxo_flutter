// Story Image Generation Service
// Captures a Flutter widget as an image for sharing on social media

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Service to generate and share story images
class StoryImageService {
  static StoryImageService? _instance;

  StoryImageService._();

  static StoryImageService get instance {
    _instance ??= StoryImageService._();
    return _instance!;
  }

  /// Capture a widget as an image using RepaintBoundary
  Future<Uint8List?> captureWidget(GlobalKey repaintBoundaryKey) async {
    try {
      final RenderRepaintBoundary? boundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        _debugPrint('RenderRepaintBoundary not found');
        return null;
      }

      // Wait for the boundary to be painted
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture at 3x for high quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        _debugPrint('Failed to convert image to bytes');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      _debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Share image using Web Share API
  Future<bool> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    required String title,
    required String text,
  }) async {
    if (!kIsWeb) return false;

    try {
      // Create a Blob from the image bytes
      final jsArray = imageBytes.toJS;
      final blob = web.Blob(
        [jsArray].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );

      // Create a File from the Blob
      final file = web.File(
        [blob].toJS,
        fileName,
        web.FilePropertyBag(type: 'image/png'),
      );

      // Check if sharing files is supported
      final shareData = JSObject();
      shareData['files'] = [file].toJS;
      shareData['title'] = title.toJS;
      shareData['text'] = text.toJS;

      final navigator = web.window.navigator;

      // Try to share with files
      try {
        await navigator.share(shareData as web.ShareData).toDart;
        return true;
      } catch (e) {
        // If file sharing fails, try downloading the image instead
        _debugPrint('File sharing not supported, downloading image: $e');
        await _downloadImage(imageBytes, fileName);
        return true;
      }
    } catch (e) {
      _debugPrint('Error sharing image: $e');
      return false;
    }
  }

  /// Download image as fallback
  Future<void> _downloadImage(Uint8List imageBytes, String fileName) async {
    if (!kIsWeb) return;

    try {
      // Create blob URL
      final jsArray = imageBytes.toJS;
      final blob = web.Blob(
        [jsArray].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );

      final url = web.URL.createObjectURL(blob);

      // Create download link
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      anchor.click();

      // Cleanup
      web.URL.revokeObjectURL(url);
    } catch (e) {
      _debugPrint('Error downloading image: $e');
    }
  }
}

void _debugPrint(String message) {
  if (kIsWeb) {
    // ignore: avoid_print
    print('[StoryImageService] $message');
  }
}
