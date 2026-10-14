import 'package:flutter/material.dart';
import 'models.dart';
import 'registry.dart';

class IdeaDef {
  final String key, title, subtitle;
  final IconData icon;
  final Color color;
  final List<ScreenModel> Function() build;
  const IdeaDef({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.build,
  });
}

ComponentModel _c(String t, Map<String, dynamic> p) {
  final c = makeComponent(t);
  c.props.addAll(p);
  return c;
}

final List<IdeaDef> ideas = [
  IdeaDef(
    key: 'shop',
    title: 'E-commerce',
    subtitle: 'Shop · Product · Cart',
    icon: Icons.shopping_bag_outlined,
    color: const Color(0xFFEF4444),
    build: () => [
      ScreenModel(id: uid(), name: 'Shop', components: [
        _c('appbar', {'text': 'Shop'}),
        _c('image', {'height': 180.0}),
        _c('heading', {'text': 'Featured products', 'size': 18}),
        _c('card', {'text': 'Wireless Headphones - 89'}),
        _c('card', {'text': 'Smart Watch - 149'}),
        _c('button', {'text': 'View Cart', 'align': 'center', 'bg': '#EF4444', 'color': '#FFFFFF'}),
      ]),
      ScreenModel(id: uid(), name: 'Product', components: [
        _c('appbar', {'text': 'Product detail'}),
        _c('image', {'height': 220.0}),
        _c('heading', {'text': 'Wireless Headphones', 'size': 20}),
        _c('text', {'text': '89.00', 'color': '#EF4444', 'size': 18, 'bold': true}),
        _c('text', {
          'text': 'Premium sound, 30-hour battery life, comfortable over-ear design.',
          'color': '#6B7280'
        }),
        _c('button', {
          'text': 'Add to Cart',
          'align': 'center',
          'bg': '#EF4444',
          'color': '#FFFFFF'
        }),
      ]),
      ScreenModel(id: uid(), name: 'Cart', components: [
        _c('appbar', {'text': 'Your Cart'}),
        _c('card', {'text': '1x Wireless Headphones  -  89'}),
        _c('divider', {}),
        _c('heading', {'text': 'Total: 89', 'size': 18}),
        _c('button', {
          'text': 'Checkout',
          'align': 'center',
          'bg': '#10B981',
          'color': '#FFFFFF'
        }),
      ]),
    ],
  ),
  IdeaDef(
    key: 'chat',
    title: 'Chat app',
    subtitle: 'Inbox · Chat · Profile',
    icon: Icons.chat_bubble_outline,
    color: const Color(0xFF4F46E5),
    build: () => [
      ScreenModel(id: uid(), name: 'Inbox', components: [
        _c('appbar', {'text': 'Messages'}),
        _c('input', {'text': 'Search conversations'}),
        _c('card', {'text': 'Alex - Hey, coffee later?'}),
        _c('card', {'text': 'Sam - Sent the file!'}),
        _c('card', {'text': 'Kim - Thanks!'}),
      ]),
      ScreenModel(id: uid(), name: 'Chat', components: [
        _c('appbar', {'text': 'Alex'}),
        _c('card', {'text': 'Alex - Hey! How are you?'}),
        _c('card', {'text': 'You - Doing great, thanks!'}),
        _c('card', {'text': 'Alex - Coffee later?'}),
        _c('spacer', {'size': 12}),
        _c('input', {'text': 'Type a message'}),
        _c('button', {
          'text': 'Send',
          'align': 'right',
          'bg': '#4F46E5',
          'color': '#FFFFFF'
        }),
      ]),
      ScreenModel(id: uid(), name: 'Profile', components: [
        _c('appbar', {'text': 'Profile'}),
        _c('avatar', {'size': 20, 'align': 'center'}),
        _c('heading', {'text': 'Alex Johnson', 'align': 'center', 'size': 20}),
        _c('text', {'text': 'Online', 'align': 'center', 'color': '#10B981', 'size': 12}),
        _c('button', {
          'text': 'Message',
          'align': 'center',
          'bg': '#4F46E5',
          'color': '#FFFFFF'
        }),
      ]),
    ],
  ),
  IdeaDef(
    key: 'fitness',
    title: 'Fitness',
    subtitle: 'Today · Workout · Stats',
    icon: Icons.fitness_center,
    color: const Color(0xFF10B981),
    build: () => [
      ScreenModel(id: uid(), name: 'Today', components: [
        _c('appbar', {'text': 'Good morning'}),
        _c('heading', {'text': "Today's goal", 'size': 20}),
        _c('progress', {}),
        _c('text', {'text': '6,240 / 10,000 steps', 'color': '#6B7280', 'size': 13}),
        _c('card', {'text': 'Active minutes - 42'}),
        _c('card', {'text': 'Calories - 380'}),
      ]),
      ScreenModel(id: uid(), name: 'Workout', components: [
        _c('appbar', {'text': 'Full-body workout'}),
        _c('image', {'height': 180.0}),
        _c('heading', {'text': '30 min - Intermediate', 'size': 16}),
        _c('divider', {}),
        _c('text', {'text': 'Warm up - 5 min'}),
        _c('text', {'text': 'Squats - 3x12'}),
        _c('text', {'text': 'Push-ups - 3x15'}),
        _c('text', {'text': 'Plank - 3x45 sec'}),
        _c('button', {
          'text': 'Start',
          'align': 'center',
          'bg': '#10B981',
          'color': '#FFFFFF'
        }),
      ]),
      ScreenModel(id: uid(), name: 'Stats', components: [
        _c('appbar', {'text': 'Stats'}),
        _c('heading', {'text': 'This week', 'size': 18}),
        _c('card', {'text': 'Total steps - 48,320'}),
        _c('card', {'text': 'Avg heart rate - 72 bpm'}),
        _c('slider', {}),
        _c('text', {'text': 'Weekly performance', 'color': '#6B7280', 'size': 12}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'notes',
    title: 'Notes',
    subtitle: 'List · Editor',
    icon: Icons.description_outlined,
    color: const Color(0xFFF59E0B),
    build: () => [
      ScreenModel(id: uid(), name: 'Notes', components: [
        _c('appbar', {'text': 'Notes'}),
        _c('input', {'text': 'Search notes'}),
        _c('chip', {'text': 'All', 'bg': '#F59E0B'}),
        _c('card', {'text': 'Shopping list'}),
        _c('card', {'text': 'Meeting notes - Tuesday'}),
        _c('card', {'text': 'Book ideas'}),
      ]),
      ScreenModel(id: uid(), name: 'Editor', components: [
        _c('appbar', {'text': 'New note'}),
        _c('heading', {'text': 'Untitled', 'size': 22}),
        _c('divider', {}),
        _c('text', {'text': 'Start typing your note...', 'color': '#6B7280'}),
        _c('spacer', {'size': 80}),
        _c('button', {
          'text': 'Save',
          'align': 'center',
          'bg': '#F59E0B',
          'color': '#FFFFFF'
        }),
      ]),
    ],
  ),
];
