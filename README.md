# buzdy

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup

After pulling the source, install the required packages with:

```bash
flutter pub get
```

Run this whenever `pubspec.yaml` changes to avoid package resolution errors.

## Video download setup

This project saves YouTube videos locally using
[`youtube_explode_dart`](https://pub.dev/packages/youtube_explode_dart).
Add the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  permission_handler: ^11.3.0
  path_provider: ^2.1.2
  youtube_explode_dart: ^2.0.2
  image_gallery_saver_plus: ^4.0.1
```

On Android include these permissions in
`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
```

If a video fails to download with `Video stream not available` in the log, you
can inspect available streams with:

```dart
await VideoDownloader.debugAvailableStreams('YOUR_VIDEO_ID');
```

This prints audio-only and video-only stream information to help diagnose
issues.
