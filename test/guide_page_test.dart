import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolineras_can/features/guide/guide_page.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> openGuide(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/guide?first=1'),
              child: const Text('home'),
            ),
          ),
        ),
        GoRoute(
          path: '/guide',
          builder: (context, state) =>
              GuidePage(firstLaunch: state.uri.queryParameters['first'] == '1'),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.text('Cómo usar GasoCan'), findsOneWidget);
  }

  Future<bool?> seen() async =>
      (await SharedPreferences.getInstance()).getBool(GuidePage.seenKey);

  testWidgets('Skipping the guide returns home and marks it as seen', (
    tester,
  ) async {
    await openGuide(tester);
    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(await seen(), isTrue);
  });

  testWidgets('Finishing every step marks the guide as seen', (tester) async {
    await openGuide(tester);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(await seen(), isTrue);
  });

  testWidgets('System back on first launch also marks the guide as seen', (
    tester,
  ) async {
    await openGuide(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(await seen(), isTrue);
  });
}
