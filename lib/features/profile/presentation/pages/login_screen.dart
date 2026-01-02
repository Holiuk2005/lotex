import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/features/auth/data/repositories/presentation/providers/auth_state_provider.dart';
import 'package:lotex/features/auction/presentation/widgets/lotex_input.dart'; // Переконайтеся, що шлях правильний

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Викликаємо метод входу (signIn) з вашого контролера
      await ref.read(authControllerProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // Якщо успішно — переходимо на головну або назад у профіль
        context.go('/home'); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка входу: ${humanError(e)}'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(title: const Text("Вхід")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 40),
              
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
                validator: (v) => v!.length < 6 ? "Занадто короткий пароль" : null,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("УВІЙТИ"),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Кнопка переходу на реєстрацію, якщо користувач помилився екраном
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text("Немає акаунту? Зареєструватися"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}