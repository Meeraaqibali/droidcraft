import 'models.dart';

class ComponentDef {
  final String type, icon, name, category;
  final List<String> fields;
  const ComponentDef({
    required this.type,
    required this.icon,
    required this.name,
    required this.category,
    required this.fields,
  });
}

const Map<String, ComponentDef> registry = {
  'heading':  ComponentDef(type: 'heading',  icon: 'H', name: 'Heading',  category: 'Basics',   fields: ['text', 'color', 'size', 'align', 'link']),
  'text':     ComponentDef(type: 'text',     icon: 'T', name: 'Text',     category: 'Basics',   fields: ['text', 'color', 'size', 'align', 'link']),
  'button':   ComponentDef(type: 'button',   icon: 'B', name: 'Button',   category: 'Basics',   fields: ['text', 'bg', 'color', 'size', 'align', 'link']),
  'input':    ComponentDef(type: 'input',    icon: 'I', name: 'Input',    category: 'Basics',   fields: ['text', 'link']),
  'image':    ComponentDef(type: 'image',    icon: 'P', name: 'Image',    category: 'Media',    fields: ['link']),
  'avatar':   ComponentDef(type: 'avatar',   icon: 'A', name: 'Avatar',   category: 'Media',    fields: ['size', 'align', 'link']),
  'divider':  ComponentDef(type: 'divider',  icon: '-', name: 'Divider',  category: 'Layout',   fields: []),
  'spacer':   ComponentDef(type: 'spacer',   icon: ' ', name: 'Spacer',   category: 'Layout',   fields: ['size']),
  'card':     ComponentDef(type: 'card',     icon: 'C', name: 'Card',     category: 'Layout',   fields: ['text', 'link']),
  'appbar':   ComponentDef(type: 'appbar',   icon: 'N', name: 'App Bar',  category: 'Layout',   fields: ['text', 'bg', 'link']),
  'tabs':     ComponentDef(type: 'tabs',     icon: '=', name: 'Tabs',     category: 'Layout',   fields: ['text', 'color', 'link']),
  'progress': ComponentDef(type: 'progress', icon: '>', name: 'Progress', category: 'Controls', fields: ['link']),
  'slider':   ComponentDef(type: 'slider',   icon: 'S', name: 'Slider',   category: 'Controls', fields: ['link']),
  'switch':   ComponentDef(type: 'switch',   icon: 'O', name: 'Switch',   category: 'Controls', fields: ['text', 'on', 'link']),
  'checkbox': ComponentDef(type: 'checkbox', icon: 'V', name: 'Checkbox', category: 'Controls', fields: ['text', 'on', 'link']),
  'radio':    ComponentDef(type: 'radio',    icon: 'o', name: 'Radio',    category: 'Controls', fields: ['text', 'on', 'link']),
  'chip':     ComponentDef(type: 'chip',     icon: '#', name: 'Chip',     category: 'Controls', fields: ['text', 'bg', 'link']),
  'fab':      ComponentDef(type: 'fab',      icon: '+', name: 'FAB',      category: 'Controls', fields: ['bg', 'link']),
  'rating':   ComponentDef(type: 'rating',   icon: '*', name: 'Rating',   category: 'Controls', fields: ['size', 'align', 'link']),
};

ComponentModel makeComponent(String type) {
  final def = registry[type]!;
  final props = <String, dynamic>{
    'text': def.name,
    'color': '#111827',
    'size': type == 'heading'
        ? 22
        : type == 'spacer'
            ? 24
            : type == 'avatar'
                ? 16
                : type == 'rating'
                    ? 20
                    : 14,
    'align': 'left',
    'bg': '#6200EE',
    'on': false,
    'link': '',
  };
  if (type == 'button') props['color'] = '#FFFFFF';
  return ComponentModel(id: uid(), type: type, props: props);
}
