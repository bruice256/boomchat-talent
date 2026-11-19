import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as excel_pkg;
import '../../../core/theme/app_theme.dart';
import '../services/file_service.dart';

class UniversalFileViewerScreen extends StatefulWidget {
  final FileItem fileItem;

  const UniversalFileViewerScreen({Key? key, required this.fileItem}) : super(key: key);

  @override
  State<UniversalFileViewerScreen> createState() => _UniversalFileViewerScreenState();
}

class _UniversalFileViewerScreenState extends State<UniversalFileViewerScreen> {
  // Audio Player state
  AudioPlayer? _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlayingAudio = false;

  // Video Player state
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  // Text/Doc Content state
  String? _textContent;
  List<List<dynamic>>? _excelRows;
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    _initializeViewer();
  }

  void _initializeViewer() async {
    final cat = widget.fileItem.category;
    final file = File(widget.fileItem.path);

    if (cat == FileCategory.audio) {
      _audioPlayer = AudioPlayer();
      try {
        await _audioPlayer!.setFilePath(file.path);
        _audioPlayer!.positionStream.listen((p) {
          if (mounted) setState(() => _position = p);
        });
        _audioPlayer!.durationStream.listen((d) {
          if (mounted && d != null) setState(() => _duration = d);
        });
        _audioPlayer!.playerStateStream.listen((state) {
          if (mounted) setState(() => _isPlayingAudio = state.playing);
        });
      } catch (e) {
        debugPrint('Audio initialization error: $e');
      }
    } else if (cat == FileCategory.video) {
      _videoPlayerController = VideoPlayerController.file(file);
      try {
        await _videoPlayerController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppTheme.primaryGold,
            handleColor: AppTheme.primaryGold,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.white24,
          ),
        );
        if (mounted) setState(() => _isVideoInitialized = true);
      } catch (e) {
        debugPrint('Video initialization error: $e');
      }
    } else if (cat == FileCategory.excel) {
      setState(() => _isLoadingContent = true);
      try {
        var bytes = file.readAsBytesSync();
        var excel = excel_pkg.Excel.decodeBytes(bytes);
        List<List<dynamic>> rows = [];
        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows) {
            rows.add(row.map((e) => e?.value?.toString() ?? '').toList());
          }
          break; // First sheet
        }
        if (mounted) {
          setState(() {
            _excelRows = rows;
            _isLoadingContent = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingContent = false);
      }
    } else if (cat == FileCategory.text || cat == FileCategory.word) {
      setState(() => _isLoadingContent = true);
      try {
        final text = await file.readAsString();
        if (mounted) {
          setState(() {
            _textContent = text;
            _isLoadingContent = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingContent = false);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _shareFile() {
    Share.shareXFiles([XFile(widget.fileItem.path)], text: widget.fileItem.name);
  }

  void _openInExternalApp() {
    OpenFilex.open(widget.fileItem.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileItem.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share File',
            onPressed: _shareFile,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open with System App',
            onPressed: _openInExternalApp,
          ),
        ],
      ),
      body: _buildViewerContent(),
    );
  }

  Widget _buildViewerContent() {
    final cat = widget.fileItem.category;
    final file = File(widget.fileItem.path);

    switch (cat) {
      case FileCategory.pdf:
        return SfPdfViewer.file(file);

      case FileCategory.image:
        return Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(file, fit: BoxFit.contain),
          ),
        );

      case FileCategory.audio:
        return _buildAudioPlayerUI();

      case FileCategory.video:
        return _isVideoInitialized && _chewieController != null
            ? Center(child: Chewie(controller: _chewieController!))
            : const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));

      case FileCategory.excel:
        return _buildExcelViewer();

      case FileCategory.text:
      case FileCategory.word:
      case FileCategory.presentation:
        return _buildTextOrDocumentViewer();

      default:
        return _buildGenericFallback();
    }
  }

  Widget _buildAudioPlayerUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryGold, width: 2),
              ),
              child: const Icon(Icons.music_note, size: 70, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 24),
            Text(
              widget.fileItem.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
            ),
            const SizedBox(height: 8),
            Text(widget.fileItem.formattedSize, style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 36),
            ProgressBar(
              progress: _position,
              total: _duration,
              progressBarColor: AppTheme.primaryGold,
              baseBarColor: Colors.white24,
              bufferedBarColor: Colors.white10,
              thumbColor: AppTheme.primaryGold,
              onSeek: (duration) => _audioPlayer?.seek(duration),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 42,
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: () {
                    final newPos = _position - const Duration(seconds: 10);
                    _audioPlayer?.seek(newPos < Duration.zero ? Duration.zero : newPos);
                  },
                ),
                const SizedBox(width: 20),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.primaryGold,
                  child: IconButton(
                    iconSize: 36,
                    icon: Icon(_isPlayingAudio ? Icons.pause : Icons.play_arrow, color: Colors.black),
                    onPressed: () {
                      if (_isPlayingAudio) {
                        _audioPlayer?.pause();
                      } else {
                        _audioPlayer?.play();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  iconSize: 42,
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: () {
                    final newPos = _position + const Duration(seconds: 10);
                    _audioPlayer?.seek(newPos > _duration ? _duration : newPos);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExcelViewer() {
    if (_isLoadingContent) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }
    if (_excelRows == null || _excelRows!.isEmpty) {
      return _buildGenericFallback(message: 'Could not render spreadsheet sheet rows in-app.');
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppTheme.darkCard),
          columns: List.generate(
            _excelRows![0].length,
            (index) => DataColumn(
              label: Text(
                'Col ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
              ),
            ),
          ),
          rows: _excelRows!.map((row) {
            return DataRow(
              cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTextOrDocumentViewer() {
    if (_isLoadingContent) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }
    if (_textContent != null && _textContent!.isNotEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: SelectableText(
          _textContent!,
          style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.textLight, fontFamily: 'monospace'),
        ),
      );
    }
    return _buildGenericFallback(
      message: 'This document contains binary formatting. Tap "Open with System App" to view full document layout.',
    );
  }

  Widget _buildGenericFallback({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file_outlined, size: 72, color: AppTheme.primaryGold),
            const SizedBox(height: 20),
            Text(
              widget.fileItem.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
            ),
            const SizedBox(height: 8),
            Text(widget.fileItem.formattedSize, style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 16),
            Text(
              message ?? 'File ready to open or share.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open with External Viewer'),
              onPressed: _openInExternalApp,
            ),
          ],
        ),
      ),
    );
  }
}
