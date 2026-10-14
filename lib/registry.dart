import 'package:flutter/material.dart';
import 'models.dart';

class ComponentDef {
  final String type, name, category;
  final IconData icon;
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
  'heading':  ComponentDef(type: 'heading',  icon: Icons.title,               name: 'Heading',  category: 'Basics',   fields: ['text', 'color', 'size', 'align', 'bold', 'italic', 'underline', 'letterSpacing', 'lineHeight', 'link']),
  'text':     ComponentDef(type: 'text',     icon: Icons.text_fields,         name: 'Text',     category: 'Basics',   fields: ['text', 'color', 'size', 'align', 'bold', 'italic', 'underline', 'letterSpacing', 'lineHeight', 'link']),
  'button':   ComponentDef(type: 'button',   icon: Icons.smart_button,        name: 'Button',   category: 'Basics',   fields: ['text', 'bg', 'color', 'size', 'align', 'bold', 'link']),
  'input':    ComponentDef(type: 'input',    icon: Icons.keyboard,            name: 'Input',    category: 'Basics',   fields: ['text', 'link']),
  'image':    ComponentDef(type: 'image',    icon: Icons.image_outlined,      name: 'Image',    category: 'Media',    fields: ['path', 'width', 'height', 'fit', 'link']),
  'avatar':   ComponentDef(type: 'avatar',   icon: Icons.person_outline,      name: 'Avatar',   category: 'Media',    fields: ['size', 'align', 'link']),
  'divider':  ComponentDef(type: 'divider',  icon: Icons.horizontal_rule,     name: 'Divider',  category: 'Layout',   fields: []),
  'spacer':   ComponentDef(type: 'spacer',   icon: Icons.space_bar,           name: 'Spacer',   category: 'Layout',   fields: ['size']),
  'card':     ComponentDef(type: 'card',     icon: Icons.credit_card,         name: 'Card',     category: 'Layout',   fields: ['text', 'link']),
  'appbar':   ComponentDef(type: 'appbar',   icon: Icons.web_asset,           name: 'App Bar',  category: 'Layout',   fields: ['text', 'bg', 'link']),
  'tabs':     ComponentDef(type: 'tabs',     icon: Icons.tab,                 name: 'Tabs',     category: 'Layout',   fields: ['text', 'color', 'link']),
  'progress': ComponentDef(type: 'progress', icon: Icons.linear_scale,        name: 'Progress', category: 'Controls', fields: ['link']),
  'slider':   ComponentDef(type: 'slider',   icon: Icons.tune,                name: 'Slider',   category: 'Controls', fields: ['link']),
  'switch':   ComponentDef(type: 'switch',   icon: Icons.toggle_on,           name: 'Switch',   category: 'Controls', fields: ['text', 'on', 'link']),
  'checkbox': ComponentDef(type: 'checkbox', icon: Icons.check_box_outlined,  name: 'Checkbox', category: 'Controls', fields: ['text', 'on', 'link']),
  'radio':    ComponentDef(type: 'radio',    icon: Icons.radio_button_checked,name: 'Radio',    category: 'Controls', fields: ['text', 'on', 'link']),
  'chip':     ComponentDef(type: 'chip',     icon: Icons.local_offer_outlined,name: 'Chip',     category: 'Controls', fields: ['text', 'bg', 'link']),
  'fab':      ComponentDef(type: 'fab',      icon: Icons.add_circle_outline,  name: 'FAB',      category: 'Controls', fields: ['bg', 'link']),
  'rating':   ComponentDef(type: 'rating',   icon: Icons.star_outline,        name: 'Rating',   category: 'Controls', fields: ['size', 'align', 'link']),
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
    'bold': type == 'heading',
    'italic': false,
    'underline': false,
    'letterSpacing': 0.0,
    'lineHeight': 1.4,
    'path': '',
    'width': 0.0,
    'height': 160.0,
    'fit': 'cover',
  };
  if (type == 'button') props['color'] = '#FFFFFF';
  return ComponentModel(id: uid(), type: type, props: props);
}
