// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'tasks_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthViewModel vm) async {
    await vm.login(_emailController.text, _passwordController.text);
    if (vm.isAuthenticated && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TasksScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  key: const Key('email'),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Почта',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('password'),
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (vm.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      vm.errorMessage ?? 'Неизвестная ошибка',
                      key: const Key('error_message'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('login_button'),
                    onPressed: vm.isLoading ? null : () => _handleLogin(vm),
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Войти'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
