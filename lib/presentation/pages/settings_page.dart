import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/channel.dart';
import '../../providers/channel_provider.dart';
import '../../data/services/m3u_import_service.dart';
import '../../data/services/m3u_export_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  List<Channel> _channels = [];
  bool _isImporting = false;
  bool _isExporting = false;
  String _importUrl = 'https://iptv-org.github.io/iptv/countries/ma.m3u';
  String? _importError;
  ImportResult? _lastImportResult;
  String? _reorderingId;

  Future<void> _exportM3U() async {
    setState(() => _isExporting = true);
    try {
      final m3uContent = M3UExportService.generateM3U(_channels);
      final fileName = 'omniiptv_export_${DateTime.now().millisecondsSinceEpoch}.m3u';
      
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save M3U Playlist',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['m3u', 'm3u8'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(m3uContent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to $outputFile'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  void _moveUp(int index) {
    if (index > 0) {
      _reorderChannels(index, index - 1);
    }
  }

  void _moveDown(int index) {
    if (index < _channels.length - 1) {
      _reorderChannels(index, index + 2);
    }
  }

  Future<void> _loadChannels() async {
    final allChannelList = await ref.read(channelRepositoryProvider).loadAllChannels();
    setState(() {
      _channels = List.from(allChannelList.channels);
    });
  }

  void _toggleChannel(Channel channel) {
    setState(() {
      final index = _channels.indexWhere((c) => c.id == channel.id);
      if (index != -1) {
        _channels[index] = channel.copyWith(isActive: !channel.isActive);
      }
    });
    _saveChanges();
  }

  void _reorderChannels(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _channels.removeAt(oldIndex);
      _channels.insert(newIndex, item);
      for (int i = 0; i < _channels.length; i++) {
        _channels[i] = _channels[i].copyWith(order: i + 1);
      }
    });
    _saveChanges();
  }

  Future<void> _saveChanges() async {
    final repository = ref.read(channelRepositoryProvider);
    await repository.updateChannelOrder(_channels.map((c) => c.id).toList());
    final overrides = _channels.where((c) => !c.isActive).toList();
    await repository.updateChannelOverrides(overrides);
    ref.invalidate(channelListProvider);
  }

  Future<void> _importM3U() async {
    setState(() {
      _isImporting = true;
      _importError = null;
      _lastImportResult = null;
    });

    final repository = ref.read(channelRepositoryProvider);
    final result = await repository.importM3U(_importUrl, append: true);

    setState(() {
      _isImporting = false;
      _lastImportResult = result;
      if (result.errors.isNotEmpty) {
        _importError = result.errors.join('\n');
      }
    });

    if (result.channelsAdded > 0) {
      await _loadChannels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text('OmniIPTV Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: _FocusButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _FocusButton(
            label: _isExporting ? 'EXPORTING...' : 'EXPORT M3U',
            onPressed: _isExporting ? null : _exportM3U,
          ),
          const SizedBox(width: 8),
          _FocusButton(
            label: _isImporting ? 'IMPORTING...' : 'IMPORT M3U',
            onPressed: _isImporting ? null : _importM3U,
            isPrimary: true,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Import Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[850],
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: _FocusTextField(
                    hintText: 'M3U Playlist URL',
                    initialValue: _importUrl,
                    onChanged: (value) => _importUrl = value,
                  ),
                ),
              ],
            ),
          ),
          if (_importError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red.withValues(alpha: 0.2),
              child: Text(_importError!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),
          if (_lastImportResult != null && _lastImportResult!.errors.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.green.withValues(alpha: 0.2),
              child: Text('Imported ${_lastImportResult!.channelsAdded} channels',
                  style: const TextStyle(color: Colors.green), textAlign: TextAlign.center),
            ),
          // Channel List
          Expanded(
            child: _channels.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ReorderableListView(
                    onReorder: _reorderChannels,
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      for (int i = 0; i < _channels.length; i++)
                        _ChannelListItem(
                          key: ValueKey(_channels[i].id),
                          channel: _channels[i],
                          index: i,
                          isReordering: _reorderingId == _channels[i].id,
                          onToggle: () => _toggleChannel(_channels[i]),
                          onLongPress: () {
                            setState(() {
                              _reorderingId = (_reorderingId == _channels[i].id) ? null : _channels[i].id;
                            });
                          },
                          onMoveUp: () => _moveUp(i),
                          onMoveDown: () => _moveDown(i),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FocusButton extends StatefulWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _FocusButton({this.icon, this.label, this.onPressed, this.isPrimary = false});

  @override
  State<_FocusButton> createState() => _FocusButtonState();
}

class _FocusButtonState extends State<_FocusButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: widget.icon != null
          ? IconButton(
              icon: Icon(widget.icon, color: _isFocused ? Colors.blue : Colors.white),
              onPressed: widget.onPressed,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFocused ? Colors.blue : widget.isPrimary ? Colors.blue.withValues(alpha: 0.5) : Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
                child: Text(widget.label!),
              ),
            ),
    );
  }
}

class _FocusTextField extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _FocusTextField({required this.hintText, required this.initialValue, required this.onChanged});

  @override
  State<_FocusTextField> createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<_FocusTextField> {
  bool _isFocused = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _isFocused ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: _isFocused ? Colors.blue : Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

class _ChannelListItem extends StatefulWidget {
  final Channel channel;
  final int index;
  final bool isReordering;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _ChannelListItem({
    super.key,
    required this.channel,
    required this.index,
    required this.isReordering,
    required this.onToggle,
    required this.onLongPress,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  State<_ChannelListItem> createState() => _ChannelListItemState();
}

class _ChannelListItemState extends State<_ChannelListItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _isFocused 
            ? Colors.blue.withValues(alpha: 0.3) 
            : widget.isReordering 
              ? Colors.blue.withValues(alpha: 0.1) 
              : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused ? Colors.blue : widget.isReordering ? Colors.blue.withValues(alpha: 0.5) : Colors.white10,
            width: _isFocused ? 3 : 1,
          ),
        ),
        child: ListTile(
          onTap: widget.onToggle,
          onLongPress: widget.onLongPress,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.channel.logoUrl != null
                    ? Image.network(
                        widget.channel.logoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(widget.channel.icon, color: Colors.white),
                      )
                    : Icon(widget.channel.icon, color: Colors.white),
              ),
              Positioned(
                top: -5,
                left: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    widget.channel.order.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            widget.channel.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: _isFocused || widget.isReordering ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            widget.isReordering ? 'MOVE MODE: Use arrows to reorder' : (widget.channel.category ?? 'General'),
            style: TextStyle(color: widget.isReordering ? Colors.blue : Colors.white54),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isReordering) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.blue),
                  onPressed: widget.onMoveUp,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, color: Colors.blue),
                  onPressed: widget.onMoveDown,
                ),
              ] else ...[
                Switch(
                  value: widget.channel.isActive,
                  onChanged: (value) => widget.onToggle(),
                  activeColor: Colors.blue,
                ),
                const Icon(Icons.drag_handle, color: Colors.white24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
