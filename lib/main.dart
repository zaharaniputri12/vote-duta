import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/candidate_provider.dart';
import 'providers/vote_provider.dart';
import 'services/local_storage_service.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CandidateProvider()),
        ChangeNotifierProvider(create: (_) => VoteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveAllData();
    }
  }

  Future<void> _saveAllData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cp = Provider.of<CandidateProvider>(context, listen: false);
    await LocalStorageService.saveAllData(
      users: auth.usersForSave,
      passwords: auth.passwordsForSave,
      bujangCandidates: cp.bujangForSave,
      gadisCandidates: cp.gadisForSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vote Informatika',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}