import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
 
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;  
 
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = false, 
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,  
      children: [
        const SizedBox(height: 40),
 
        if (showLogo) ...[
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              color: Colors.white,
              border: Border.all(
                color: AppColors.primary,  
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(  
              child: Image.asset(
                'assets/icons/logo_toko.png',
                width: 110,
                height: 110,
                fit: BoxFit.cover,  
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.store,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
     
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
 
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
