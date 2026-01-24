import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/features/auction/presentation/widgets/lotex_input.dart'; // Використовуємо ваш віджет інпуту

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
    
    // Тут ми викликаємо метод реєстрації з контролера
    // Увага: переконайтеся, що у вашому authController є метод signUp або register
    try {
      await ref.read(authControllerProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      // Navigation is handled centrally by GoRouter redirect (auth -> /home)
      // to avoid double-navigation and deactivated-context issues.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: ${humanError(e)}')),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
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
                validator: (v) => !v!.contains('@') ? "Некоректний email" : null,
              ),
              const SizedBox(height: 16),
              LotexInput(
                label: "Пароль",
                hint: "******",
                obscureText: true,
                controller: _passwordController,
                validator: (v) => v!.length < 6 ? "Мінімум 6 символів" : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("ЗАРЕЄСТРУВАТИСЯ"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}