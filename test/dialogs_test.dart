import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/busy_button.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';

/// Snackbars and spinners animate, so pump fixed frames instead of pumpAndSettle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Lets the snack time out and animate away so no ticker outlives the test.
Future<void> _snackGone(WidgetTester tester) async {
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pumpApp(WidgetTester tester) async {
  Get.reset();
  await tester.pumpWidget(
    const GetMaterialApp(home: Scaffold(body: Text('home'))),
  );
}

void main() {
  // Regression: every save shows a success snack and then closed its dialog
  // with Get.back(), which closes the snack instead, leaving the dialog open.
  testWidgets('closeDialog closes the dialog while a snackbar shows', (
    tester,
  ) async {
    await _pumpApp(tester);
    Get.dialog(const AlertDialog(title: Text('Edit customer')));
    await _settle(tester);
    showSuccessSnack('Saved');
    await _settle(tester);
    expect(Get.isSnackbarOpen, isTrue);

    closeDialog();
    await _settle(tester);

    expect(find.text('Edit customer'), findsNothing);
    expect(find.text('home'), findsOneWidget);
    await _snackGone(tester);
  });

  testWidgets('closeDialog does nothing without a dialog', (tester) async {
    await _pumpApp(tester);
    closeDialog();
    await _settle(tester);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('confirmAction confirms while a snackbar shows', (tester) async {
    await _pumpApp(tester);
    showErrorSnack('Something failed');
    await _settle(tester);

    String? result;
    confirmAction(title: 'Pause goal?', message: '').then((r) => result = r);
    await _settle(tester);
    await tester.tap(find.text('Confirm'));
    await _settle(tester);

    expect(result, '');
    expect(find.text('Pause goal?'), findsNothing);
    await _snackGone(tester);
  });

  group('BusyButton', () {
    Future<void> pump(
      WidgetTester tester, {
      required bool busy,
      VoidCallback? onPressed,
    }) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusyButton(
            label: 'Save',
            icon: Icons.save_outlined,
            busy: busy,
            onPressed: onPressed,
          ),
        ),
      ),
    );

    testWidgets('shows a spinner and ignores taps while busy', (tester) async {
      var taps = 0;
      await pump(tester, busy: true, onPressed: () => taps++);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.save_outlined), findsNothing);
      await tester.tap(find.text('Save'));
      expect(taps, 0);
    });

    testWidgets('shows its icon and fires when idle', (tester) async {
      var taps = 0;
      await pump(tester, busy: false, onPressed: () => taps++);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.save_outlined), findsOneWidget);
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });
  });
}
