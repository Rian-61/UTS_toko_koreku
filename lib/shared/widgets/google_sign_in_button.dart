import 'package:flutter/material.dart';
 
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
 
  const GoogleSignInButton({super.key, this.onPressed, this.isLoading = false});
 
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: Color(0xFFDDDDDD)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: isLoading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/google_logo.png', height: 24, width: 24),
                const SizedBox(width: 12),
                const Text('Masuk dengan Google', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w500)),
              ],
            ),
    );
  }
}
