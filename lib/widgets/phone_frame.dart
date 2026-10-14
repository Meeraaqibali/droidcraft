import 'package:flutter/material.dart';

class PhoneFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? screenBg;
  final Color? barBg;
  final bool statusBar;
  const PhoneFrame({
    super.key,
    required this.title,
    required this.child,
    this.screenBg,
    this.barBg,
    this.statusBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = screenBg ?? Colors.white;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
            BoxShadow(color: Color(0x0F000000), blurRadius: 40, offset: Offset(0, 20)),
          ],
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (statusBar)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: const Color(0xFF1F2937),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('9:41',
                          style: TextStyle(
                              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      Text('▮▮▮ 🔋',
                          style: TextStyle(
                              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: barBg ?? const Color(0xFF6200EE),
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              Container(color: bg, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
