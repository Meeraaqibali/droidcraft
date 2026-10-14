import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Guide')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _intro(context),
          const SizedBox(height: 24),
          _sectionTitle(context, 'WHAT IS DROIDCRAFT?'),
          _card(context, [
            _paragraph(context,
                'DroidCraft is a visual Android UI builder. You drag widgets onto a phone canvas, style them, and export real Android XML layouts and Kotlin code that you can use in any Android project.'),
          ]),
          const SizedBox(height: 24),
          _sectionTitle(context, 'QUICK START'),
          _card(context, [
            _step(context, 1, 'Create a project',
                'Tap Create Project on Home and pick a template like Login or Blank.'),
            _divider(context),
            _step(context, 2, 'Add widgets',
                'Tap the + button at the bottom of the editor to open the widget library. Choose from 19 components.'),
            _divider(context),
            _step(context, 3, 'Style widgets',
                'Tap a widget once to select it, tap it again to open properties. Change text, color, size, style, radius, padding.'),
            _divider(context),
            _step(context, 4, 'Link screens',
                'In properties, use "Tap to go to screen" to make a widget navigate. Or open the Flow builder (tree icon) to chain screens.'),
            _divider(context),
            _step(context, 5, 'Preview and export',
                'Tap Preview to test. Tap the download icon to see the XML and Kotlin. Tap the code icon to edit the code directly.'),
          ]),
          const SizedBox(height: 24),
          _sectionTitle(context, 'HOW XML EXPORT WORKS'),
          _card(context, [
            _paragraph(context,
                'DroidCraft converts every widget on your screen into real Android XML. Example: a Button with text "Sign In" and purple background becomes:'),
            _code(context,
                '<Button\n    android:text="Sign In"\n    android:textColor="#FFFFFFFF"\n    android:backgroundTint="#FF6200EE" />'),
            _paragraph(context,
                'Where to put the XML: In Android Studio, paste it into app/src/main/res/layout/activity_yourscreen.xml. Any Android project reads this folder automatically.'),
          ]),
          const SizedBox(height: 24),
          _sectionTitle(context, 'HOW KOTLIN EXPORT WORKS'),
          _card(context, [
            _paragraph(context,
                'The Kotlin file is the Activity that loads your XML layout. Example:'),
            _code(context,
                'class LoginActivity : AppCompatActivity() {\n    override fun onCreate(savedInstanceState: Bundle?) {\n        super.onCreate(savedInstanceState)\n        setContentView(R.layout.activity_login)\n    }\n}'),
            _paragraph(context,
                'Where to put it: app/src/main/java/com/yourpackage/LoginActivity.kt. Register it in AndroidManifest.xml.'),
          ]),
          const SizedBox(height: 24),
          _sectionTitle(context, 'BUILD AN APK FROM TERMUX'),
          _card(context, [
            _paragraph(context,
                'Termux alone cannot build Android APKs because it has no Android SDK. Three working options:'),
            _heading(context, 'Option 1 - GitHub Actions (easiest)'),
            _paragraph(context,
                'Push your project to GitHub. Add a workflow file that runs flutter build apk on every push. GitHub builds the APK in the cloud, you download it. DroidCraft itself uses this exact method.'),
            _heading(context, 'Option 2 - Android Studio on a PC'),
            _paragraph(context,
                'Copy the exported XML and Kotlin into a new Android Studio project. Build then Build APK.'),
            _heading(context, 'Option 3 - proot-distro Ubuntu in Termux'),
            _paragraph(context,
                'Install a full Ubuntu inside Termux, then install the Android SDK and Gradle. Heavy but works. Commands:'),
            _code(context,
                'pkg install proot-distro\nproot-distro install ubuntu\nproot-distro login ubuntu\napt update && apt install -y openjdk-17-jdk wget unzip\nexport ANDROID_HOME=~\\/android-sdk\nmkdir -p \\$ANDROID_HOME/cmdline-tools\nwget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip\nunzip commandlinetools-linux-*.zip -d \\$ANDROID_HOME/cmdline-tools\nyes | \\$ANDROID_HOME/cmdline-tools/cmdline-tools/bin/sdkmanager --licenses\n\\$ANDROID_HOME/cmdline-tools/cmdline-tools/bin/sdkmanager "platforms;android-34" "build-tools;34.0.0"\ncd /path/to/your/android/project\n./gradlew assembleRelease'),
          ]),
          const SizedBox(height: 24),
          _sectionTitle(context, 'CREATE A FULL APP FROM YOUR DESIGN'),
          _card(context, [
            _paragraph(context,
                'In the editor, tap the code icon (top right). You will see two tabs:'),
            _bullet(context, 'XML - the layout file for this screen'),
            _bullet(context, 'Kotlin - the Activity for this screen'),
            _paragraph(context,
                'Edit either tab, then tap Save. Your edits are stored for that screen and used by Export. Tap Reset to regenerate from the design.'),
          ]),
          const SizedBox(height: 24),
          _sectionTitle(context, 'TIPS'),
          _card(context, [
            _bullet(context, 'Long-press a screen tab to drag and reorder'),
            _bullet(context, 'Long-press a card in Flow builder to reorder screens'),
            _bullet(context, 'Tap a widget twice (slowly) to open properties'),
            _bullet(context, 'Use the download icon to see the code anytime'),
            _bullet(context, 'Use the code editor to edit XML and Kotlin'),
            _bullet(context, 'Settings has Backup and Restore - export all projects as JSON'),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _intro(BuildContext ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x594F46E5), blurRadius: 20, offset: Offset(0, 10))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Icon(Icons.menu_book_outlined, color: Colors.white, size: 32),
          SizedBox(height: 12),
          Text('Welcome to DroidCraft',
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('A 5-minute guide to designing, exporting, and building Android apps.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
        ]),
      );

  Widget _sectionTitle(BuildContext ctx, String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(t,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: DC.muted(ctx),
                letterSpacing: 1)),
      );

  Widget _card(BuildContext ctx, List<Widget> children) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: DC.surface(ctx),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DC.border(ctx)),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _paragraph(BuildContext ctx, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(text,
            style: TextStyle(fontSize: 13, height: 1.55, color: DC.text(ctx))),
      );

  Widget _heading(BuildContext ctx, String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Text(t,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: DC.text(ctx))),
      );

  Widget _bullet(BuildContext ctx, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  color: AppTheme.primary, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13, height: 1.5, color: DC.text(ctx))),
          ),
        ]),
      );

  Widget _step(BuildContext ctx, int n, String title, String body) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$n',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DC.text(ctx))),
              const SizedBox(height: 2),
              Text(body,
                  style: TextStyle(
                      fontSize: 12, height: 1.45, color: DC.muted(ctx))),
            ]),
          ),
        ]),
      );

  Widget _divider(BuildContext ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Divider(height: 1, color: DC.border(ctx)),
      );

  Widget _code(BuildContext ctx, String code) => Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              code,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFFE2E8F0),
                  height: 1.5),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.copy, size: 16, color: Color(0xFF94A3B8)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Copied')));
              },
            ),
          ),
        ]),
      );
}
