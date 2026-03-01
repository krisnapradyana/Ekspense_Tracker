import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/controllers/budget_controller.dart';

void main() {
  testWidgets('ExpenseTrackerApp renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BudgetController()),
        ],
        child: const ExpenseTrackerApp(),
      ),
    );

    // Verify that the title exists.
    expect(find.text('Sisa Budget'), findsOneWidget);
  });
}
