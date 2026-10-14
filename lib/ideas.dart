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
    subtitle: 'Shop - Product - Cart',
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
        _c('text', {'text': 'Premium sound, 30-hour battery life.', 'color': '#6B7280'}),
        _c('button', {'text': 'Add to Cart', 'align': 'center', 'bg': '#EF4444', 'color': '#FFFFFF'}),
      ]),
      ScreenModel(id: uid(), name: 'Cart', components: [
        _c('appbar', {'text': 'Your Cart'}),
        _c('card', {'text': '1x Wireless Headphones - 89'}),
        _c('divider', {}),
        _c('heading', {'text': 'Total: 89', 'size': 18}),
        _c('button', {'text': 'Checkout', 'align': 'center', 'bg': '#10B981', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'chat',
    title: 'Chat app',
    subtitle: 'Inbox - Chat - Profile',
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
        _c('card', {'text': 'You - Doing great!'}),
        _c('card', {'text': 'Alex - Coffee later?'}),
        _c('spacer', {'size': 12}),
        _c('input', {'text': 'Type a message'}),
        _c('button', {'text': 'Send', 'align': 'right', 'bg': '#4F46E5', 'color': '#FFFFFF'}),
      ]),
      ScreenModel(id: uid(), name: 'Profile', components: [
        _c('appbar', {'text': 'Profile'}),
        _c('avatar', {'size': 20, 'align': 'center'}),
        _c('heading', {'text': 'Alex Johnson', 'align': 'center', 'size': 20}),
        _c('text', {'text': 'Online', 'align': 'center', 'color': '#10B981', 'size': 12}),
        _c('button', {'text': 'Message', 'align': 'center', 'bg': '#4F46E5', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'fitness',
    title: 'Fitness',
    subtitle: 'Today - Workout - Stats',
    icon: Icons.fitness_center,
    color: const Color(0xFF10B981),
    build: () => [
      ScreenModel(id: uid(), name: 'Today', components: [
        _c('appbar', {'text': 'Good morning'}),
        _c('heading', {'text': 'Today goal', 'size': 20}),
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
        _c('button', {'text': 'Start', 'align': 'center', 'bg': '#10B981', 'color': '#FFFFFF'}),
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
    subtitle: 'List - Editor',
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
        _c('button', {'text': 'Save', 'align': 'center', 'bg': '#F59E0B', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'food',
    title: 'Food delivery',
    subtitle: 'Menu - Item - Cart',
    icon: Icons.restaurant_outlined,
    color: const Color(0xFFF97316),
    build: () => [
      ScreenModel(id: uid(), name: 'Menu', components: [
        _c('appbar', {'text': 'Order food'}),
        _c('input', {'text': 'Search restaurants'}),
        _c('chip', {'text': 'Pizza', 'bg': '#F97316'}),
        _c('card', {'text': 'Pizza Palace - 20 min'}),
        _c('card', {'text': 'Sushi House - 30 min'}),
        _c('card', {'text': 'Burger Joint - 15 min'}),
      ]),
      ScreenModel(id: uid(), name: 'Item', components: [
        _c('appbar', {'text': 'Pizza Palace'}),
        _c('image', {'height': 200.0}),
        _c('heading', {'text': 'Margherita Pizza', 'size': 20}),
        _c('text', {'text': '12.99', 'color': '#F97316', 'size': 18, 'bold': true}),
        _c('text', {'text': 'Fresh mozzarella, tomato, basil', 'color': '#6B7280'}),
        _c('button', {'text': 'Add to Cart', 'align': 'center', 'bg': '#F97316', 'color': '#FFFFFF'}),
      ]),
      ScreenModel(id: uid(), name: 'Cart', components: [
        _c('appbar', {'text': 'Your Order'}),
        _c('card', {'text': '1x Margherita - 12.99'}),
        _c('card', {'text': 'Delivery fee - 2.50'}),
        _c('divider', {}),
        _c('heading', {'text': 'Total: 15.49', 'size': 18}),
        _c('button', {'text': 'Place Order', 'align': 'center', 'bg': '#10B981', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'music',
    title: 'Music player',
    subtitle: 'Library - Now Playing',
    icon: Icons.music_note_outlined,
    color: const Color(0xFF8B5CF6),
    build: () => [
      ScreenModel(id: uid(), name: 'Library', components: [
        _c('appbar', {'text': 'Your Library'}),
        _c('chip', {'text': 'Songs', 'bg': '#8B5CF6'}),
        _c('card', {'text': 'Midnight Drive - The Waves'}),
        _c('card', {'text': 'Neon Sky - Aurora'}),
        _c('card', {'text': 'Echoes - Reflections'}),
      ]),
      ScreenModel(id: uid(), name: 'Now Playing', components: [
        _c('appbar', {'text': 'Now Playing'}),
        _c('image', {'height': 240.0}),
        _c('heading', {'text': 'Midnight Drive', 'size': 22, 'align': 'center'}),
        _c('text', {'text': 'The Waves', 'color': '#6B7280', 'size': 13, 'align': 'center'}),
        _c('slider', {}),
        _c('text', {'text': '1:24  /  3:47', 'color': '#6B7280', 'size': 11}),
        _c('button', {'text': 'Pause', 'align': 'center', 'bg': '#8B5CF6', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'weather',
    title: 'Weather',
    subtitle: 'Today - Forecast',
    icon: Icons.cloud_outlined,
    color: const Color(0xFF06B6D4),
    build: () => [
      ScreenModel(id: uid(), name: 'Today', components: [
        _c('appbar', {'text': 'Weather'}),
        _c('heading', {'text': '22 deg', 'size': 60, 'align': 'center'}),
        _c('text', {'text': 'Partly cloudy', 'color': '#6B7280', 'align': 'center'}),
        _c('text', {'text': 'Karachi, Pakistan', 'color': '#6B7280', 'align': 'center', 'size': 12}),
        _c('divider', {}),
        _c('card', {'text': 'Humidity - 62%'}),
        _c('card', {'text': 'Wind - 12 km/h'}),
      ]),
      ScreenModel(id: uid(), name: 'Forecast', components: [
        _c('appbar', {'text': '5-day forecast'}),
        _c('card', {'text': 'Mon - 22 deg  Partly cloudy'}),
        _c('card', {'text': 'Tue - 24 deg  Sunny'}),
        _c('card', {'text': 'Wed - 21 deg  Rain'}),
        _c('card', {'text': 'Thu - 20 deg  Cloudy'}),
        _c('card', {'text': 'Fri - 23 deg  Sunny'}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'bank',
    title: 'Banking',
    subtitle: 'Home - Transfer - History',
    icon: Icons.account_balance_outlined,
    color: const Color(0xFF0EA5E9),
    build: () => [
      ScreenModel(id: uid(), name: 'Home', components: [
        _c('appbar', {'text': 'My Account'}),
        _c('heading', {'text': '12,480.50', 'size': 34}),
        _c('text', {'text': 'Available balance', 'color': '#6B7280', 'size': 12}),
        _c('divider', {}),
        _c('button', {'text': 'Send Money', 'align': 'center', 'bg': '#0EA5E9', 'color': '#FFFFFF'}),
        _c('button', {'text': 'Request Money', 'align': 'center', 'bg': '#10B981', 'color': '#FFFFFF'}),
      ]),
      ScreenModel(id: uid(), name: 'Transfer', components: [
        _c('appbar', {'text': 'Send Money'}),
        _c('input', {'text': 'Recipient name'}),
        _c('input', {'text': 'Account number'}),
        _c('input', {'text': 'Amount'}),
        _c('text', {'text': 'No fees for this transfer', 'color': '#10B981', 'size': 12}),
        _c('button', {'text': 'Send', 'align': 'center', 'bg': '#0EA5E9', 'color': '#FFFFFF'}),
      ]),
      ScreenModel(id: uid(), name: 'History', components: [
        _c('appbar', {'text': 'Transactions'}),
        _c('card', {'text': 'Coffee Shop -12.50'}),
        _c('card', {'text': 'Salary +2,400'}),
        _c('card', {'text': 'Electricity -68.20'}),
        _c('card', {'text': 'Transfer to Sam -150'}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'travel',
    title: 'Travel',
    subtitle: 'Explore - Detail - Book',
    icon: Icons.flight_takeoff_outlined,
    color: const Color(0xFF14B8A6),
    build: () => [
      ScreenModel(id: uid(), name: 'Explore', components: [
        _c('appbar', {'text': 'Explore'}),
        _c('input', {'text': 'Where to?'}),
        _c('image', {'height': 200.0}),
        _c('heading', {'text': 'Popular destinations', 'size': 18}),
        _c('card', {'text': 'Bali - from 499'}),
        _c('card', {'text': 'Dubai - from 320'}),
      ]),
      ScreenModel(id: uid(), name: 'Detail', components: [
        _c('appbar', {'text': 'Bali'}),
        _c('image', {'height': 220.0}),
        _c('heading', {'text': 'Bali, Indonesia', 'size': 22}),
        _c('text', {'text': '499', 'color': '#14B8A6', 'size': 20, 'bold': true}),
        _c('text', {'text': 'Tropical paradise with beaches and culture.', 'color': '#6B7280'}),
        _c('button', {'text': 'Book Now', 'align': 'center', 'bg': '#14B8A6', 'color': '#FFFFFF'}),
      ]),
      ScreenModel(id: uid(), name: 'Book', components: [
        _c('appbar', {'text': 'Booking'}),
        _c('input', {'text': 'Full name'}),
        _c('input', {'text': 'Passport number'}),
        _c('input', {'text': 'Travel date'}),
        _c('checkbox', {'text': 'Travel insurance', 'on': true}),
        _c('button', {'text': 'Confirm Booking', 'align': 'center', 'bg': '#10B981', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
  IdeaDef(
    key: 'portfolio',
    title: 'Portfolio',
    subtitle: 'About - Work - Contact',
    icon: Icons.palette_outlined,
    color: const Color(0xFFEC4899),
    build: () => [
      ScreenModel(id: uid(), name: 'About', components: [
        _c('appbar', {'text': 'Portfolio'}),
        _c('avatar', {'size': 22, 'align': 'center'}),
        _c('heading', {'text': 'Jane Doe', 'size': 22, 'align': 'center'}),
        _c('text', {'text': 'Product Designer', 'color': '#6B7280', 'align': 'center'}),
        _c('divider', {}),
        _c('text', {'text': 'I design digital products with focus on simplicity.', 'color': '#6B7280'}),
        _c('button', {'text': 'See my work', 'align': 'center', 'bg': '#EC4899', 'color': '#FFFFFF'}),
      ]),
      ScreenModel(id: uid(), name: 'Work', components: [
        _c('appbar', {'text': 'Selected Work'}),
        _c('image', {'height': 180.0}),
        _c('heading', {'text': 'Fintech App', 'size': 16}),
        _c('text', {'text': 'Mobile banking experience', 'color': '#6B7280', 'size': 12}),
        _c('divider', {}),
        _c('image', {'height': 180.0}),
        _c('heading', {'text': 'Travel Booking', 'size': 16}),
        _c('text', {'text': 'End-to-end flight booking', 'color': '#6B7280', 'size': 12}),
      ]),
      ScreenModel(id: uid(), name: 'Contact', components: [
        _c('appbar', {'text': 'Get in Touch'}),
        _c('input', {'text': 'Your name'}),
        _c('input', {'text': 'Your email'}),
        _c('input', {'text': 'Message'}),
        _c('button', {'text': 'Send', 'align': 'center', 'bg': '#EC4899', 'color': '#FFFFFF'}),
      ]),
    ],
  ),
];
