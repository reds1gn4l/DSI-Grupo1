import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class UserPhotoService {
  static const _prefsKey = 'plant_user_photos';

  /// Returns the absolute path of the saved local photo for a plant, if any.
  Future<String?> getPhotoPath(String plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getStringList(_prefsKey) ?? const [];
    for (final entry in map) {
      final parts = entry.split('||');
      if (parts.length == 2 && parts[0] == plantId) {
        final path = parts[1];
        if (File(path).existsSync()) return path;
      }
    }
    return null;
  }

  /// Saves/copies [source] into the app documents folder and associates it with [plantId].
  Future<String> savePhotoForPlant(String plantId, File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/plant_photos');
    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }
    final filename = 'plant_${plantId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = File('${photosDir.path}/$filename');

    // Try to process (center-crop to 4:3 and resize), fallback to raw copy
    File saved;
    try {
      saved = await _processAndSave(source, dest);
    } catch (_) {
      saved = await source.copy(dest.path);
    }

    // persist mapping
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getStringList(_prefsKey) ?? [];
    // remove old mapping for this plant
    map.removeWhere((e) => e.startsWith('$plantId||'));
    map.add('$plantId||${saved.path}');
    await prefs.setStringList(_prefsKey, map);
    return saved.path;
  }

  /// Removes the mapping; does not delete the file by default.
  Future<void> removePhotoForPlant(String plantId, {bool deleteFile = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getStringList(_prefsKey) ?? [];
    String? path;
    map.removeWhere((e) {
      final hit = e.startsWith('$plantId||');
      if (hit) path = e.split('||').elementAtOrNull(1);
      return hit;
    });
    await prefs.setStringList(_prefsKey, map);
    if (deleteFile && path != null) {
      final f = File(path!);
      if (await f.exists()) {
        try { await f.delete(); } catch (_) {}
      }
    }
  }

  Future<File> _processAndSave(File source, File dest) async {
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return source.copy(dest.path);

    // Normalize orientation if available
    final oriented = img.bakeOrientation(decoded);

    // Center-crop to 4:3
    const targetAspect = 4 / 3;
    final w = oriented.width;
    final h = oriented.height;
    final currentAspect = w / h;
    int cropW = w;
    int cropH = h;
    int offsetX = 0;
    int offsetY = 0;
    if (currentAspect > targetAspect) {
      cropW = (h * targetAspect).round();
      offsetX = ((w - cropW) / 2).round();
    } else if (currentAspect < targetAspect) {
      cropH = (w / targetAspect).round();
      offsetY = ((h - cropH) / 2).round();
    }
    final cropped = img.copyCrop(oriented, x: offsetX, y: offsetY, width: cropW, height: cropH);

    // Resize to a reasonable width (max 1600)
    final targetW = min(1600, cropped.width);
    final resized = img.copyResize(cropped, width: targetW);

    final outBytes = img.encodeJpg(resized, quality: 85);
    await dest.writeAsBytes(outBytes, flush: true);
    return dest;
  }
}

extension _SafeIndex on List<String> {
  String? elementAtOrNull(int i) => (i >= 0 && i < length) ? this[i] : null;
}
