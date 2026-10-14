import 'package:flutter/material.dart';

/// Fades + slides each child into place, one after another.
/// Wrap a list of children and they'll cascade in smoothly.
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration stepDelay;

  const StaggeredList({
    super.key,
    required this.children,
    this.baseDelay = const Duration(milliseconds: 40),
    this.stepDelay = const Duration(milliseconds: 55),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(children.length, (i) {
        return _StaggerItem(
          delay: baseDelay + stepDelay * i,
          child: children[i],
        );
      }),
    );
  }
}

class _StaggerItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _StaggerItem({required this.child, required this.delay});

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_c);
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
