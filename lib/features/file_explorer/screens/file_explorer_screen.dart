import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/file_service.dart';
import 'universal_file_viewer_screen.dart';
import '../../../core/permissions/permission_handler_service.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({Key? key}) : super(key: key);

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  String _currentPath = FileService.androidInternalStorageRoot;
  List<FileItem> _items = [];
  bool _isLoading = true;
  bool _showHidden = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoad();
  }

  void _checkPermissionsAndLoad() async {
    final hasPerm = await PermissionHandlerService.hasStoragePermission();
    if (!hasPerm) {
      await PermissionHandlerService.requestStoragePermission();
    }
    final initialPath = await FileService.getInitialDirectoryPath();
    setState(() => _currentPath = initialPath);
    _loadDirectory(initialPath);
  }

  void _loadDirectory(String path) async {
    setState(() => _isLoading = true);
    final items = await FileService.listDirectory(path, showHidden: _showHidden);
    if (mounted) {
      setState(() {
        _currentPath = path;
        _items = items;
        _isLoading = false;
      });
    }
  }

  IconData _getIconForCategory(FileCategory cat) {
    switch (cat) {
      case FileCategory.directory:
        return Icons.folder_rounded;
      case FileCategory.pdf:
        return Icons.picture_as_pdf;
      case FileCategory.word:
        return Icons.description;
      case FileCategory.presentation:
        return Icons.slideshow;
      case FileCategory.excel:
        return Icons.table_chart;
      case FileCategory.image:
        return Icons.image;
      case FileCategory.video:
        return Icons.video_file;
      case FileCategory.audio:
        return Icons.audio_file;
      case FileCategory.text:
        return Icons.article;
      case FileCategory.archive:
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getColorForCategory(FileCategory cat) {
    switch (cat) {
      case FileCategory.directory:
        return AppTheme.primaryGold;
      case FileCategory.pdf:
        return Colors.redAccent;
      case FileCategory.word:
        return Colors.blueAccent;
      case FileCategory.presentation:
        return Colors.orangeAccent;
      case FileCategory.excel:
        return Colors.greenAccent;
      case FileCategory.image:
        return Colors.purpleAccent;
      case FileCategory.video:
        return Colors.pinkAccent;
      case FileCategory.audio:
        return Colors.cyanAccent;
      default:
        return Colors.grey;
    }
  }

  void _navigateUp() {
    final parent = Directory(_currentPath).parent;
    if (parent.path != _currentPath && parent.path.startsWith('/storage/emulated/0') || parent.path == '/storage/emulated/0') {
      _loadDirectory(parent.path);
    }
  }

  void _showFileOptions(FileItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(_getIconForCategory(item.category), color: _getColorForCategory(item.category)),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item.formattedSize} • ${item.formattedDate}'),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.remove_red_eye, color: AppTheme.primaryGold),
                title: const Text('Open & View File'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UniversalFileViewerScreen(fileItem: item)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline, color: Colors.blueAccent),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(ctx);
                  _renameItem(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteItem(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _renameItem(FileItem item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'New Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await FileService.renameEntity(item.entity, controller.text.trim());
              if (success) _loadDirectory(_currentPath);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(FileItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await FileService.deleteEntity(item.entity);
              if (success) _loadDirectory(_currentPath);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((i) {
      if (_searchQuery.isEmpty) return true;
      return i.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final canGoBack = _currentPath != FileService.androidInternalStorageRoot &&
        _currentPath != Directory(FileService.androidInternalStorageRoot).parent.path;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search internal storage...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('Storage & Universal Viewer'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            color: AppTheme.darkSurface,
            onSelected: (val) {
              if (val == 'hidden') {
                setState(() => _showHidden = !_showHidden);
                _loadDirectory(_currentPath);
              } else if (val == 'refresh') {
                _loadDirectory(_currentPath);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'hidden',
                child: Row(
                  children: [
                    Icon(_showHidden ? Icons.visibility : Icons.visibility_off, size: 18),
                    const SizedBox(width: 8),
                    Text(_showHidden ? 'Hide Hidden Files' : 'Show Hidden Files'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    const SizedBox(width: 8),
                    Text('Refresh Folder'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Path breadcrumb bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.darkSurface,
            child: Row(
              children: [
                if (canGoBack)
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, size: 20, color: AppTheme.primaryGold),
                    onPressed: _navigateUp,
                    tooltip: 'Up one directory',
                  ),
                Expanded(
                  child: Text(
                    _currentPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_open, size: 64, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            const Text('No files found in this folder.', style: TextStyle(color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            Text(
                              'Powered by ${AppCredentials.appName}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                        itemBuilder: (ctx, idx) {
                          final item = filtered[idx];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.darkCard,
                              child: Icon(
                                _getIconForCategory(item.category),
                                color: _getColorForCategory(item.category),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              item.isDirectory ? 'Folder' : '${item.formattedSize} • ${item.formattedDate}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                            trailing: item.isDirectory
                                ? const Icon(Icons.chevron_right, color: AppTheme.textMuted)
                                : IconButton(
                                    icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
                                    onPressed: () => _showFileOptions(item),
                                  ),
                            onTap: () {
                              if (item.isDirectory) {
                                _loadDirectory(item.path);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UniversalFileViewerScreen(fileItem: item),
                                  ),
                                );
                              }
                            },
                            onLongPress: () => _showFileOptions(item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
