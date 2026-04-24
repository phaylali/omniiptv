import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/channel.dart';
import '../../providers/channel_provider.dart';
import '../../providers/overlay_provider.dart';
import '../../data/services/m3u_import_service.dart';

class SettingsOverlay extends ConsumerStatefulWidget {
  const SettingsOverlay({super.key});

  @override
  ConsumerState<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends ConsumerState<SettingsOverlay> {
  List<Channel> _channels = [];
  bool _isImporting = false;
  String _importUrl = 'https://iptv-org.github.io/iptv/countries/ma.m3u';
  String? _importError;
  ImportResult? _lastImportResult;
  String? _reorderingId;

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
    final allChannelList = await ref
        .read(channelRepositoryProvider)
        .loadAllChannels();
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
      // Update order numbers
      for (int i = 0; i < _channels.length; i++) {
        _channels[i] = _channels[i].copyWith(order: i + 1);
      }
    });
    _saveChanges();
  }

  Future<void> _saveChanges() async {
    final repository = ref.read(channelRepositoryProvider);
    // Save channel order
    await repository.updateChannelOrder(_channels.map((c) => c.id).toList());
    // Save overrides (inactive channels)
    final overrides = _channels.where((c) => !c.isActive).toList();
    await repository.updateChannelOverrides(overrides);

    // Refresh
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
    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[800],
            child: Row(
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isImporting ? null : _importM3U,
                  child: _isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Import M3U'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ref.read(showOverlayProvider.notifier).state = false;
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Column(
              children: [
                // Top: Import settings
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[800]!.withValues(alpha: 0.5),
                  child: Row(
                    children: [
                      const Text(
                        'M3U Import:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'M3U Playlist URL',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          controller: TextEditingController(text: _importUrl)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _importUrl.length),
                            ),
                          onChanged: (value) => _importUrl = value,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_isImporting)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: _importM3U,
                          child: const Text('Import'),
                        ),
                    ],
                  ),
                ),
                if (_importError != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.withValues(alpha: 0.2),
                    child: Text(
                      _importError!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_lastImportResult != null && _lastImportResult!.errors.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.green.withValues(alpha: 0.2),
                    child: Text(
                      'Imported ${_lastImportResult!.channelsAdded} channels',
                      style: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Bottom: Channel list management
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Channel List (Drag to reorder)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _channels.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ReorderableListView(
                                onReorder: _reorderChannels,
                                children: _channels.map((channel) {
                                  final isReordering = _reorderingId == channel.id;
                                  final index = _channels.indexOf(channel);

                                  return Container(
                                    key: ValueKey(channel.id),
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isReordering ? Colors.blue.withValues(alpha: 0.2) : Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isReordering ? Colors.blue : Colors.white10,
                                        width: isReordering ? 2 : 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          if (_reorderingId == channel.id) {
                                            _reorderingId = null;
                                          } else {
                                            _reorderingId = channel.id;
                                          }
                                        });
                                      },
                                      leading: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: channel.logoUrl != null
                                            ? Image.network(
                                                channel.logoUrl!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Icon(channel.icon, color: Colors.white),
                                              )
                                            : Icon(channel.icon, color: Colors.white),
                                      ),
                                      title: Text(
                                        channel.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: isReordering ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      subtitle: Text(
                                        isReordering ? 'Use arrows to move up/down' : (channel.category ?? 'General'),
                                        style: TextStyle(
                                          color: isReordering ? Colors.blue[300] : Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isReordering) ...[
                                            IconButton(
                                              icon: const Icon(Icons.arrow_upward, color: Colors.blue),
                                              onPressed: () => _moveUp(index),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.arrow_downward, color: Colors.blue),
                                              onPressed: () => _moveDown(index),
                                            ),
                                          ] else ...[
                                            Switch(
                                              value: channel.isActive,
                                              onChanged: (value) =>
                                                  _toggleChannel(channel),
                                            ),
                                            const Icon(
                                              Icons.drag_handle,
                                              color: Colors.white54,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
