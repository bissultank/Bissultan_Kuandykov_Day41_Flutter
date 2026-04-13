// integration_test/app_test.dart
//
// Integration Test: полный пользовательский сценарий
// «Логин → Список задач → Добавить задачу → Выйти»
//
// КЛЮЧЕВЫЕ МОМЕНТЫ:
// - Используем FakeApiClient вместо реального HTTP → нет сетевых запросов
// - AppDependencies принимает тестовые зависимости (DI)
// - Тест не трогает production данные
// - pumpAndSettle() ждёт завершения всех анимаций

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/core/di.dart';
import 'package:tasks_app/data/datasources/api_client.dart';
import 'package:tasks_app/data/datasources/local_storage.dart';
import 'package:tasks_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test — полный сценарий пользователя', () {
    late FakeApiClient fakeApi;
    late InMemoryStorage fakeStorage;
    late AppDependencies deps;

    setUp(() {
      // DI: подменяем все внешние зависимости тестовыми
      // Реальных сетевых запросов НЕТ
      fakeApi = FakeApiClient();
      fakeStorage = InMemoryStorage();
      deps = AppDependencies(
        apiClient: fakeApi,
        localStorage: fakeStorage,
      );
    });

    testWidgets(
      'Happy path: Логин → Список задач → Добавить → Удалить → Выйти',
      (tester) async {
        // ── ЗАПУСК ПРИЛОЖЕНИЯ ──────────────────────────────────────────
        await tester.pumpWidget(MyApp(dependencies: deps));
        await tester.pumpAndSettle();

        // Должны видеть экран логина
        expect(find.byKey(const Key('email')), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);

        // ── ШАГ 1: ЛОГИН ───────────────────────────────────────────────
        await tester.enterText(
          find.byKey(const Key('email')),
          'test@mail.com',
        );
        await tester.enterText(
          find.byKey(const Key('password')),
          '123456',
        );
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // После логина переходим на экран задач
        expect(find.text('Мои задачи'), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsNothing);

        // ── ШАГ 2: СПИСОК ЗАДАЧ ЗАГРУЖАЕТСЯ ────────────────────────────
        // FakeApiClient возвращает 3 задачи
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('tasks_list')), findsOneWidget);
        expect(find.text('Купить продукты'), findsOneWidget);
        expect(find.text('Почитать документацию Flutter'), findsOneWidget);
        expect(find.text('Написать тесты'), findsOneWidget);

        // ── ШАГ 3: ДОБАВЛЕНИЕ ЗАДАЧИ ───────────────────────────────────
        await tester.enterText(
          find.byKey(const Key('taskInput')),
          'New Task from Integration Test',
        );
        await tester.tap(find.byKey(const Key('add_button')));
        await tester.pumpAndSettle();

        // Новая задача появилась в списке
        expect(find.text('New Task from Integration Test'), findsOneWidget);

        // Задач стало 4
        expect(find.byType(ListTile), findsNWidgets(4));

        // ── ШАГ 4: УДАЛЕНИЕ ЗАДАЧИ ─────────────────────────────────────
        await tester.tap(find.byKey(const Key('delete_task_task_1')));
        await tester.pumpAndSettle();

        // 'Купить продукты' больше нет в списке
        expect(find.text('Купить продукты'), findsNothing);
        expect(find.byType(ListTile), findsNWidgets(3));

        // ── ШАГ 5: ВЫХОД (LOGOUT) ──────────────────────────────────────
        await tester.tap(find.byKey(const Key('logout_button')));
        await tester.pumpAndSettle();

        // Вернулись на экран логина
        expect(find.byKey(const Key('email')), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);
        expect(find.text('Мои задачи'), findsNothing);
      },
    );

    testWidgets(
      'Error path: неверные данные логина показывают ошибку',
      (tester) async {
        await tester.pumpWidget(MyApp(dependencies: deps));
        await tester.pumpAndSettle();

        // Вводим неверные данные
        await tester.enterText(
          find.byKey(const Key('email')),
          'wrong@mail.com',
        );
        await tester.enterText(
          find.byKey(const Key('password')),
          'badpassword',
        );
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Остаёмся на экране логина
        expect(find.byKey(const Key('login_button')), findsOneWidget);
        // Видим сообщение об ошибке
        expect(find.byKey(const Key('error_message')), findsOneWidget);
      },
    );

    testWidgets(
      'DI проверка: FakeApiClient используется — реальных запросов нет',
      (tester) async {
        // Сбрасываем FakeApiClient перед тестом
        fakeApi.reset();

        await tester.pumpWidget(MyApp(dependencies: deps));
        await tester.pumpAndSettle();

        // Логинимся
        await tester.enterText(find.byKey(const Key('email')), 'test@mail.com');
        await tester.enterText(find.byKey(const Key('password')), '123456');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Данные приходят из FakeApiClient (фиксированные JSON)
        expect(find.text('Купить продукты'), findsOneWidget);

        // Токен сохранён в InMemoryStorage (не в SharedPreferences)
        final token = await fakeStorage.getToken();
        expect(token, isNotNull);
        expect(token, isNotEmpty);
      },
    );
  });
}
