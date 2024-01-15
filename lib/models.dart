class Expense {
  String title;
  double amount;
  String person;

  Expense(this.title, this.amount, this.person);
}

class Account {
  String name;
  List<Expense> expenses;
  List<String> people;

  Account(this.name, this.expenses, this.people);
}
