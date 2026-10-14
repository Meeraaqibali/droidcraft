import 'package:flutter/material.dart';
import '../theme.dart';

/// Wraps a screen and asks "Discard changes?" if [isDirty] is true when the
/// user tries to leave. Use [onSave] to persist before leaving.
class DirtyGuard extends StatelessWidget {
  final Widget child;
  final bool isDirty;
  final Future<void> Function()? onSave;
  final VoidCallback? onDiscard;

  const DirtyGuard({
    super.key,
    required this.child,
    required this.isDirty,
    this.onSave,
    this.onDiscard,
  });

  Future<void> _handleBack(BuildContext context) async {
    if (!isDirty) {
      Navigator.pop(context);
      return;
    }
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text(
            'You have edits that haven\'t been saved yet. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (action == 'save') {
      if (onSave != null) await onSave!();
      if (context.mounted) Navigator.pop(context);
    } else if (action == 'discard') {
      onDiscard?.call();
      if (context.mounted) Navigator.pop(context);
    }
    // 'cancel' → do nothing
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack(context);
      },
      child: child,
    );
  }
}
