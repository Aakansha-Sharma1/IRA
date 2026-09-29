import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/app/app.dart';
import 'package:ira_app/core/config/app_config.dart';
import 'package:ira_app/core/storage/storage_service.dart';
import 'package:ira_app/core/widgets/ira_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('IraApp initial launch smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    const config = AppConfig(
      environment: AppEnvironmentType.development,
      apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
      enableDebugLogs: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const IraApp(),
      ),
    );

    // Initial pump shows SplashScreen
    expect(find.byType(IraApp), findsOneWidget);
  });

  testWidgets('IraButton stays inside a tight two-button row without overflow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: Row(
                children: [
                  Expanded(
                    child: IraButton(
                      text: "Complete today's check-in",
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: IraButton(
                      text: 'Mood history',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
