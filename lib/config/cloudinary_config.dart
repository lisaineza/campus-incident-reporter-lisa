/// Cloudinary settings for incident photo uploads.
///
/// The upload preset must be an *unsigned* preset. These values are safe to
/// commit: an unsigned preset is designed to be used from client apps, and no
/// API key or secret is stored here.
class CloudinaryConfig {
  CloudinaryConfig._();

  static const cloudName = 'YOUR_CLOUD_NAME';
  static const uploadPreset = 'campus_incidents';
  static const folder = 'campus-incidents';
}
