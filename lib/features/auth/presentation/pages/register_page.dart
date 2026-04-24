import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../providers/auth_provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';
 
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
 
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
 
class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
 
  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmPassCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (auth.status == AuthStatus.emailNotVerified) {
            Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
          }
        });
        return LoadingOverlay(
          isLoading: auth.status == AuthStatus.loading,
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthHeader(title: 'Buat Akun', subtitle: 'Daftar untuk mulai belanja'),
                      CustomTextField(label: 'Nama Lengkap', controller: _nameCtrl, prefixIcon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null),
                      CustomTextField(label: 'Email', controller: _emailCtrl, prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => !EmailValidator.validate(v!) ? 'Email tidak valid' : null),
                      CustomTextField(label: 'Password', controller: _passCtrl, isPassword: true, prefixIcon: Icons.lock_outline,
                        validator: (v) => v!.length < 6 ? 'Password min 6 karakter' : null),
                      CustomTextField(label: 'Konfirmasi Password', controller: _confirmPassCtrl, isPassword: true, prefixIcon: Icons.lock_outline,
                        validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null),
                      if (auth.status == AuthStatus.error)
                        Padding(padding: const EdgeInsets.only(bottom: 12),
                          child: Text(auth.errorMessage ?? '', style: const TextStyle(color: Colors.red, fontSize: 13))),
                      CustomButton(text: 'Daftar', onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          auth.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());
                        }
                      }),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Sudah punya akun? '),
                        TextButton(onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.login),
                          child: const Text('Masuk')),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
