import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/core/theme/app_colors.dart';
import 'package:lotex/core/theme/app_text_styles.dart';
import 'package:lotex/features/auth/domain/entities/user_entity.dart'; // Переконайтесь, що шлях правильний
import 'package:lotex/features/profile/presentation/pages/edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Слухаємо ПОТІК змін стану (вхід/вихід/завантаження)
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (authState.asData?.value != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () async {
                final updated = await Navigator.push<bool?>(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                if (updated == true) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профіль оновлено')));
                }
              },
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5), // Світло-сірий фон
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const _GuestView();
          }
          return _UserView(user: user);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary600)),
        error: (err, stack) => Center(child: Text('Помилка: $err')),
      ),
    );
  }
}

        
  class _MenuOption {
    final IconData icon;
    final String title;
    final VoidCallback onTap;
    const _MenuOption({required this.icon, required this.title, required this.onTap});
  }

  // --- ВИГЛЯД ДЛЯ АВТОРИЗОВАНОГО КОРИСТУВАЧА ---
class _UserView extends ConsumerWidget {
  final UserEntity user;

  const _UserView({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Картка профілю
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary500,
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null 
                      ? Text(user.email[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary600)) 
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Користувач Lotex',
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppTextStyles.bodyRegular.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Меню опцій
          _buildMenuSection([
            _MenuOption(
              icon: Icons.gavel_rounded,
              title: 'Мої лоти',
              onTap: () {
                // TODO: Навігація до лотів
              },
            ),
            _MenuOption(
              icon: Icons.favorite_border_rounded,
              title: 'Обране',
              onTap: () {
                // TODO: Навігація до обраного
              },
            ),
            _MenuOption(
              icon: Icons.history_rounded,
              title: 'Історія ставок',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 16),

          _buildMenuSection([
            _MenuOption(
              icon: Icons.settings_outlined,
              title: 'Налаштування',
              onTap: () {},
            ),
            _MenuOption(
              icon: Icons.support_agent_rounded,
              title: 'Підтримка',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          // Кнопка виходу
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Вийти з акаунту', style: TextStyle(color: AppColors.error, fontSize: 16)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<_MenuOption> options) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return Column(
            children: [
              if (index != 0) const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(option.icon, color: AppColors.primary600),
                ),
                title: Text(option.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: option.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вихід'),
        content: const Text('Ви дійсно бажаєте вийти з акаунту?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Вийти', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      // Тут не потрібно context.go('/login'), бо StreamBuilder сам оновить UI на _GuestView
    }
  }
}

// --- ВИГЛЯД ДЛЯ ГОСТЯ ---
class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 20)],
              ),
              child: const Icon(Icons.person_outline_rounded, size: 64, color: AppColors.primary600),
            ),
            const SizedBox(height: 32),
            Text('Ласкаво просимо!', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Увійдіть або зареєструйтесь, щоб купувати та продавати лоти.',
              style: AppTextStyles.bodyRegular.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text('УВІЙТИ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary600),
                ),
                child: const Text('ЗАРЕЄСТРУВАТИСЯ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}