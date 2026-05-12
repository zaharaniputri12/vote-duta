import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _resetSent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _reset() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final ok = await auth.resetPassword(_emailCtrl.text.trim());
      if (ok && mounted) { setState(() => _resetSent = true); }
      else if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Gagal'), backgroundColor: AppColors.error)); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.primary),
      body: SafeArea(
        child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Center(child: Icon(Icons.lock_reset, size: 80, color: AppColors.primary.withOpacity(0.3))),
          const SizedBox(height: 24),
          const Text('Reset Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(_resetSent ? 'Password berhasil direset!' : 'Masukkan email Anda untuk mereset password.', style: const TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          if (_resetSent) ...[
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Column(children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 50),
              const SizedBox(height: 12),
              const Text('Password Baru:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8)), child: const Text('123456', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 3))),
              const SizedBox(height: 12),
              const Text('Silakan login dengan password baru.', style: TextStyle(fontSize: 13, color: AppColors.grey)),
            ])),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('KEMBALI KE LOGIN')),
          ] else ...[
            TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', hintText: 'Masukkan email terdaftar', prefixIcon: Icon(Icons.email_outlined)), validator: Validators.email),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: auth.isLoading ? null : _reset, child: auth.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)) : const Text('RESET PASSWORD')),
            const SizedBox(height: 16),
            Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali ke Login'))),
          ],
        ]))),
      ),
    );
  }
}