# Sprints Audio Recorder Task

## Screenshots

| Recording Screen | Recorded Screen |
| ---------------- | --------------- |
| <img src=""/>    | <img src=""/>   |

## Overview

This Flutter application is an audio recorder that allows users to record, play, and manage audio files. The app utilizes the `flutter_sound` package to handle audio playback and recording functionalities.

## Features

- **Cross-Platform Support:** Runs seamlessly on Android and iOS.
- **Record Audio:** Allows users to record high-quality audio.
- **Playback:** Users can play recorded audio files.
- **Manage Recordings:** Users can view, delete, and manage their recordings.

## Dependencies

- [flutter_sound](https://pub.dev/packages/flutter_sound): A Flutter plugin for handling audio playback and recording.
- [pretty_animated_buttons](https://pub.dev/packages/pretty_animated_buttons): A Flutter plugin for animated buttons.
- [path_provider](https://pub.dev/packages/path_provider): A Flutter plugin for finding commonly used locations on the filesystem.
- [permission_handler](https://pub.dev/packages/permission_handler): A Flutter plugin for handling permissions.

## Getting Started

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/OmarAmeer96/Sprints-Audio-Task.git
   cd Sprints-Audio-Task
   ```

2. **Install Dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the App:**

   ```bash
   flutter run
   ```

## Usage

Upon launching the app, the main screen will display options to start a new recording or view existing recordings. Users can record audio, play back recordings, and manage their audio files.
