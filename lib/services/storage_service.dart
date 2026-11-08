import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

class UploadedPhoto {
  const UploadedPhoto({required this.url, required this.path});

  final String url;

  /// Provider-specific identifier for the stored file.
  final String path;
}

class PhotoUploadException implements Exception {
  const PhotoUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class StorageService {
  Future<UploadedPhoto> uploadIncidentPhoto({
    required String uid,
    required String incidentId,
    required File file,
  });

  Future<void> deleteByPath(String path);
}

/// Stores incident photos on Cloudinary using an unsigned upload preset.
///
/// Unsigned presets let the app upload without shipping an API secret. The
/// trade-off is that the client cannot delete images, so removed reports
/// leave their photo behind; these can be cleaned up from the Cloudinary
/// Media Library.
class CloudinaryStorageService implements StorageService {
  CloudinaryStorageService({http.Client? client})
      : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 60);

  final http.Client _client;

  Uri get _endpoint => Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload');

  @override
  Future<UploadedPhoto> uploadIncidentPhoto({
    required String uid,
    required String incidentId,
    required File file,
  }) async {
    final request = http.MultipartRequest('POST', _endpoint)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = '${CloudinaryConfig.folder}/$uid'
      ..fields['public_id'] = incidentId
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await _client.send(request).timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw PhotoUploadException(
        'Photo upload failed (${response.statusCode}).',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['secure_url'] as String?;
    final publicId = body['public_id'] as String?;
    if (url == null || publicId == null) {
      throw const PhotoUploadException('Photo upload returned no URL.');
    }
    return UploadedPhoto(url: url, path: publicId);
  }

  @override
  Future<void> deleteByPath(String path) async {
    // Deleting requires a signed request with the API secret, which must
    // never be bundled in a mobile app. See the class comment.
  }
}
