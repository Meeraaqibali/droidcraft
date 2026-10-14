import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ideas.dart';
import '../models.dart';
import '../nav.dart';
import '../services.dart';
import '../templates.dart';
import '../theme.dart';
import 'editor_screen.dart';
import '../widgets/pressable.dart';
import '../widgets/exit_confirm.dart';
import '../widgets/animated_list.dart';
import 'guide_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _quickKeys = ['blank', 'login', 'profile', 'dashboard'];

  String _timeAgo(DateTime ts) {
    final d = DateTime.now().difference(ts);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 30) return '${d.inDays}d ago';
    return ts.toLocal().toString().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final projSvc = context.watch<ProjectService>();
    final theme = context.watch<ThemeService>();
    final exploreKeys =
        templates.keys.where((k) => !_quickKeys.contains(k)).toList();

    return ExitConfirm(
      child: Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.android, color: AppTheme.primary, size: 26),
          SizedBox(width: 8),
          Text('DroidCraft', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        ]),
        actions: [
          IconButton(
            icon: Icon(theme.mode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => context.read<ThemeService>().toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'User Guide',
            onPressed: () =>
                Navigator.of(context).push(slideRoute(const GuideScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.of(context).push(slideRoute(const SettingsScreen())),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 80 + MediaQuery.of(context).padding.bottom),
        children: [
          Text('Hello 👋',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: DC.text(context))),
          const SizedBox(height: 4),
          Text("Let's build something beautiful today.",
              style: TextStyle(fontSize: 14, color: DC.muted(context))),
          const SizedBox(height: 22),
          _createCard(context),
          const SizedBox(height: 22),
          Row(children: [
            _stat(context, 'Projects', projSvc.projects.length),
            const SizedBox(width: 10),
            _stat(context, 'Screens', projSvc.totalScreens),
            const SizedBox(width: 10),
            _stat(context, 'Widgets', projSvc.totalComponents),
          ]),
          const SizedBox(height: 26),
          _sectionTitle(context, 'QUICK START'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: _quickKeys
                .map((k) => _templateCard(context, k, templates[k]!))
                .toList(),
          ),
          const SizedBox(height: 26),
          _sectionTitle(context, 'EXPLORE MORE TEMPLATES'),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: exploreKeys.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final key = exploreKeys[i];
                return SizedBox(
                    width: 150,
                    child: _templateCard(context, key, templates[key]!,
                        compact: true));
              },
            ),
          ),
          const SizedBox(height: 26),
          _sectionTitle(context, 'QUICK TOOLS'),
          Row(children: [
            _tool(context, Icons.dark_mode, 'Theme',
                () => context.read<ThemeService>().toggle()),
            const SizedBox(width: 10),
            _tool(context, Icons.bolt, 'Templates',
                () => _newProjectSheet(context, 'signup')),
            const SizedBox(width: 10),
            _tool(context, Icons.settings, 'Settings',
                () => Navigator.of(context).push(slideRoute(const SettingsScreen()))),
          ]),
          const SizedBox(height: 26),
          _tipCard(context),
          const SizedBox(height: 26),
          _sectionTitle(context, 'WHAT CAN YOU BUILD?'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: ideas.map((idea) => _ideaCard(ctx, idea)).toList(),
          ),
          const SizedBox(height: 26),
          _sectionTitle(context, 'YOUR PROJECTS'),
          if (projSvc.projects.isEmpty)
            _emptyState(context)
          else
            ...projSvc.projects.map((p) => _projectTile(context, p, projSvc)),
        ],
      ),
      ),
    );
  }

  Widget _createCard(BuildContext ctx) => Pressable(
        onTap: () => _newProjectSheet(ctx, null),
        scale: 0.98,
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Color(0x594F46E5), blurRadius: 24, offset: Offset(0, 12))
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Start a new project',
                style: TextStyle(
                    color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Pick a template and start dragging components onto the canvas.',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add, color: AppTheme.primary, size: 18),
                SizedBox(width: 6),
                Text('Create Project',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
      );

  Widget _stat(BuildContext ctx, String label, int value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: DC.surface(ctx),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 4)],
          ),
          child: Column(children: [
            Text('$value',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    color: DC.muted(ctx),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
          ]),
        ),
      );

  Widget _sectionTitle(BuildContext ctx, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: DC.muted(ctx),
                letterSpacing: 1)),
      );

  Widget _templateCard(BuildContext ctx, String key, TemplateDef t,
      {bool compact = false}) {
    return Pressable(
      onTap: () => _newProjectSheet(ctx, key),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: DC.surface(ctx),
          border: Border.all(color: DC.border(ctx)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(t.icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(t.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DC.text(ctx))),
        ]),
      ),
    );
  }

  Widget _tool(BuildContext ctx, IconData icon, String label, VoidCallback onTap) =>
      Expanded(
        child: Pressable(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: DC.surface(ctx),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DC.border(ctx)),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
            ),
            child: Column(children: [
              Icon(icon, color: AppTheme.primary, size: 22),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: DC.text(ctx))),
            ]),
          ),
        ),
      );

  Widget _tipCard(BuildContext ctx) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x26F59E0B), blurRadius: 20, offset: Offset(0, 8))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_outline,
                color: Color(0xFFF59E0B), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Pro tip',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF78350F),
                      fontSize: 13)),
              SizedBox(height: 4),
              Text(
                  'Tap a widget to select, tap again to edit its properties and link it to another screen.',
                  style: TextStyle(
                      color: Color(0xFF92400E), fontSize: 12, height: 1.4)),
            ]),
          ),
        ]),
      );

  Widget _emptyState(BuildContext ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DC.surface(ctx),
          border: Border.all(color: DC.border(ctx), width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(children: [
          Icon(Icons.phone_android, size: 44, color: DC.muted(ctx)),
          const SizedBox(height: 12),
          Text('No projects yet',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DC.text(ctx))),
          const SizedBox(height: 6),
          Text('Tap a template above or start blank.',
              style: TextStyle(fontSize: 12, color: DC.muted(ctx)),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _newProjectSheet(ctx, 'blank'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Project'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ]),
      );


  Widget _ideaCard(BuildContext ctx, IdeaDef idea) {
    return Pressable(
      onTap: () => _launchIdea(ctx, idea),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DC.inputFill(ctx),
          border: Border.all(color: DC.border(ctx)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: idea.color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(idea.icon, color: idea.color, size: 20),
            ),
            const Spacer(),
            Text(idea.title,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: DC.text(ctx))),
            const SizedBox(height: 2),
            Text(idea.subtitle,
                style: TextStyle(color: DC.muted(ctx), fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Future<void> _launchIdea(BuildContext ctx, IdeaDef idea) async {
    final svc = ctx.read<ProjectService>();
    final p = await svc.create('${idea.title} App', 'idea_${idea.key}', idea.build());
    if (!ctx.mounted) return;
    Navigator.of(ctx).push(slideRoute(EditorScreen(project: p)));
  }

  Widget _projectTile(BuildContext ctx, Project p, ProjectService svc) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: DC.surface(ctx),
          border: Border.all(color: DC.border(ctx)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4)],
        ),
        child: Row(children: [
          Expanded(
            child: InkWell(
              onTap: () =>
                  Navigator.of(ctx).push(slideRoute(EditorScreen(project: p))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DC.text(ctx))),
                const SizedBox(height: 4),
                const Text('', style: TextStyle(fontSize: 0)),
                Text('${p.screens.length} screen${p.screens.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Edited ${_timeAgo(p.updatedAt)}',
                    style: TextStyle(fontSize: 12, color: DC.muted(ctx))),
              ]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed: () => _confirmDelete(ctx, p, svc),
          ),
        ]),
      );

  void _confirmDelete(BuildContext ctx, Project p, ProjectService svc) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('"${p.name}" and all its screens will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              await svc.delete(p.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _newProjectSheet(BuildContext ctx, String? preset) {
    final nameCtrl = TextEditingController(
        text: preset != null ? '${templates[preset]!.name} App' : '');
    String selected = preset ?? 'blank';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: DC.surface(ctx),
      builder: (_) => StatefulBuilder(
        builder: (context, setSt) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('New Project',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DC.text(context))),
              const SizedBox(height: 4),
              Text('Name your app and pick a starting template',
                  style: TextStyle(color: DC.muted(context), fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: DC.text(context)),
                decoration: InputDecoration(
                  labelText: 'Project name',
                  labelStyle: TextStyle(color: DC.muted(context)),
                  filled: true,
                  fillColor: DC.inputFill(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Text('TEMPLATE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: DC.muted(context),
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: templates.values.map((t) {
                  final on = t.key == selected;
                  return InkWell(
                    onTap: () => setSt(() => selected = t.key),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: on
                            ? AppTheme.primary.withOpacity(0.12)
                            : DC.inputFill(context),
                        border: Border.all(
                          color: on ? AppTheme.primary : DC.border(context),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(t.icon,
                            size: 22,
                            color: on ? AppTheme.primary : DC.muted(context)),
                        const SizedBox(width: 8),
                        Text(t.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: DC.text(context))),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary),
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final tpl = templates[selected]!;
                      final svc = ctx.read<ProjectService>();
                      Navigator.pop(ctx);
                      final p = await svc.create(
                          name.isEmpty ? tpl.name : name, selected, tpl.build());
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).push(slideRoute(EditorScreen(project: p)));
                    },
                    child: const Text('Create'),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
