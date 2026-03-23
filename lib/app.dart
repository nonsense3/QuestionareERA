import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'features/auth/auth_gate.dart';
import 'shared/widgets/neo_loader.dart';

class QuestioareEraApp extends StatelessWidget {
  const QuestioareEraApp({super.key, required this.supabaseReady});
  final bool supabaseReady;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Questioare ERA',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: _BootstrapGate(supabaseReady: supabaseReady),
        );
      },
    );
  }
}

class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate({required this.supabaseReady});

  final bool supabaseReady;

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  var _showLoader = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _showLoader = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoader) {
      return const Scaffold(
        body: Center(
          child: NeoLoader(label: 'Starting Questioare Era'),
        ),
      );
    }
    return AuthGate(supabaseReady: widget.supabaseReady);
  }
}
