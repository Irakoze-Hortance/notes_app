import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/notes/notes_bloc.dart';
import 'repositories/auth_repository.dart';
import 'repositories/notes_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/notes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform checking
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux || 
                  defaultTargetPlatform == TargetPlatform.windows)) {
    // For desktop platforms, show a warning and continue without Firebase
    print('Warning: Firebase is not fully supported on desktop platforms.');
    print('Consider running on mobile/web or using Firebase Emulator Suite for development.');
  } else {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print('Firebase initialization failed: $e');
      print('Running in development mode without Firebase backend');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<NotesRepository>(
          create: (context) => NotesRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            )..add(AuthCheckStatus()),
          ),
          BlocProvider<NotesBloc>(
            create: (context) => NotesBloc(
              notesRepository: RepositoryProvider.of<NotesRepository>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Firebase Notes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we're on an unsupported platform
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux || 
                    defaultTargetPlatform == TargetPlatform.windows)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Notes'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isLandscape ? 32.0 : 16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLandscape ? 800 : 400,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: isLandscape ? 48 : 64,
                        color: Colors.orange,
                      ),
                      SizedBox(height: isLandscape ? 12 : 16),
                      Text(
                        'Desktop Platform Detected',
                        style: TextStyle(
                          fontSize: isLandscape ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isLandscape ? 12 : 16),
                      Text(
                        'Firebase is not fully supported on desktop platforms.\n\n'
                        'To test this app properly, please run it on:\n'
                        '• Android device/emulator\n'
                        '• iOS device/simulator\n'
                        '• Web browser\n\n'
                        'Or set up Firebase Emulator Suite for local development.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isLandscape ? 14 : 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is AuthAuthenticated) {
          return const NotesScreen();
        }
        
        return const AuthScreen();
      },
    );
  }
}
