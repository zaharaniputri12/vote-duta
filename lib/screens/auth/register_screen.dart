import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true, _obscure2 = true;

  @override
  void dispose() { _namaCtrl.dispose(); _nimCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final ok = await auth.register(
        nama: _namaCtrl.text.trim(),
        nim: _nimCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil!'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Gagal'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.primary),
      body: SafeArea(
        child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Column(children: [Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(35)), child: const Icon(Icons.person_add, size: 35, color: AppColors.primary)), const SizedBox(height: 16), const Text('Buat Akun Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)), const Text('Lengkapi data diri', style: TextStyle(color: AppColors.grey, fontSize: 14))])),
          const SizedBox(height: 32),
          TextFormField(controller: _namaCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)), validator: (v) => Validators.required(v, 'Nama')),
          const SizedBox(height: 16),
          TextFormField(controller: _nimCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'NIM', prefixIcon: Icon(Icons.badge_outlined)), validator: Validators.nim),
          const SizedBox(height: 16),
          TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), validator: Validators.email),
          const SizedBox(height: 16),
          TextFormField(controller: _passCtrl, obscureText: _obscure, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outlined), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))), validator: Validators.password),
          const SizedBox(height: 16),
          TextFormField(controller: _confirmCtrl, obscureText: _obscure2, decoration: InputDecoration(labelText: 'Konfirmasi Password', prefixIcon: const Icon(Icons.lock_outlined)), validator: (v) => v != _passCtrl.text ? 'Password tidak sama' : null),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: auth.isLoading ? null : _register, child: auth.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)) : const Text('DAFTAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Sudah punya akun? '), GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Login', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))])),
        ]))),
      ),
    );
  }
}