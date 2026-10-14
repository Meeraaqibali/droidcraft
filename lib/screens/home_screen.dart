import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../services.dart';
import '../templates.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final auth = context.watch<AuthService>();
    final projSvc = context.watch<ProjectService>();
    final theme = context.watch<ThemeService>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.smartphone, color: Color(0xFF4F46E5), size: 28),
          SizedBox(width: 8),
          Text('DroidCraft',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        ]),
        actions: [
          IconButton(
            icon: Icon(theme.mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeService>().toggle(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _accountSheet(context),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF4F46E5),
                child: Text((auth.user?['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProjectService>().refresh(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Hello, ${auth.user?['name'] ?? 'there'} 👋',
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            const Text("Let's build something beautiful today.",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 22),
            InkWell(
              onTap: () => _newProjectSheet(context, null),
              borderRadius: BorderRadius.circular(22),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: const Text('+ Create Project',
                        style: TextStyle(
                            color: Color(0xFF4F46E5), fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 22),
            Row(children: [
              _stat('Projects', projSvc.projects.length),
              const SizedBox(width: 10),
              _stat('Screens', projSvc.totalScreens),
              const SizedBox(width: 10),
              _stat('Widgets', projSvc.totalComponents),
            ]),
            const SizedBox(height: 26),
            _sectionTitle('QUICK START'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: ['blank', 'login', 'profile', 'dashboard'].map((k) {
                final t = templates[k]!;
                return _templateCard(context, k, t);
              }).toList(),
            ),
            const SizedBox(height: 26),
            _sectionTitle('EXPLORE TEMPLATES'),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final t = templates.values.elementAt(i);
                  return SizedBox(
                      width: 150,
                      child: _templateCard(context, t.key, t, compact: true));
                },
              ),
            ),
            const SizedBox(height: 26),
            Container(
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
                const Text('💡', style: TextStyle(fontSize: 28)),
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
                        'Select any widget on the canvas, then tap it again to open properties and link it to another screen.',
                        style: TextStyle(
                            color: Color(0xFF92400E), fontSize: 12, height: 1.4)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 26),
            _sectionTitle('YOUR PROJECTS'),
            if (projSvc.projects.isEmpty)
              _emptyState(context)
            else
              ...projSvc.projects.map((p) => _projectTile(context, p, projSvc)),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 4)]),
          child: Column(children: [
            Text('$value',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5))),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
          ]),
        ),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 1)),
      );

  Widget _templateCard(BuildContext ctx, String key, TemplateDef t,
      {bool compact = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _newProjectSheet(ctx, key),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.icon,
                  style: TextStyle(
                      fontSize: compact ? 28 : 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(t.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
      ),
    );
  }

  Widget _emptyState(BuildContext ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(children: [
          const Text('📱', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No projects yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Create your first Android UI mockup in seconds.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _newProjectSheet(ctx, 'blank'),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22))),
            child: const Text('Create Project'),
          ),
        ]),
      );

  Widget _projectTile(BuildContext ctx, Project p, ProjectService svc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4)]),
      child: Row(children: [
        Expanded(
          child: InkWell(
            onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                builder: (_) => EditorScreen(project: p))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${p.screens.length} screen${p.screens.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Edited ${_timeAgo(p.updatedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
          onPressed: () => _confirmDelete(ctx, p, svc),
        ),
      ]),
    );
  }

  void _confirmDelete(BuildContext ctx, Project p, ProjectService svc) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: const Text('Delete project?'),
              content:
                  Text('"${p.name}" and all its screens will be permanently removed.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await svc.delete(p.id);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ));
  }

  void _accountSheet(BuildContext ctx) {
    final auth = context.read<AuthService>();
    showModalBottomSheet(
        context: ctx,
        builder: (_) => Padding(
              padding: const EdgeInsets.all(22),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(auth.user?['name'] ?? 'Guest',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                Text(auth.user?['email'] ?? '',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      auth.logout();
                    },
                    child: const Text('Sign Out'),
                  ),
                ),
              ]),
            ));
  }

  void _newProjectSheet(BuildContext ctx, String? preset) {
    final nameCtrl = TextEditingController(
        text: preset != null ? '${templates[preset]!.name} App' : '');
    String selected = preset ?? 'blank';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSt) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Project',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Name your app and pick a starting template',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Project name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('TEMPLATE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
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
                                ? const Color(0xFFEEF2FF)
                                : Colors.white,
                            border: Border.all(
                                color: on
                                    ? const Color(0xFF4F46E5)
                                    : const Color(0xFFE5E7EB),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(t.icon,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(width: 8),
                                Text(t.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
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
                            backgroundColor: const Color(0xFF4F46E5)),
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final tpl = templates[selected]!;
                          final svc = ctx.read<ProjectService>();
                          Navigator.pop(ctx);
                          try {
                            final p = await svc.create(
                                name.isEmpty ? tpl.name : name,
                                selected,
                                tpl.build());
                            if (!ctx.mounted) return;
                            Navigator.of(ctx).push(MaterialPageRoute(
                                builder: (_) => EditorScreen(project: p)));
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Failed: $e')));
                          }
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
