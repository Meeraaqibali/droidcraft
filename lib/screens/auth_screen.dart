import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _busy = false;
  bool _showPass = false;

  final _loginEmail = TextEditingController(text: 'alex@demo.com');
  final _loginPass = TextEditingController(text: 'demo1234');
  final _suName = TextEditingController();
  final _suEmail = TextEditingController();
  final _suPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    _suName.dispose();
    _suEmail.dispose();
    _suPass.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade600),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(children: [
              const SizedBox(height: 10),
              const Icon(Icons.smartphone, color: Colors.white, size: 64),
              const SizedBox(height: 10),
              const Text('DroidCraft',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1)),
              const SizedBox(height: 6),
              const Text('Design Android apps visually - right from your phone.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 22),
              const Text('QUICK DEMO ACCOUNTS',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(spacing: 10, children: [
                _quickAccount('Alex', 'alex@demo.com', auth),
                _quickAccount('Sam', 'sam@demo.com', auth),
              ]),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40000000), blurRadius: 30, offset: Offset(0, 12))
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  TabBar(
                    controller: _tabs,
                    indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8)]),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: const Color(0xFF4F46E5),
                    unselectedLabelColor: const Color(0xFF6B7280),
                    tabs: const [
                      Tab(text: 'Sign In', height: 44),
                      Tab(text: 'Sign Up', height: 44),
                    ],
                  ),
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabs,
                      children: [_loginTab(auth), _signupTab(auth)],
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _quickAccount(String name, String email, AuthService auth) {
    return GestureDetector(
      onTap: _busy ? null : () => _run(() => auth.login(email, 'demo1234')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Text(name[0],
                  style: const TextStyle(
                      color: Color(0xFF4F46E5), fontWeight: FontWeight.w800))),
          const SizedBox(width: 8),
          Text(name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _loginTab(AuthService auth) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _field(
            controller: _loginEmail,
            icon: Icons.email_outlined,
            hint: 'Email address'),
        const SizedBox(height: 14),
        _field(
            controller: _loginPass,
            icon: Icons.lock_outline,
            hint: 'Password',
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey),
              onPressed: () => setState(() => _showPass = !_showPass),
            )),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: _busy
                ? null
                : () => _run(() => auth.login(_loginEmail.text, _loginPass.text)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                : const Text('Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _signupTab(AuthService auth) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _field(controller: _suName, icon: Icons.person_outline, hint: 'Full name'),
        const SizedBox(height: 14),
        _field(controller: _suEmail, icon: Icons.email_outlined, hint: 'Email address'),
        const SizedBox(height: 14),
        _field(
            controller: _suPass,
            icon: Icons.lock_outline,
            hint: 'Password (min 6 chars)',
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey),
              onPressed: () => setState(() => _showPass = !_showPass),
            )),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: _busy
                ? null
                : () => _run(() => auth.signup(_suName.text, _suEmail.text, _suPass.text)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                : const Text('Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffix,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
      ),
    );
  }
}
