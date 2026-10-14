# DroidCraft

Design Android UI visually, right from your phone.

DroidCraft is a native Android app built with Flutter that lets you mock up
Android screens by dragging widgets onto a phone canvas, then exports
production-ready XML layouts and Kotlin activities.

## Features

- Multi-screen projects, build as many screens as you need
- Drag to reorder, long-press a screen in the Flow builder to rearrange
- 19 UI components: heading, text, button, input, image, avatar, divider,
  spacer, card, app bar, tabs, progress, slider, switch, checkbox, radio,
  chip, FAB, rating
- Rich styling: colors, font size, alignment, bold / italic / underline,
  letter spacing, line height, corner radius, padding
- Screen-to-screen navigation, link any widget to another screen, or
  chain screens in the Flow builder
- Image picker, pick from gallery, resize, adjust fit and radius
- Code editor, edit the generated XML and Kotlin inline, save per-screen
  overrides, reset to regenerate
- Android XML + Kotlin export, copy to clipboard, paste into Android Studio
- Backup and Restore, export all projects as JSON, restore from a backup
- Dark mode + 5 font styles
- Local storage only, no accounts, no server, works fully offline

## Templates included

Blank, Login, Profile, Dashboard, Sign Up, Chat, Search, Payment, Onboarding,
Empty State.

## Building the APK

The APK is built automatically by GitHub Actions on every push to main.

1. Go to the Actions tab
2. Open the newest successful run
3. Download the droidcraft-apk artifact
4. Unzip and install app-release.apk on your phone

Flutter cannot build APKs on Android itself. The Android SDK only runs on
desktop, so GitHub Actions handles the build for you.

## Local development

    flutter pub get
    flutter run

## Project structure

    lib/
      main.dart                      app entry + providers
      models.dart                    Project, ScreenModel, ComponentModel
      registry.dart                  component definitions + factory
      renderer.dart                  widget renderer (canvas + preview)
      templates.dart                 10 starter templates
      exporter.dart                  XML + Kotlin code generation
      backup.dart                    export / restore all projects as JSON
      nav.dart                       slide + fade page routes
      services.dart                  theme + project state
      theme.dart                     light/dark themes + font options
      screens/
        home_screen.dart             project list + templates
        editor_screen.dart           canvas + toolbar
        preview_screen.dart          full-screen preview with Continue button
        flow_screen.dart             drag-to-reorder navigation builder
        code_editor_screen.dart      editable XML + Kotlin
        settings_screen.dart         theme, fonts, backup, about
      widgets/
        phone_frame.dart             phone mockup shell

## License

MIT
