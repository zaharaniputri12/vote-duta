import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/candidate_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.3, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cp = Provider.of<CandidateProvider>(context, listen: false);
    await auth.init();
    await cp.init();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => auth.isLoggedIn ? const HomeScreen() : const LoginScreen()));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(opacity: _fade.value, child: Transform.scale(scale: _scale.value, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 150, height: 150, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(75), boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.3), blurRadius: 30)]), child: const Icon(Icons.how_to_vote_rounded, size: 80, color: AppColors.primary)),
            const SizedBox(height: 30),
            const Text('VOTE DUTA', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.white, letterSpacing: 3)),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withOpacity(0.5))), child: const Text('Bujang Gadis Informatika', style: TextStyle(color: AppColors.accent, fontSize: 16))),
            const SizedBox(height: 8),
            Text('Program Studi Informatika', style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: 14)),
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: AppColors.accent),
          ]))),
        ),
      ),
    );
  }
}