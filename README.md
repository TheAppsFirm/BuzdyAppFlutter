# Buzdy

Sample Flutter app that lets you browse YouTube videos in a WebView and save
them locally. Videos can be merged with `ffmpeg_kit_flutter_new` when no combined
stream is available. Downloads are stored inside the app directory and may be
added to the device gallery on demand.

## Features

- Built-in WebView to browse YouTube
- Download the highest quality muxed stream when available
- Automatically merge separate video and audio streams with ffmpeg if needed
- Track download progress with a progress bar
- Manage saved videos from the **Saved Videos** screen
- Save or delete videos and play them within the app
- Select multiple saved videos to save or delete them all at once

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
  ffmpeg_kit_flutter_new: ^1.6.1
```

Add the ffmpeg-kit Maven repository in `android/build.gradle` so Gradle can
resolve native binaries:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://artifacts.arthenica.com/release' }
    }
}
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

### Download separate streams and merging fallback

If a muxed stream is unavailable the downloader automatically fetches the best
video-only and audio-only streams, merges them with `ffmpeg_kit`, and saves the
resulting `.mp4` in the app's storage directory.

Open the **Saved Videos** screen from the feed to view your downloads. Each
video can then be saved to the device gallery on demand. Use the delete button
to remove unwanted videos.

You can also call `VideoDownloader.downloadStreams` to retrieve the raw
video-only and audio-only files in the app documents directory without merging.
This can be useful when you need custom ffmpeg processing.

### Viewing saved videos

Tap the video library icon in the Feed screen to open the list of downloads.
From here you can play the video, save it to the gallery or delete it. Tap the
checklist icon to select multiple videos and save them all to the gallery or
delete them in one action.
