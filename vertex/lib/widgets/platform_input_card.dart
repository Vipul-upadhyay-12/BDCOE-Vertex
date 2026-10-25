import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PlatformInputCard extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final Color accentColor;
  final IconData icon;
  final bool isVerified;

  const PlatformInputCard({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.accentColor,
    required this.icon,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? AppColors.primaryGreen : AppColors.border,
          width: isVerified ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (isVerified)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}