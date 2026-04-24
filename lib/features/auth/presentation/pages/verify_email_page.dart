import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/custom_button.dart';
 
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}
 
class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  int _cooldown = 0;
 
  @override
  void initState() {
    super.initState();
    _startPolling();
  }
 
  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (user?.emailVerified == true) {
        _timer?.cancel();
        if (mounted) {
          await context.read<AuthProvider>().loginWithEmail(
            user!.email!, '',
          );
          Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        }
      }
    });
  }
 
  Future<void> _resendEmail() async {
    if (_cooldown > 0) return;
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    setState(() => _cooldown = 60);
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 0) { t.cancel(); return; }
      setState(() => _cooldown--);
    });
  }
 
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Color(0xFF1565C0)),
            const SizedBox(height: 24),
            const Text('Cek Email Kamu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Link verifikasi sudah dikirim ke ${FirebaseAuth.instance.currentUser?.email ?? ''}', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Halaman ini akan otomatis berpindah setelah email diverifikasi.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            CustomButton(
              text: _cooldown > 0 ? 'Kirim Ulang ($_cooldown detik)' : 'Kirim Ulang Email',
              type: ButtonType.outlined,
              onPressed: _cooldown > 0 ? null : _resendEmail,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                Navigator.pushReplacementNamed(context, AppRouter.login);
              },
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    );
  }
}
