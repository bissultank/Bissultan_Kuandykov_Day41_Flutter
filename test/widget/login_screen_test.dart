// test/widget/login_screen_test.dart
//
// Widget тесты для LoginScreen.
// AuthViewModel подменяется через MockAuthRepository — DI тестируется здесь.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tasks_app/domain/entities/user.dart';
import 'package:tasks_app/domain/usecases/add_task_usecase.dart';
import 'package:tasks_app/domain/usecases/get_tasks_usecase.dart';
import 'package:tasks_app/domain/usecases/login_usecase.dart';
import 'package:tasks_app/presentation/screens/login_screen.dart';
import 'package:tasks_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:tasks_app/presentation/viewmodels/tasks_viewmodel.dart';
import '../mocks.dart';

Widget buildLoginScreen({
  required AuthViewModel authVm,
  required TasksViewModel tasksVm,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
      ChangeNotifierProvider<TasksViewModel>.value(value: tasksVm),
    ],
    child: const MaterialApp(
      home: LoginScreen(),
    ),
  );
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockTaskRepository mockTaskRepository;
  late AuthViewModel authViewModel;
  late TasksViewModel tasksViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTaskRepository = MockTaskRepository();

    when(() => mockTaskRepository.getTasks()).thenAnswer((_) async => []);

    authViewModel = AuthViewModel(
      loginUseCase: LoginUseCase(mockAuthRepository),
      authRepository: mockAuthRepository,
    );
    tasksViewModel = TasksViewModel(
      getTasksUseCase: GetTasksUseCase(mockTaskRepository),
      addTaskUseCase: AddTaskUseCase(mockTaskRepository),
      taskRepository: mockTaskRepository,
    );
  });

  testWidgets('LoginScreen отображает поля ввода и кнопку', (tester) async {
    await tester.pumpWidget(
      buildLoginScreen(authVm: authViewModel, tasksVm: tasksViewModel),
    );

    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.byKey(const Key('password')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('успешный логин вызывает навигацию', (tester) async {
    const fakeUser = User(id: '1', email: 'test@mail.com', token: 'tok');
    when(() => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => fakeUser);

    await tester.pumpWidget(
      buildLoginScreen(authVm: authViewModel, tasksVm: tasksViewModel),
    );

    await tester.enterText(find.byKey(const Key('email')), 'test@mail.com');
    await tester.enterText(find.byKey(const Key('password')), '123456');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // После успешного логина LoginScreen больше не показывается
    expect(find.byKey(const Key('login_button')), findsNothing);
  });

  testWidgets('ошибка логина показывает сообщение', (tester) async {
    when(() => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Неверный логин или пароль'));

    await tester.pumpWidget(
      buildLoginScreen(authVm: authViewModel, tasksVm: tasksViewModel),
    );

    await tester.enterText(find.byKey(const Key('email')), 'bad@mail.com');
    await tester.enterText(find.byKey(const Key('password')), 'wrong');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text('Неверный логин или пароль'), findsOneWidget);
  });
}

