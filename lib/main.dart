import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: SetupScreen()),
);

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with WidgetsBindingObserver {
  static const channel = MethodChannel('one_tap_lock/setup');
  bool ready = false;
  String? error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  // Returning from Settings checks status only. It never requests a lock.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    try {
      final value = await channel.invokeMethod<bool>('isReady') ?? false;
      if (mounted) {
        setState(() {
          ready = value;
          error = null;
        });
      }
    } on PlatformException {
      if (mounted) {
        setState(() {
          ready = false;
          error = 'Service unavailable. Try Accessibility settings again.';
        });
      }
    }
  }

  Future<void> action(String method) async {
    try {
      await channel.invokeMethod<void>(method);
    } on PlatformException catch (e) {
      if (mounted) setState(() => error = e.message);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7F7),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Color(0xFF163A43),
                ),
                const SizedBox(height: 24),
                const Text(
                  'One Tap Lock',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  ready
                      ? 'Ready to lock'
                      : 'Enable Accessibility to get started',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'One Tap Lock uses Android’s Accessibility Service only to turn off and lock the screen when you tap its home-screen icon. It does not read your screen or collect data.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  ready
                      ? 'Close setup, then tap the home-screen icon to lock. Returning from Settings will not lock your phone.'
                      : 'In Accessibility settings, open Installed services (or Installed apps), select One Tap Lock, and enable it. If already enabled but unavailable, switch it off and on.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => action('openSettings'),
                  child: const Text('Open Accessibility settings'),
                ),
                TextButton(
                  onPressed: refresh,
                  child: const Text('Refresh status'),
                ),
                if (ready)
                  TextButton(
                    onPressed: () => action('closeSetup'),
                    child: const Text('Close setup'),
                  ),
                if (error != null) Text(error!, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
