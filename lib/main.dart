// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/tasks_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final AppDependencies? dependencies;

  const MyApp({super.key, this.dependencies});

  @override
  Widget build(BuildContext context) {
    // Используем переданные зависимости или создаём новые
    // В тестах передаём FakeApiClient — реальных сетевых запросов нет
    final deps = dependencies ?? AppDependencies();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deps.authViewModel),
        ChangeNotifierProvider.value(value: deps.tasksViewModel),
      ],
      child: MaterialApp(
        title: 'Приложение задач',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
