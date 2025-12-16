import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// no-go_router import
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auction/presentation/widgets/lotex_input.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      await ref.read(authControllerProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Якщо успішно - перенаправлення відбудеться автоматично через authStateChanges
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Помилка: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Реєстрація")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Створити акаунт',
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                LotexInput(
                  label: "Ім'я",
                  hint: "Ваше ім'я",
                  controller: _nameController,
                  validator: (v) => v!.isEmpty ? "Введіть ім'я" : null,
                ),
                const SizedBox(height: 16),
                
                LotexInput(
                  label: "Email",
                  hint: "example@mail.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Введіть коректний email',
                ),
                const SizedBox(height: 16),
                
                LotexInput(
                  label: "Пароль",
                  hint: "******",
                  obscureText: true,
                  controller: _passwordController,
                  maxLines: 1,
                  validator: (v) => v!.length < 6 ? "Мінімум 6 символів" : null,
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text("ЗАРЕЄСТРУВАТИСЯ"),
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