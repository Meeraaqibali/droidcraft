import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _argb(String? hex) {
  final h = (hex ?? '#111827').replaceAll('#', '');
  if (h.length == 6) return '#FF$h';
  if (h.length == 8) return '#$h';
  return '#FF000000';
}

String _grav(dynamic a) {
  if (a == 'center') return 'center';
  if (a == 'right') return 'end';
  return 'start';
}

String _slug(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

String _xmlFor(ComponentModel c, int i) {
  final p = c.props;
  final text = _esc(p['text']?.toString() ?? '');
  final color = _argb(p['color']?.toString());
  final bg = _argb(p['bg']?.toString());
  final size = p['size'] ?? 14;
  final grav = _grav(p['align']);
  final id = '${c.type}_$i';

  switch (c.type) {
    case 'heading':
      return '  <TextView\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:text="$text"\n'
          '      android:textColor="$color"\n'
          '      android:textSize="${size}sp"\n'
          '      android:textStyle="bold"\n'
          '      android:gravity="$grav" />';

    case 'text':
      return '  <TextView\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:text="$text"\n'
          '      android:textColor="$color"\n'
          '      android:textSize="${size}sp"\n'
          '      android:gravity="$grav" />';

    case 'button':
      return '  <Button\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="wrap_content"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:layout_gravity="$grav"\n'
          '      android:text="$text"\n'
          '      android:textColor="$color"\n'
          '      android:backgroundTint="$bg" />';

    case 'input':
      return '  <EditText\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:hint="$text"\n'
          '      android:padding="14dp"\n'
          '      android:background="@drawable/input_bg" />';

    case 'image':
      return '  <ImageView\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="120dp"\n'
          '      android:scaleType="centerCrop"\n'
          '      android:src="@drawable/placeholder" />';

    case 'avatar':
      return '  <ImageView\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="${size * 4}dp"\n'
          '      android:layout_height="${size * 4}dp"\n'
          '      android:layout_gravity="$grav"\n'
          '      android:src="@drawable/avatar_placeholder" />';

    case 'divider':
      return '  <View\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="1dp"\n'
          '      android:background="#E5E7EB" />';

    case 'spacer':
      return '  <Space\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="${size}dp" />';

    case 'card':
      return '  <androidx.cardview.widget.CardView\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      app:cardCornerRadius="12dp"\n'
          '      app:cardElevation="2dp">\n'
          '    <LinearLayout\n'
          '        android:layout_width="match_parent"\n'
          '        android:layout_height="wrap_content"\n'
          '        android:orientation="vertical"\n'
          '        android:padding="16dp">\n'
          '      <TextView\n'
          '          android:layout_width="wrap_content"\n'
          '          android:layout_height="wrap_content"\n'
          '          android:text="$text"\n'
          '          android:textSize="15sp"\n'
          '          android:textStyle="bold" />\n'
          '      <TextView\n'
          '          android:layout_width="wrap_content"\n'
          '          android:layout_height="wrap_content"\n'
          '          android:text="Supporting text for this card."\n'
          '          android:textColor="#6B7280"\n'
          '          android:textSize="12sp" />\n'
          '    </LinearLayout>\n'
          '  </androidx.cardview.widget.CardView>';

    case 'tabs':
      return '  <com.google.android.material.tabs.TabLayout\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      app:tabIndicatorColor="$color">\n'
          '    <com.google.android.material.tabs.TabItem\n'
          '        android:text="$text" />\n'
          '    <com.google.android.material.tabs.TabItem\n'
          '        android:text="Tab Two" />\n'
          '    <com.google.android.material.tabs.TabItem\n'
          '        android:text="Tab Three" />\n'
          '  </com.google.android.material.tabs.TabLayout>';

    case 'progress':
      return '  <ProgressBar\n'
          '      android:id="@+id/$id"\n'
          '      style="?android:attr/progressBarStyleHorizontal"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="6dp"\n'
          '      android:progress="60"\n'
          '      android:progressTint="#6200EE" />';

    case 'slider':
      return '  <SeekBar\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:progress="50" />';

    case 'switch':
      return '  <Switch\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:text="$text"\n'
          '      android:checked="${p['on'] == true ? 'true' : 'false'}" />';

    case 'checkbox':
      return '  <CheckBox\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:text="$text"\n'
          '      android:checked="${p['on'] == true ? 'true' : 'false'}" />';

    case 'radio':
      return '  <RadioButton\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="match_parent"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:text="$text"\n'
          '      android:checked="${p['on'] == true ? 'true' : 'false'}" />';

    case 'chip':
      return '  <com.google.android.material.chip.Chip\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="wrap_content"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:layout_gravity="$grav"\n'
          '      android:text="$text"\n'
          '      android:backgroundTint="$bg" />';

    case 'fab':
      return '  <com.google.android.material.floatingactionbutton.FloatingActionButton\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="wrap_content"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:layout_gravity="end"\n'
          '      android:src="@android:drawable/ic_input_add"\n'
          '      app:backgroundTint="$bg" />';

    case 'rating':
      return '  <RatingBar\n'
          '      android:id="@+id/$id"\n'
          '      android:layout_width="wrap_content"\n'
          '      android:layout_height="wrap_content"\n'
          '      android:layout_gravity="$grav"\n'
          '      android:numStars="5"\n'
          '      android:rating="4" />';

    default:
      return '  <!-- Unsupported: ${c.type} -->';
  }
}

String exportXml(ScreenModel s) {
  final over = s.codeOverrides['xml'];
  if (over != null && over.isNotEmpty) return over;
  final name = _slug(s.name);
  final body = s.components.asMap().entries.map((e) => _xmlFor(e.value, e.key)).join('\n\n');
  return '<?xml version="1.0" encoding="utf-8"?>\n'
      '<!-- Generated by DroidCraft · $name -->\n'
      '<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"\n'
      '    xmlns:app="http://schemas.android.com/apk/res-auto"\n'
      '    android:layout_width="match_parent"\n'
      '    android:layout_height="match_parent">\n\n'
      '  <LinearLayout\n'
      '      android:layout_width="match_parent"\n'
      '      android:layout_height="wrap_content"\n'
      '      android:orientation="vertical"\n'
      '      android:background="${_argb(s.bg)}"\n'
      '      android:padding="16dp">\n\n'
      '$body\n\n'
      '  </LinearLayout>\n'
      '</ScrollView>\n';
}

String exportKotlin(Project p, ScreenModel s) {
  final over = s.codeOverrides['kotlin'];
  if (over != null && over.isNotEmpty) return over;
  final cls = s.name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '') + 'Activity';
  final layout = 'activity_${_slug(s.name)}';
  final buf = StringBuffer();
  buf.writeln('package com.droidcraft.generated');
  buf.writeln();
  buf.writeln('import android.graphics.Color');
  buf.writeln('import android.os.Bundle');
  buf.writeln('import android.view.View');
  buf.writeln('import android.widget.*');
  buf.writeln('import androidx.appcompat.app.AppCompatActivity');
  buf.writeln();
  buf.writeln('/*');
  buf.writeln(' * Generated by DroidCraft');
  buf.writeln(' * Project: ${p.name}');
  buf.writeln(' * Screen:  ${s.name}');
  buf.writeln(' * Components: ${s.components.length}');
  buf.writeln(' *');
  buf.writeln(' * You can edit any property below and tap Save.');
  buf.writeln(' * DroidCraft will try to apply your changes back to the canvas.');
  buf.writeln(' */');
  buf.writeln('class $cls : AppCompatActivity() {');
  buf.writeln('    override fun onCreate(savedInstanceState: Bundle?) {');
  buf.writeln('        super.onCreate(savedInstanceState)');
  buf.writeln('        setContentView(R.layout.$layout)');
  if (s.components.isNotEmpty) {
    buf.writeln();
    buf.writeln('        // Widget properties');
    for (var i = 0; i < s.components.length; i++) {
      final c = s.components[i];
      final id = '${c.type}_$i';
      final tv = _kotlinType(c.type);
      final text = (c.props['text'] ?? '').toString().replaceAll('"', r'\"');
      if (c.props['text'] != null && tv != null) {
        buf.writeln('        findViewById<$tv>(R.id.$id).text = "$text"');
      }
      if (c.props['on'] == true && (c.type == 'switch' || c.type == 'checkbox')) {
        buf.writeln('        findViewById<CompoundButton>(R.id.$id).isChecked = true');
      }
      final link = (c.props['link'] ?? '').toString();
      if (link.isNotEmpty) {
        final target = p.screens.firstWhere((x) => x.id == link,
            orElse: () => ScreenModel(id: '', name: 'Next'));
        final targetCls =
            target.name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '') + 'Activity';
        buf.writeln('        findViewById<View>(R.id.$id).setOnClickListener {');
        buf.writeln('            startActivity(android.content.Intent(this, $targetCls::class.java))');
        buf.writeln('        }');
      }
    }
  }
  buf.writeln('    }');
  buf.writeln('}');
  return buf.toString();
}

String? _kotlinType(String type) {
  switch (type) {
    case 'heading':
    case 'text':
      return 'TextView';
    case 'button':
      return 'Button';
    case 'input':
      return 'EditText';
    case 'image':
      return 'ImageView';
    case 'switch':
      return 'Switch';
    case 'checkbox':
      return 'CheckBox';
    case 'radio':
      return 'RadioButton';
    case 'chip':
      return 'TextView';
    case 'rating':
      return 'RatingBar';
  }
  return null;
}

void showExportSheet(BuildContext context, Project project, ScreenModel screen) {
  final xml = exportXml(screen);
  final kt = exportKotlin(project, screen);
  final xmlName = 'activity_${_slug(screen.name)}.xml';
  final ktName = '${screen.name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}Activity.kt';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFF5F6FA),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) => DefaultTabController(
        length: 2,
        child: Column(children: [
          const SizedBox(height: 10),
          Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              const Icon(Icons.download_outlined, color: Color(0xFF4F46E5)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Export',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('${screen.components.length} components · ${screen.name}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ]),
          ),
          const TabBar(
            labelColor: Color(0xFF4F46E5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4F46E5),
            tabs: [
              Tab(text: 'Android XML'),
              Tab(text: 'Kotlin'),
            ],
          ),
          Expanded(
            child: TabBarView(children: [
              _codeTab(ctx, scroll, xmlName, xml),
              _codeTab(ctx, scroll, ktName, kt),
            ]),
          ),
        ]),
      ),
    ),
  );
}

Widget _codeTab(BuildContext ctx, ScrollController scroll, String filename, String code) {
  return ListView(
    controller: scroll,
    padding: const EdgeInsets.all(16),
    children: [
      Row(children: [
        Expanded(
          child: Text(filename,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F46E5))),
        ),
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Copied $filename')));
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy'),
        ),
      ]),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SelectableText(
          code,
          style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Color(0xFFE2E8F0),
              height: 1.5),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Paste into Android Studio:\n'
        '• XML   → app/src/main/res/layout/\n'
        '• Kotlin → app/src/main/java/com/droidcraft/generated/',
        style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
      ),
    ],
  );
}
