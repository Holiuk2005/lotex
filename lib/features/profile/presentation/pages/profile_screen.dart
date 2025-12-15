import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Профіль"), centerTitle: true),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const CircleAvatar(radius: 50, backgroundColor: AppColors.primary500, child: Text("TS", style: TextStyle(color: Colors.white, fontSize: 24))),
            const SizedBox(height: 16),
            Text("User Name", style: AppTextStyles.h2),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text("Вийти"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}