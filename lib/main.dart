import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/secure_storage.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/product_provider.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Toko Koreku',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        home: const SplashPage(),
      ),
    );
  }
}
 
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}
 
class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }
 
  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final hasToken = await SecureStorage.hasToken();
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        hasToken ? AppRouter.dashboard : AppRouter.login,
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
