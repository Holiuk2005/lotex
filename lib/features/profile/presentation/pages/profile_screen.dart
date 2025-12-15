import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/features/auth/data/repositories/presentation/providers/auth_state_provider.dart';
import 'package:lotex/core/theme/app_colors.dart';
import 'package:lotex/core/theme/app_text_styles.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Ви не увійшли в акаунт', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text('Увійдіть або створіть профіль, щоб почати', style: AppTextStyles.bodyRegular, textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    
                    // Кнопка УВІЙТИ
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Увійти'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // --- НОВА КНОПКА РЕЄСТРАЦІЇ ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => context.go('/register'), // Перехід на екран реєстрації
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary600),
                        ),
                        child: const Text('Зареєструватися'),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                        child: user.photoURL == null ? const Icon(Icons.person, size: 36) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.displayName ?? 'Користувач', style: AppTextStyles.h2),
                            const SizedBox(height: 4),
                            Text(user.email, style: AppTextStyles.bodyRegular),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Вийти'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  ),
                ],
              ),
      ),
    );
  }
}