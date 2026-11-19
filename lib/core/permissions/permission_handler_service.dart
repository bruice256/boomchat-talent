import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  static Future<Map<Permission, PermissionStatus>> requestAllAppPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.contacts,
      Permission.phone,
      Permission.notification,
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses;
  }

  static Future<bool> hasCameraAndMicPermission() async {
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    return camera.isGranted && mic.isGranted;
  }

  static Future<bool> hasStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (await Permission.storage.isGranted) return true;
    final photos = await Permission.photos.isGranted;
    final videos = await Permission.videos.isGranted;
    final audio = await Permission.audio.isGranted;
    return photos || videos || audio;
  }

  static Future<bool> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) return true;
    if (await Permission.storage.request().isGranted) return true;
    return false;
  }
}
