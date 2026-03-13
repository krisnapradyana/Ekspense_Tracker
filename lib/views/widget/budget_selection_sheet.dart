import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/budget_controller.dart';
import '../../core/theme/app_colors.dart';

class BudgetSelectionSheet extends StatelessWidget {
  const BudgetSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetController>(
      builder: (context, controller, child) {
        final categories = controller.categories;
        final selectedId = controller.selectedWidgetBudgetId;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Tampilan Widget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Semua Budget'),
                trailing: selectedId == 'all'
                    ? const Icon(Icons.check_circle, color: AppColors.sagePrimary)
                    : null,
                onTap: () {
                  controller.updateWidgetSelection('all');
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              if (categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Belum ada kategori budget.'),
                )
              else
                ...categories.map((cat) {
                  return ListTile(
                    title: Text(cat.name),
                    subtitle: Text('Sisa: Rp ${(cat.allocatedAmount - cat.spentAmount).toStringAsFixed(0)}'),
                    trailing: selectedId == cat.id
                        ? const Icon(Icons.check_circle, color: AppColors.sagePrimary)
                        : null,
                    onTap: () {
                      controller.updateWidgetSelection(cat.id);
                      Navigator.pop(context);
                    },
                  );
                }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
