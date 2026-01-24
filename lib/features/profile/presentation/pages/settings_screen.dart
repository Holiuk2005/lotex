import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/features/profile/presentation/widgets/link_card_modal.dart';
import 'package:lotex/features/profile/presentation/widgets/verification_modal.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _aboutCopy(LotexLanguage lang) {
    if (lang == LotexLanguage.en) {
      return '''About the app

Lotex is a modern online auction built for convenient and secure selling and buying between users.

The app lets you create auctions, place bids in real time, or buy items at a fixed price. Lotex focuses on simplicity, speed, and reliability.

Key features:

• Google sign-in
• Create and participate in auctions
• Real-time bidding
• Personal user profile
• Online payment support
• Delivery service integration

Development

HolTiv Studio

UI/UX design: Holiuk Denys
Software: Max Titov

Version

2.3.3 alpha''';
    }

    return '''Про додаток

Lotex — сучасний онлайн-аукціон, створений для зручного та безпечного продажу й купівлі товарів між користувачами.

Додаток дозволяє створювати аукціони, робити ставки в реальному часі або купувати товари за фіксованою ціною. Lotex орієнтований на простоту використання, швидкість роботи та надійність.

Основні можливості:

• Авторизація через Google
• Створення та участь в аукціонах
• Ставки в режимі реального часу
• Особистий профіль користувача
• Підтримка онлайн-оплати
• Інтеграція служб доставки

Розробка

HolTiv Studio

UI/UX дизайн: Holiuk Denys
Програмне забезпечення: Max Titov

Версія

2.3.3 alpha''';
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вихід'),
        content: const Text('Ви дійсно бажаєте вийти з акаунту?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Вийти', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(lotexLanguageProvider);
    final showLogout =
        !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: LotexAppBar(
        showBack: true,
        showDesktopSearch: false,
        titleText: LotexI18n.tr(lang, 'settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: LotexI18n.tr(lang, 'language'),
            child: Row(
              children: [
                Expanded(
                  child: _PillButton(
                    isActive: lang == LotexLanguage.uk,
                    label: 'Українська',
                    onTap: () => ref.read(lotexLanguageProvider.notifier).set(LotexLanguage.uk),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    isActive: lang == LotexLanguage.en,
                    label: 'English',
                    onTap: () => ref.read(lotexLanguageProvider.notifier).set(LotexLanguage.en),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: LotexI18n.tr(lang, 'paymentMethods'),
            child: _ActionTile(
              icon: Icons.credit_card,
              title: LotexI18n.tr(lang, 'linkCard'),
              subtitle: LotexI18n.tr(lang, 'paymentMethods'),
              onTap: () => showLinkCardModal(context: context, ref: ref),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: LotexI18n.tr(lang, 'settings'),
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.verified_outlined,
                  title: LotexI18n.tr(lang, 'verifyPhone'),
                  subtitle: LotexI18n.tr(lang, 'unverified'),
                  onTap: () => showVerificationModal(context: context, ref: ref, isPhone: true),
                ),
                const SizedBox(height: 10),
                _ActionTile(
                  icon: Icons.alternate_email,
                  title: LotexI18n.tr(lang, 'verifyEmail'),
                  subtitle: LotexI18n.tr(lang, 'unverified'),
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && !user.emailVerified) {
                      await user.sendEmailVerification();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(LotexI18n.tr(lang, 'codeSent'))),
                      );
                    }
                    if (!context.mounted) return;
                    await showVerificationModal(context: context, ref: ref, isPhone: false);
                  },
                ),
                if (showLogout) ...[
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.logout,
                    title: LotexI18n.tr(lang, 'logout'),
                    subtitle: 'Sign out on this device',
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: LotexI18n.tr(lang, 'aboutApp'),
            child: Text(
              _aboutCopy(lang),
              style: const TextStyle(
                color: LotexUiColors.slate400,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.04 * 255).round()),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.06 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: LotexUiColors.slate400, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: LotexUiColors.slate400),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const _PillButton({required this.isActive, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isActive ? LotexUiColors.slate950 : Colors.white,
          backgroundColor: isActive ? Colors.white : Colors.white.withAlpha((0.06 * 255).round()),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
