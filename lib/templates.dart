import 'models.dart';
import 'registry.dart';

class TemplateDef {
  final String key, name, icon;
  final List<ScreenModel> Function() build;
  const TemplateDef({required this.key, required this.name, required this.icon, required this.build});
}

ComponentModel _c(String t, Map<String, dynamic> p) {
  final c = makeComponent(t);
  c.props.addAll(p);
  return c;
}

final Map<String, TemplateDef> templates = {
  'blank': TemplateDef(
    key: 'blank', name: 'Blank', icon: 'B',
    build: () => [ScreenModel(id: uid(), name: 'Home')],
  ),
  'login': TemplateDef(
    key: 'login', name: 'Login', icon: 'L',
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
    key: 'profile', name: 'Profile', icon: 'P',
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
  'feed': TemplateDef(
    key: 'feed', name: 'Feed', icon: 'F',
    build: () => [
      ScreenModel(id: uid(), name: 'Feed', components: [
        _c('heading', {'text': 'Home Feed', 'size': 22}),
        _c('image', {}),
        _c('card', {'text': 'Post from Alex'}),
        _c('card', {'text': 'Post from Sam'}),
        _c('text', {'text': 'All caught up!', 'align': 'center', 'color': '#6B7280', 'size': 13}),
      ]),
    ],
  ),
  'settings': TemplateDef(
    key: 'settings', name: 'Settings', icon: 'S',
    build: () => [
      ScreenModel(id: uid(), name: 'Settings', components: [
        _c('heading', {'text': 'Settings', 'size': 22}),
        _c('switch', {'text': 'Dark mode', 'on': true}),
        _c('switch', {'text': 'Notifications'}),
        _c('divider', {}),
        _c('checkbox', {'text': 'Auto-save projects', 'on': true}),
        _c('radio', {'text': 'Use mobile data', 'on': true}),
        _c('progress', {}),
        _c('slider', {}),
      ]),
    ],
  ),
  'dashboard': TemplateDef(
    key: 'dashboard', name: 'Dashboard', icon: 'D',
    build: () => [
      ScreenModel(id: uid(), name: 'Dashboard', components: [
        _c('heading', {'text': 'Dashboard', 'size': 22}),
        _c('card', {'text': 'Revenue - \$12,480'}),
        _c('card', {'text': 'Active users - 3,214'}),
        _c('progress', {}),
        _c('text', {'text': 'Weekly performance', 'color': '#6B7280', 'size': 12}),
        _c('slider', {}),
        _c('button', {'text': 'View Report', 'align': 'center'}),
      ]),
    ],
  ),
};
