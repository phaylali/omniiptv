import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/overlay_provider.dart';
import '../../providers/player_provider.dart';

class VolumeOverlay extends ConsumerWidget {
  const VolumeOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider);

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: Slider(
                value: volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(volume * 100).round()}%',
                onChanged: (value) {
                  ref.read(volumeProvider.notifier).state = value;
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Volume: ${(volume * 100).round()}%',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(showOverlayProvider.notifier).state = false;
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
