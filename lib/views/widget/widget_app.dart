import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../expense/add_expense_sheet.dart';
import 'budget_selection_sheet.dart';

class WidgetApp extends StatelessWidget {
  final Uri initialUri;

  const WidgetApp({super.key, required this.initialUri});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: WidgetEntryPoint(initialUri: initialUri),
      ),
    );
  }
}

class WidgetEntryPoint extends StatefulWidget {
  final Uri initialUri;

  const WidgetEntryPoint({super.key, required this.initialUri});

  @override
  State<WidgetEntryPoint> createState() => _WidgetEntryPointState();
}

class _WidgetEntryPointState extends State<WidgetEntryPoint> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSheet();
    });
  }

  void _showSheet() async {
    final path = widget.initialUri.path; // e.g., '/add' or '/list'
    
    if (path == '/add') {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent, // Ensures our border radius shows
        builder: (context) => const AddExpenseSheet(),
      );
    } else if (path == '/list') {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const BudgetSelectionSheet(),
      );
    }
    
    // Allow time for modal exit animation and background tasks
    await Future.delayed(const Duration(milliseconds: 300));
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container because the actual UI is the bottom sheet
    return Container();
  }
}
