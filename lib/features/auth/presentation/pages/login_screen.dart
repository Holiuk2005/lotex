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
  bool isSigningUp = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text;
    final password = _passwordController.text;
    final controller = ref.read(authControllerProvider.notifier);

    if (isSigningUp) {
      controller.signUp(email: email, password: password);
    } else {
      controller.signIn(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString()), backgroundColor: AppColors.error),
        );
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

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
                Text(
                  isSigningUp ? 'Реєстрація Lotex' : 'Вхід у Lotex',
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                LotexInput(
                  label: "Email",
                  hint: "you@example.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : 'Введіть коректний email',
                ),
                const SizedBox(height: 16),
                
                LotexInput(
                  label: "Пароль",
                  hint: "••••••••",
                  controller: _passwordController,
                  maxLines: 1,
                  // Тут треба додати obscureText, але ми його не реалізовували в LotexInput
                  validator: (v) => v!.length >= 6 ? null : 'Пароль має бути не менше 6 символів',
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isSigningUp ? 'ЗАРЕЄСТРУВАТИСЬ' : 'УВІЙТИ'),
                ),
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSigningUp = !isSigningUp;
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