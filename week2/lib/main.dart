import 'package:flutter/material.dart';

void main() {
  runApp(BudgetApp());
}

class BudgetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: BudgetHome(),
    );
  }
}

class BudgetHome extends StatefulWidget {
  @override
  _BudgetHomeState createState() => _BudgetHomeState();
}

class _BudgetHomeState extends State<BudgetHome> {
  bool showExpenses = false;

  double totalBudget = 60000;
  List<ExpenseCategory> expenseCategories = [
    ExpenseCategory(name: 'Groceries', budget: -4000),
    ExpenseCategory(name: 'Bills', budget: -1000),
    ExpenseCategory(name: 'Salary', budget: 65000),
  ];

  void addExpense(double budget, String category) {
    setState(() {
      expenseCategories.add(ExpenseCategory(name: category, budget: budget));
      totalBudget += budget;
    });
  }

  void deleteExpense(ExpenseCategory category) {
    setState(() {
      expenseCategories.remove(category);
      totalBudget -= category.budget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showExpenses = !showExpenses;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Budget: \$${totalBudget.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    showExpenses ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (showExpenses)
            Expanded(
              child: ListView.builder(
                itemCount: expenseCategories.length,
                itemBuilder: (context, index) => ExpenseCategoryItem(
                  category: expenseCategories[index],
                  onDelete: () => deleteExpense(expenseCategories[index]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpenseListScreen(category: expenseCategories[index]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) => AddExpenseDialog(addExpense),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ExpenseCategoryItem extends StatelessWidget {
  final ExpenseCategory category;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  ExpenseCategoryItem({
    required this.category,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.name),
      subtitle: Text('Budget: \$${category.budget.toStringAsFixed(2)}'),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}

class ExpenseListScreen extends StatelessWidget {
  final ExpenseCategory category;

  ExpenseListScreen({required this.category});

  List<Expense> expenses = [
    Expense(description: 'Groceries', amount: 50),
    Expense(description: 'Restaurant', amount: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(expenses[index].description),
          subtitle: Text('Amount: \$${expenses[index].amount.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}

class AddExpenseDialog extends StatefulWidget {
  final Function(double, String) addExpense;

  AddExpenseDialog(this.addExpense);

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  TextEditingController categoryController = TextEditingController();
  TextEditingController budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: categoryController,
            decoration: InputDecoration(labelText: 'Category'),
          ),
          TextField(
            controller: budgetController,
            decoration: InputDecoration(labelText: 'Budget'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            double budget = double.tryParse(budgetController.text) ?? 0.0;
            String category = categoryController.text.trim();
            if (budget > 0 && category.isNotEmpty) {
              widget.addExpense(budget, category);
            }
            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class ExpenseCategory {
  final String name;
  final double budget;

  ExpenseCategory({required this.name, required this.budget});
}

class Expense {
  final String description;
  final double amount;

  Expense({required this.description, required this.amount});
}
