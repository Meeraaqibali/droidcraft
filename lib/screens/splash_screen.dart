import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));

    _logoScale = Tween(begin: 0.4, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(CurvedAnimation(
            parent: _c, curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));

    _logoFade = CurvedAnimation(
        parent: _c, curve: const Interval(0.0, 0.35, curve: Curves.easeOut));

    _titleSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(CurvedAnimation(
            parent: _c, curve: const Interval(0.35, 0.75, curve: Curves.easeOut)));

    _titleFade = CurvedAnimation(
        parent: _c, curve: const Interval(0.35, 0.75, curve: Curves.easeOut));

    _glow = CurvedAnimation(
        parent: _c, curve: const Interval(0.55, 1.0, curve: Curves.easeInOut));

    _c.forward();

    Future.delayed(const Duration(milliseconds: 3600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: a,
          child: child,
        ),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF6D28D9), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [
          Positioned(
            top: -120,
            right: -80,
            child: AnimatedBuilder(
              animation: _glow,
              builder: (_, __) => Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08 * _glow.value),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: AnimatedBuilder(
              animation: _glow,
              builder: (_, __) => Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06 * _glow.value),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 40,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.android,
                        size: 76,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: const Text(
                      'DroidCraft',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: const Text(
                      'Design Android apps visually',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 60,
            right: 60,
            bottom: 70,
            child: FadeTransition(
              opacity: _glow,
              child: Column(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Loading your workspace...',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
