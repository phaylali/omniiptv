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

  @override
  void initState() {
    super.initState();
    _loadChannels();
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
            child: Row(
              children: [
                // Left: Channel list management
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Channel List',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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
                                  return Container(
                                    key: ValueKey(channel.id),
                                    color: Colors.grey[900],
                                    child: ListTile(
                                      leading: Icon(
                                        channel.icon,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        channel.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
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
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
                // Right: Import settings
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[800]!.withValues(alpha: 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'M3U Import',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'M3U Playlist URL',
                            labelStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.white),
                          controller: TextEditingController(text: _importUrl)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _importUrl.length),
                            ),
                          onChanged: (value) => _importUrl = value,
                        ),
                        const SizedBox(height: 16),
                        if (_isImporting)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: _importM3U,
                            child: const Text('Import'),
                          ),
                        const SizedBox(height: 16),
                        if (_importError != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.red.withValues(alpha: 0.2),
                            child: Text(
                              _importError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        if (_lastImportResult != null &&
                            _lastImportResult!.errors.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.green.withValues(alpha: 0.2),
                            child: Text(
                              'Imported ${_lastImportResult!.channelsAdded} channels',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        const SizedBox(height: 32),
                        const Text(
                          'Note: Imported channels will be appended to the end of the list. You can reorder them manually.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
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
