import 'package:flutter/material.dart';
import 'models.dart';
import 'registry.dart';

class TemplateDef {
  final String key, name;
  final IconData icon;
  final List<ScreenModel> Function() build;
  const TemplateDef({required this.key, required this.name, required this.icon, required this.build});
}

ComponentModel _c(String t, Map<String, dynamic> p) {
  final c = makeComponent(t);
  c.props.addAll(p);
  return c;
}

final Map<String, TemplateDef> templates = {
  // ---------- Quick Start (4) ----------
  'blank': TemplateDef(
    key: 'blank', name: 'Blank', icon: Icons.crop_square,
    build: () => [ScreenModel(id: uid(), name: 'Home')],
  ),
  'login': TemplateDef(
    key: 'login', name: 'Login', icon: Icons.lock_outline,
    build: () => [
      ScreenModel(id: uid(), name: 'Login', components: [
        _c('heading', {'text': 'Welcome back', 'align': 'center', 'size': 24}),
        _c('text', {'text': 'Sign in to continue', 'align': 'center', 'color': '#6B7280', 'size': 13}),
        _c('input', {'text': 'Email address'}),
        _c('input', {'text': 'Password'}),
        _c('button', {'text': 'Sign In', 'align': 'center', 'bg': '#6200EE', 'color': '#FFFFFF'}),
        _c('text', {'text': 'Forgot password?', 'align': 'center', 'color': '#6200EE', 'size': 12}),
      ]),
    ],
  ),
  'profile': TemplateDef(
    key: 'profile', name: 'Profile', icon: Icons.person_outline,
    build: () => [
      ScreenModel(id: uid(), name: 'Profile', components: [
        _c('avatar', {'size': 20, 'align': 'center'}),
        _c('heading', {'text': 'Alex Johnson', 'align': 'center', 'size': 20}),
        _c('text', {'text': 'Product Designer', 'align': 'center', 'color': '#6B7280', 'size': 13}),
        _c('divider', {}),
        _c('card', {'text': 'Account settings'}),
        _c('card', {'text': 'Notifications'}),
        _c('button', {'text': 'Log Out', 'align': 'center', 'bg': '#EF4444', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  'dashboard': TemplateDef(
    key: 'dashboard', name: 'Dashboard', icon: Icons.dashboard_outlined,
    build: () => [
      ScreenModel(id: uid(), name: 'Dashboard', components: [
        _c('heading', {'text': 'Dashboard', 'size': 22}),
        _c('card', {'text': 'Revenue 12,480'}),
        _c('card', {'text': 'Active users 3,214'}),
        _c('progress', {}),
        _c('text', {'text': 'Weekly performance', 'color': '#6B7280', 'size': 12}),
        _c('slider', {}),
        _c('button', {'text': 'View Report', 'align': 'center'}),
      ]),
    ],
  ),

  // ---------- Explore (6 new) ----------
  'signup': TemplateDef(
    key: 'signup', name: 'Sign Up', icon: Icons.person_add_outlined,
    build: () => [
      ScreenModel(id: uid(), name: 'Sign Up', components: [
        _c('heading', {'text': 'Create account', 'align': 'center', 'size': 24}),
        _c('text', {'text': 'Start building in seconds', 'align': 'center', 'color': '#6B7280', 'size': 13}),
        _c('input', {'text': 'Full name'}),
        _c('input', {'text': 'Email address'}),
        _c('input', {'text': 'Password'}),
        _c('checkbox', {'text': 'I agree to the terms', 'on': true}),
        _c('button', {'text': 'Create Account', 'align': 'center', 'bg': '#4F46E5', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  'chat': TemplateDef(
    key: 'chat', name: 'Chat', icon: Icons.chat_bubble_outline,
    build: () => [
      ScreenModel(id: uid(), name: 'Chat', components: [
        _c('appbar', {'text': 'Alex Johnson'}),
        _c('card', {'text': 'Alex · Hey! How are you?'}),
        _c('card', {'text': 'You · Doing great, thanks!'}),
        _c('card', {'text': 'Alex · Coffee later?'}),
        _c('spacer', {'size': 12}),
        _c('input', {'text': 'Type a message'}),
        _c('button', {'text': 'Send', 'align': 'right', 'bg': '#4F46E5', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  'search': TemplateDef(
    key: 'search', name: 'Search', icon: Icons.search,
    build: () => [
      ScreenModel(id: uid(), name: 'Search', components: [
        _c('appbar', {'text': 'Search'}),
        _c('input', {'text': 'Search products, people, places'}),
        _c('chip', {'text': 'Popular', 'bg': '#4F46E5'}),
        _c('card', {'text': 'Trending now'}),
        _c('card', {'text': 'Near you'}),
        _c('card', {'text': 'Recommended'}),
      ]),
    ],
  ),
  'payment': TemplateDef(
    key: 'payment', name: 'Payment', icon: Icons.payment,
    build: () => [
      ScreenModel(id: uid(), name: 'Payment', components: [
        _c('heading', {'text': 'Checkout', 'size': 22}),
        _c('card', {'text': 'Order total  —  \$58.00'}),
        _c('input', {'text': 'Card number'}),
        _c('input', {'text': 'MM / YY'}),
        _c('input', {'text': 'CVC'}),
        _c('button', {'text': 'Pay \$58.00', 'align': 'center', 'bg': '#10B981', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  'onboarding': TemplateDef(
    key: 'onboarding', name: 'Onboarding', icon: Icons.auto_awesome,
    build: () => [
      ScreenModel(id: uid(), name: 'Welcome', components: [
        _c('spacer', {'size': 24}),
        _c('avatar', {'size': 22, 'align': 'center'}),
        _c('heading', {'text': 'Build apps on your phone', 'align': 'center', 'size': 24}),
        _c('text', {
          'text': 'Drag, drop, and export production-ready Android UI in minutes.',
          'align': 'center',
          'color': '#6B7280',
          'size': 14,
        }),
        _c('spacer', {'size': 20}),
        _c('button', {'text': 'Get Started', 'align': 'center', 'bg': '#4F46E5', 'color': '#FFFFFF'}),
        _c('text', {'text': 'Skip', 'align': 'center', 'color': '#6B7280', 'size': 12}),
      ]),
    ],
  ),
  'empty': TemplateDef(
    key: 'empty', name: 'Empty State', icon: Icons.inbox_outlined,
    build: () => [
      ScreenModel(id: uid(), name: 'Empty', components: [
        _c('spacer', {'size': 32}),
        _c('image', {}),
        _c('heading', {'text': 'Nothing here yet', 'align': 'center', 'size': 20}),
        _c('text', {
          'text': 'Items you add will show up here.',
          'align': 'center',
          'color': '#6B7280',
          'size': 13,
        }),
        _c('button', {'text': 'Add Item', 'align': 'center', 'bg': '#4F46E5', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
};
