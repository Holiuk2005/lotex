import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:lotex/core/widgets/app_button.dart';
import '../../../auction/presentation/widgets/lotex_input.dart';
import '../providers/auth_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Змінна для перемикання між Входом та Реєстрацією
  bool isSigningUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final controller = ref.read(authControllerProvider.notifier);

      try {
      if (isSigningUp) {
        await controller.signUp(email: email, password: password);
      } else {
        await controller.signIn(email: email, password: password);
      }
      if (!mounted) return;
      // Navigation is handled centrally by GoRouter redirect (auth -> /home)
      // to avoid double-navigation and deactivated-context issues.
    } catch (e) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final controller = ref.read(authControllerProvider.notifier);

    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final title = isDark ? AppColors.darkTitle : AppColors.lightTitle;
    final body = isDark ? AppColors.darkBody : AppColors.lightBody;

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    AppColors.darkBackground,
                    Color(0xFF0B1028),
                  ]
                : const [
                    Color(0xFFFDFDFF),
                    Color(0xFFF6F4FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: isDark
                        ? const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 40,
                              offset: Offset(0, 20),
                            )
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x1A020617),
                              blurRadius: 40,
                              offset: Offset(0, 20),
                            )
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary500,
                                      AppColors.secondary500,
                                    ],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x338B5CF6),
                                      blurRadius: 24,
                                      offset: Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/branding/logo.png',
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Lotex',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: title,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isSigningUp ? 'Створіть акаунт' : 'Увійдіть у свій акаунт',
                            style: TextStyle(fontSize: 14, color: body),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            isSigningUp ? 'Реєстрація' : 'Вхід',
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.primary600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          LotexInput(
                            label: "Email",
                            hint: "you@example.com",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v != null && v.contains('@')
                                ? null
                                : 'Введіть коректний email',
                          ),
                          const SizedBox(height: 16),

                          LotexInput(
                            label: "Пароль",
                            hint: "••••••••",
                            controller: _passwordController,
                            maxLines: 1,
                            obscureText: true,
                            validator: (v) => v != null && v.length >= 6
                                ? null
                                : 'Мінімум 6 символів',
                          ),
                          const SizedBox(height: 24),

                          AppButton.primary(
                            label: isLoading
                                ? 'Зачекайте...'
                                : (isSigningUp
                                    ? 'ЗАРЕЄСТРУВАТИСЬ'
                                    : 'УВІЙТИ'),
                            onPressed: isLoading ? null : _submit,
                          ),

                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white.withAlpha(25)
                                      : Colors.black.withAlpha(25),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Або",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white.withAlpha(25)
                                      : Colors.black.withAlpha(25),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialButton(
                                icon: Icons.g_mobiledata,
                                color: Colors.red,
                                isLoading: isLoading,
                                onTap: () async {
                                  try {
                                    await controller.signInWithGoogle();
                                    if (!mounted) return;
                                    if (FirebaseAuth.instance.currentUser != null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (!mounted) return;
                                        context.go('/home');
                                      });
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (!mounted) return;
                                      final messenger =
                                          ScaffoldMessenger.maybeOf(context);
                                      messenger?.showSnackBar(
                                        SnackBar(
                                          content: Text(e
                                              .toString()
                                              .replaceAll('Exception: ', '')),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    });
                                  }
                                },
                              ),
                              if (!kIsWeb &&
                                  defaultTargetPlatform == TargetPlatform.iOS) ...[
                                const SizedBox(width: 20),
                                _SocialButton(
                                  icon: Icons.apple,
                                  color: isDark ? Colors.white : Colors.black,
                                  onTap: () async {
                                    try {
                                      await controller.signInWithApple();
                                      if (!mounted) return;
                                    } catch (e) {
                                      if (!mounted) return;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (!mounted) return;
                                        final messenger =
                                            ScaffoldMessenger.maybeOf(context);
                                        messenger?.showSnackBar(
                                          SnackBar(
                                            content: Text(e
                                                .toString()
                                                .replaceAll('Exception: ', '')),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      });
                                    }
                                  },
                                  isLoading: isLoading,
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSigningUp = !isSigningUp;
                              });
                            },
                            child: Text(
                              isSigningUp
                                  ? 'Вже є акаунт? Увійти'
                                  : 'Немає акаунта? Зареєструватись',
                              style: AppTextStyles.bodyRegular.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Допоміжний віджет для круглої кнопки
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(30) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
        ),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon, size: 36, color: color),
      ),
    );
  }
}