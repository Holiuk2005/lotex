import 'dart:io'; // Для Platform
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final controller = ref.read(authControllerProvider.notifier);

    // Викликаємо відповідний метод залежно від режиму
    if (isSigningUp) {
      controller.signUp(email: email, password: password);
    } else {
      controller.signIn(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Слухаємо зміни стану (помилки або успіх)
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      next.when(
        data: (_) {
          // Успішний вхід - перенаправлення зазвичай обробляється в router.dart через authStateChanges,
          // але можна додати явний перехід, якщо потрібно:
          // context.go('/home'); 
        },
        error: (e, st) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        ),
        loading: () {},
      );
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- ЗАГОЛОВОК ---
                Text(
                  isSigningUp ? 'Реєстрація' : 'Вхід',
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // --- ПОЛЕ EMAIL ---
                LotexInput(
                  label: "Email",
                  hint: "you@example.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Введіть коректний email',
                ),
                const SizedBox(height: 16),
                
                // --- ПОЛЕ ПАРОЛЬ ---
                LotexInput(
                  label: "Пароль",
                  hint: "••••••••",
                  controller: _passwordController,
                  maxLines: 1,
                  obscureText: true, // Приховуємо символи
                  validator: (v) => v != null && v.length >= 6 ? null : 'Мінімум 6 символів',
                ),
                const SizedBox(height: 32),
                
                // --- КНОПКА ДІЇ (Вхід або Реєстрація) ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isSigningUp ? 'ЗАРЕЄСТРУВАТИСЬ' : 'УВІЙТИ'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // --- РОЗДІЛЬНИК ---
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Або", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // --- СОЦІАЛЬНІ КНОПКИ ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google
                    _SocialButton(
  icon: Icons.g_mobiledata,
  color: Colors.red,
  isLoading: isLoading,
  onTap: () async {
    print("🔘 КНОПКУ НАТИСНУТО!"); // Цей текст має з'явитися в консолі
    try {
      await controller.signInWithGoogle();
      print("✅ Вхід успішний (з точки зору UI)");
    } catch (e) {
      print("🛑 ПОМИЛКА ПРИ НАТИСКАННІ: $e");
    }
  },
),
                    
                    // Apple (показуємо тільки на iOS)
                    if (Platform.isIOS) ...[
                      const SizedBox(width: 20),
                      _SocialButton(
                        icon: Icons.apple,
                        color: Colors.black,
                        onTap: () => controller.signInWithApple(),
                        isLoading: isLoading,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),
                
                // --- ПЕРЕМИКАЧ ВХІД / РЕЄСТРАЦІЯ ---
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSigningUp = !isSigningUp; // Перемикаємо режим
                    });
                  },
                  child: Text(
                    isSigningUp ? 'Вже є акаунт? Увійти' : 'Немає акаунта? Зареєструватись',
                    style: AppTextStyles.bodyRegular.copyWith(color: AppColors.primary600),
                  ),
                ),
              ],
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
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon, size: 36, color: color),
      ),
    );
  }
}