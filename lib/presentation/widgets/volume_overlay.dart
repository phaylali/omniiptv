import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/overlay_provider.dart';
import '../../providers/player_provider.dart';

class VolumeOverlay extends ConsumerStatefulWidget {
  const VolumeOverlay({super.key});

  @override
  ConsumerState<VolumeOverlay> createState() => _VolumeOverlayState();
}

class _VolumeOverlayState extends ConsumerState<VolumeOverlay> {
  bool _isButtonFocused = false;

  @override
  Widget build(BuildContext context) {
    final volume = ref.watch(volumeProvider);

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              volume == 0 ? Icons.volume_off : volume < 0.5 ? Icons.volume_down : Icons.volume_up,
              color: Colors.blue, 
              size: 100,
            ),
            const SizedBox(height: 32),
            Container(
              width: 400,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: volume,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${(volume * 100).round()}%',
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 48, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 64),
            Focus(
              autofocus: true,
              onFocusChange: (hasFocus) => setState(() => _isButtonFocused = hasFocus),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(showOverlayProvider.notifier).state = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonFocused ? Colors.blue : Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'CLOSE', 
                  style: TextStyle(
                    color: _isButtonFocused ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
