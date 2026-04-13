// lib/presentation/screens/tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/tasks_viewmodel.dart';
import 'login_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksViewModel>().loadTasks();
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _handleAddTask(TasksViewModel vm) async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;
    await vm.addTask(title);
    _taskController.clear();
  }

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои задачи'),
        actions: [
          IconButton(
            key: const Key('logout_button'),
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Consumer<TasksViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(key: Key('loading_indicator')),
            );
          }

          if (vm.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vm.errorMessage ?? 'Ошибка',
                    key: const Key('tasks_error'),
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    key: const Key('retry_button'),
                    onPressed: vm.loadTasks,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: vm.tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'Пока нет задач. Добавьте первую задачу!',
                          key: Key('empty_state'),
                        ),
                      )
                    : ListView.builder(
                        key: const Key('tasks_list'),
                        itemCount: vm.tasks.length,
                        itemBuilder: (context, index) {
                          final task = vm.tasks[index];
                          return ListTile(
                            key: Key('task_item_${task.id}'),
                            title: Text(
                              task.title,
                              key: Key('task_title_${task.id}'),
                            ),
                            leading: Icon(
                              task.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                            ),
                            trailing: IconButton(
                              key: Key('delete_task_${task.id}'),
                              icon: const Icon(Icons.delete),
                              onPressed: () => vm.deleteTask(task.id),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('taskInput'),
                        controller: _taskController,
                        decoration: const InputDecoration(
                          hintText: 'Новая задача...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      key: const Key('add_button'),
                      onPressed: () => _handleAddTask(vm),
                      child: const Text('Добавить'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
