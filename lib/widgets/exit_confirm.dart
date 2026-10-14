import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Wraps a screen so pressing the system back button shows a confirm dialog.
class ExitConfirm extends StatelessWidget {
  final Widget child;
  final String title;
  final String message;

  const ExitConfirm({
    super.key,
    required this.child,
    this.title = 'Exit DroidCraft?',
    this.message = 'Your projects are saved automatically. Close the app now?',
  });

  Future<bool> _confirm(BuildContext context) async {
    final v = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return v ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirm(context);
        if (ok && context.mounted) {
          await SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
