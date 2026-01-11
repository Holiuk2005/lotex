import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AuctionImagesStorageService {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  AuctionImagesStorageService({FirebaseStorage? storage, Uuid? uuid})
      : _storage = storage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  /// Uploads images to: auction_images/{auctionId}/{imageId}
  /// Returns download URLs in the same order as [files].
  ///
  /// Behavior: if any upload fails, already uploaded files are deleted
  /// and the error is rethrown.
  Future<List<String>> uploadAuctionImages({
    required String auctionId,
    required List<XFile> files,
  }) async {
    if (auctionId.trim().isEmpty) {
      throw ArgumentError.value(auctionId, 'auctionId', 'Must not be empty');
    }
    if (files.isEmpty) return const [];

    final uploadedRefs = <Reference>[];
    try {
      final urls = <String>[];

      for (final file in files) {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          throw StateError('Empty file: ${file.name}');
        }

        final imageId = _uuid.v4();
        final ref = _storage.ref().child('auction_images/$auctionId/$imageId');
        uploadedRefs.add(ref);

        final metadata =
            SettableMetadata(contentType: _guessContentType(file, bytes));
        await ref.putData(bytes, metadata);
        final url = await ref.getDownloadURL();
        urls.add(url);
      }

      return List.unmodifiable(urls);
    } catch (_) {
      // Best-effort cleanup.
      await Future.wait(
        uploadedRefs.map((r) async {
          try {
            await r.delete();
          } catch (_) {}
        }),
      );
      rethrow;
    }
  }

  String _guessContentType(XFile file, Uint8List bytes) {
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';

    // Magic numbers (best-effort)
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }
}
