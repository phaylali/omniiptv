import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.blue.withValues(alpha: 0.1),
                  Colors.black,
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                const Text(
                  'OmniIPTV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const Text(
                  'Premium Moroccan Streaming',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 80),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MenuCard(
                      title: 'WATCH TV',
                      icon: TablerIcons.device_tv,
                      onPressed: () => context.push('/tv'),
                      autofocus: true,
                    ),
                    const SizedBox(width: 40),
                    _MenuCard(
                      title: 'SETTINGS',
                      icon: TablerIcons.settings,
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Made by Moroccans, for the Omniverse',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final bool autofocus;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.autofocus = false,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 250,
          height: 300,
          decoration: BoxDecoration(
            color: _isFocused ? Colors.blue : Colors.grey[900],
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ]
                : [],
            border: Border.all(
              color: _isFocused ? Colors.blueAccent : Colors.white10,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 80,
                color: _isFocused ? Colors.white : Colors.white54,
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: TextStyle(
                  color: _isFocused ? Colors.white : Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
