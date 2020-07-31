import '../screens/homescreen.dart';

List<OperationCard> datas = data
    .map(
      (item) => OperationCard(
        operation: item['operation'],
        selectedIcon: item['selectedIcon'],
        unselectedIcon: item['unselectedIcon'],
      ),
    )
    .toList();

var data = [
  {
    "operation": "Add\nIncome",
    "selectedIcon": "assets/images/income_active.svg",
    "unselectedIcon": "assets/images/income_inactive.svg",
  },
  {
    "operation": "Add\nExpense",
    "selectedIcon": "assets/images/expense_active.svg",
    "unselectedIcon": "assets/images/expense_inactive.svg",
  },
  {
    "operation": "Insight\nTracking",
    "selectedIcon": "assets/images/insight_active.svg",
    "unselectedIcon": "assets/images/insight_inactive.svg",
  },
];
