import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../providers/auth_provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/auth_header.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/divider_with_text.dart';
import '../../../../shared/widgets/google_sign_in_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';
 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
 
  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
 
  void _handleNavigation(BuildContext context, AuthStatus status) {
    if (status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (status == AuthStatus.emailNotVerified) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    }
  }
 
  void _showForgotPassword(BuildContext context, AuthProvider auth) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Email')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: () async {
          await auth.forgotPassword(ctrl.text.trim());
          if (context.mounted) { Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email reset password sudah dikirim!')));
          }
        }, child: const Text('Kirim')),
      ],
    ));
  }
 
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _handleNavigation(context, auth.status));
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
                      const AuthHeader(title: 'Selamat Datang', subtitle: 'Masuk ke akun kamu'),
                      CustomTextField(label: 'Email', controller: _emailCtrl, prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => !EmailValidator.validate(v!) ? 'Email tidak valid' : null),
                      CustomTextField(label: 'Password', controller: _passCtrl, isPassword: true, prefixIcon: Icons.lock_outline,
                        validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null),
                      Align(alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () => _showForgotPassword(context, auth), child: const Text('Lupa Password?'))),
                      if (auth.status == AuthStatus.error)
                        Padding(padding: const EdgeInsets.only(bottom: 12),
                          child: Text(auth.errorMessage ?? '', style: const TextStyle(color: Colors.red, fontSize: 13))),
                      CustomButton(text: 'Masuk', onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          auth.loginWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
                        }
                      }),
                      const SizedBox(height: 20),
                      const DividerWithText(text: 'atau'),
                      const SizedBox(height: 16),
                      GoogleSignInButton(onPressed: () => auth.loginWithGoogle()),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Belum punya akun? '),
                        TextButton(onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.register),
                          child: const Text('Daftar')),
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
