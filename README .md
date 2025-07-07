# Flutter + Firebase Setup (Minimal)

## 🔧 Requirements
- Flutter SDK
- Dart SDK
- Node.js & npm
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

## 🚀 Project Setup

1. **Create Flutter Project**
   ```bash
   flutter create my_app
   cd my_app
   ```

2. **Configure Firebase**
   ```bash
   flutterfire configure --platforms=android,web
   ```

3. **Install Dependencies**
   In `pubspec.yaml`, add:
   ```yaml
   dependencies:
     firebase_core: ^2.31.0
     firebase_auth: ^4.17.0
     cloud_firestore: ^4.15.0
   ```
   Then run:
   ```bash
   flutter pub get
   ```

4. **Initialize Firebase**
   In `main.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(MyApp());
   }
   ```

5. **Run the App**
   ```bash
   flutter run -d chrome    # or android
   ```

> ⚠️ Linux is not officially supported by Firebase SDKs.
