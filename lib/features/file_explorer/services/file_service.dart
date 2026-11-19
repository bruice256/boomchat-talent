import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

enum FileCategory {
  pdf,
  word,
  presentation,
  excel,
  image,
  video,
  audio,
  text,
  archive,
  other,
  directory,
}

class FileItem {
  final FileSystemEntity entity;
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modified;
  final FileCategory category;

  FileItem({
    required this.entity,
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modified,
    required this.category,
  });

  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy HH:mm').format(modified);
  }
}

class FileService {
  static const String androidInternalStorageRoot = '/storage/emulated/0';

  static Future<String> getInitialDirectoryPath() async {
    final rootDir = Directory(androidInternalStorageRoot);
    if (await rootDir.exists()) {
      return androidInternalStorageRoot;
    }
    final docDir = await getApplicationDocumentsDirectory();
    return docDir.path;
  }

  static FileCategory categorizeFile(String path, bool isDir) {
    if (isDir) return FileCategory.directory;
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return FileCategory.pdf;
      case 'doc':
      case 'docx':
        return FileCategory.word;
      case 'ppt':
      case 'pptx':
        return FileCategory.presentation;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return FileCategory.excel;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
      case 'svg':
        return FileCategory.image;
      case 'mp4':
      case 'mkv':
      case 'avi':
      case 'mov':
      case '3gp':
      case 'webm':
        return FileCategory.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'm4a':
      case 'ogg':
      case 'flac':
        return FileCategory.audio;
      case 'txt':
      case 'md':
      case 'json':
      case 'xml':
      case 'html':
      case 'dart':
      case 'kt':
      case 'java':
        return FileCategory.text;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return FileCategory.archive;
      default:
        return FileCategory.other;
    }
  }

  static Future<List<FileItem>> listDirectory(String dirPath, {bool showHidden = false}) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];

    try {
      final List<FileSystemEntity> entities = await dir.list().toList();
      final List<FileItem> items = [];

      for (var entity in entities) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (!showHidden && name.startsWith('.')) continue;

        final isDir = entity is Directory;
        int size = 0;
        DateTime modified = DateTime.now();

        try {
          final stat = await entity.stat();
          size = stat.size;
          modified = stat.modified;
        } catch (_) {}

        items.add(FileItem(
          entity: entity,
          name: name,
          path: entity.path,
          isDirectory: isDir,
          size: size,
          modified: modified,
          category: categorizeFile(entity.path, isDir),
        ));
      }

      // Sort: folders first, then alphabetical
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return items;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> deleteEntity(FileSystemEntity entity) async {
    try {
      if (entity is Directory) {
        await entity.delete(recursive: true);
      } else {
        await entity.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> renameEntity(FileSystemEntity entity, String newName) async {
    try {
      final parent = entity.parent.path;
      final newPath = '$parent${Platform.pathSeparator}$newName';
      await entity.rename(newPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
