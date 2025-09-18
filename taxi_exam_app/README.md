# 香港的士考試應用程式 Hong Kong Taxi Exam App

A Flutter application for Hong Kong taxi driver exam preparation with location and route questions.

## ✅ Features

### 📱 4 Main Tabs
1. **地方問題 (Locations)** - Browse and search 85+ Hong Kong locations
2. **路線問題 (Routes)** - View and search 37 taxi routes
3. **地方測驗 (Location Quiz)** - Multiple choice quiz for testing location knowledge
4. **路線測驗 (Route Quiz)** - Multiple choice quiz for testing route knowledge

### 🎯 Key Features
- **Search & Filter** - Search locations by name/district, filter by category
- **Favorites System** - Mark locations and routes as favorites
- **Quiz System** - Multiple choice questions with instant feedback
- **Progress Tracking** - Persistent score tracking across sessions
- **Detail Views** - View detailed information about each location and route
- **No API Key Required** - Works without Google Maps API key using placeholder maps

## 🚀 Quick Start

### Run the app:
```bash
flutter run -d chrome
```

### Run on iOS Simulator:
```bash
flutter run -d ios
```

### Run on Android:
```bash
flutter run -d android
```

## 📦 Installation

1. Ensure Flutter is installed
2. Navigate to project directory:
```bash
cd /Users/cliffyeung/Development/rnd11_car/taxi_exam_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. For iOS:
```bash
cd ios && pod install && cd ..
```

## 📂 Project Structure

```
taxi_exam_app/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── models/                        # Data models
│   ├── providers/                     # State management
│   ├── services/                      # Data services
│   ├── screens/                       # App screens (4 tabs + details)
│   └── widgets/                       # Reusable widgets
└── docs/                              # Exam data source
```

## 🗺️ Google Maps (Optional)

The app works without Google Maps API key. To enable actual maps:

1. Get API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add to `ios/Runner/AppDelegate.swift` and `android/app/src/main/AndroidManifest.xml`

## 📊 Data Source

Uses Hong Kong Transport Department taxi exam data (December 2024 revision).

## 🛠️ Technologies

- Flutter 3.0+
- Dart
- Provider (State Management)
- Google Maps Flutter
- SharedPreferences

## 📱 Supported Platforms

✅ iOS  
✅ Android  
✅ Web

## 🏃 Running Status

The app is currently running on Chrome at http://localhost:55951/

Press 'r' in terminal for hot reload.
