import 'package:flutter/material.dart';
import 'models.dart';

class SplitExpensesScreen extends StatefulWidget {
  @override
  _SplitExpensesScreenState createState() => _SplitExpensesScreenState();
}

class _SplitExpensesScreenState extends State<SplitExpensesScreen> {
  List<Account> accounts = [];
  TextEditingController accountNameController = TextEditingController();
  TextEditingController expenseTitleController = TextEditingController();
  TextEditingController expenseAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Expenses App'),
      ),
      body: accounts.isEmpty
          ? Center(
              child: Text('No accounts available'),
            )
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(accounts[index].name),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteAccount(index);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      navigateToAccountDetails(accounts[index]);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addAccount();
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void deleteAccount(int accountIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete this account?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                removeAccount(accountIndex);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void removeAccount(int accountIndex) {
    setState(() {
      accounts.removeAt(accountIndex);
    });
  }

  void addAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String peopleList = '';

        return AlertDialog(
          title: Text('Add Account'),
          content: Column(
            children: [
              TextField(
                controller: accountNameController,
                decoration: InputDecoration(labelText: 'Account Name'),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  peopleList = value;
                },
                decoration:
                    InputDecoration(labelText: 'People (comma-separated)'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                addAccountWithNameAndPeople(peopleList);
                Navigator.pop(context);
              },
              child: Text('Add Account'),
            ),
          ],
        );
      },
    );
  }

  void addAccountWithNameAndPeople(String peopleList) {
    setState(() {
      final newAccount = Account(accountNameController.text, [], []);

      newAccount.people = peopleList.split(',').map((e) => e.trim()).toList();

      accounts.add(newAccount);

      accountNameController.clear();
    });
  }

  void navigateToAccountDetails(Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountDetailsScreen(account)),
    );
  }
}

class AccountDetailsScreen extends StatefulWidget {
  final Account account;

  AccountDetailsScreen(this.account);

  @override
  _AccountDetailsScreenState createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  TextEditingController expenseAmountController = TextEditingController();
  TextEditingController expenseTitleController = TextEditingController();
  String expensePerson = ''; // Variable para almacenar la persona seleccionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.account.expenses.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Title: ${widget.account.expenses[index].title}'),
                        Text(
                            'Person: ${widget.account.expenses[index].person}'),
                      ],
                    ),
                    subtitle: Text(
                        'Amount: \$${widget.account.expenses[index].amount.toString()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            editExpense(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteExpense(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              addExpenseToAccountDetails();
            },
            child: Icon(Icons.add),
          ),
          SizedBox(width: 16), // Espacio entre los dos botones flotantes
          FloatingActionButton(
            onPressed: () {
              calculateExpenses();
            },
            child: Icon(Icons.done),
          ),
        ],
      ),
    );
  }

  void calculateExpenses() {
    // Create a map to store the total paid by each person
    Map<String, double> totalPaidByPerson = {};

    // Iterate over the expenses and sum the amount paid by each person
    for (Expense expense in widget.account.expenses) {
      totalPaidByPerson[expense.person] =
          (totalPaidByPerson[expense.person] ?? 0) + expense.amount;
    }

    // Calculate the amount each person should pay to equalize the expenses
    double averageExpense = totalPaidByPerson.values.reduce((a, b) => a + b) /
        widget.account.people.length;

    // Create a map to store the debts
    Map<String, Map<String, double>> debts = {};

    // Iterate over the people and calculate the debts
    for (String person in widget.account.people) {
      debts[person] = {};

      // Calculate the debt of the current person
      double debt = totalPaidByPerson.containsKey(person)
          ? totalPaidByPerson[person]! - averageExpense
          : -averageExpense;

      // Iterate over the other people and assign the debts
      for (String otherPerson in widget.account.people) {
        if (person != otherPerson) {
          debts[person]![otherPerson] = 0.0; // Initialize the debt to 0
        }
      }

      // Distribute the debt among the other people
      for (String otherPerson in widget.account.people) {
        if (person != otherPerson) {
          double share = debt / (widget.account.people.length - 1);
          debts[person]![otherPerson] = share;
        }
      }
    }

    // Show the results in a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Expense Distribution'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: debts.keys.map((String person) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: debts[person]!.keys.map((String otherPerson) {
                  double amount = debts[person]![otherPerson]!;
                  if (amount > 0 && person.hashCode < otherPerson.hashCode) {
                    return Text(
                        '$otherPerson owes $person: \$${amount.toStringAsFixed(2)}');
                  } else if (amount < 0 &&
                      person.hashCode < otherPerson.hashCode) {
                    return Text(
                        '$person owes $otherPerson: \$${(-amount).toStringAsFixed(2)}');
                  } else {
                    return Container(); // Don't show duplicate debts
                  }
                }).toList(),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void editExpense(int expenseIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        expenseAmountController.text =
            widget.account.expenses[expenseIndex].amount.toString();
        expenseTitleController.text =
            widget.account.expenses[expenseIndex].title;
        expensePerson = widget.account.expenses[expenseIndex].person;

        return AlertDialog(
          title: Text('Edit Expense'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: expenseTitleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: expenseAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    choosePersonForExpense();
                  },
                  child: Text('Choose Person'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                updateExpense(expenseIndex);
                Navigator.pop(context);
              },
              child: Text('Update Expense'),
            ),
          ],
        );
      },
    );
  }

  void deleteExpense(int expenseIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                removeExpense(expenseIndex);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void addExpenseToAccountDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: expenseTitleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: expenseAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    choosePersonForExpense();
                  },
                  child: Text('Choose Person'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                addExpenseToExistingAccountDetails();
                Navigator.pop(context);
              },
              child: Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  void choosePersonForExpense() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.account.people.map((String person) {
              return ListTile(
                title: Text(person),
                onTap: () {
                  Navigator.pop(context, person);
                },
              );
            }).toList(),
          ),
        );
      },
    ).then((selectedPerson) {
      if (selectedPerson != null) {
        setState(() {
          expensePerson = selectedPerson;
        });
      }
    });
  }

  void addExpenseToExistingAccountDetails() {
    setState(() {
      final newExpense = Expense(
        expenseTitleController.text,
        double.tryParse(expenseAmountController.text) ?? 0.0,
        expensePerson,
      );

      widget.account.expenses.add(newExpense);

      // Limpiar los controladores después de agregar el gasto
      expenseTitleController.clear();
      expenseAmountController.clear();
      expensePerson = ''; // Limpiar la persona seleccionada
    });
  }

  void updateExpense(int expenseIndex) {
    setState(() {
      widget.account.expenses[expenseIndex].title = expenseTitleController.text;
      widget.account.expenses[expenseIndex].amount =
          double.tryParse(expenseAmountController.text) ?? 0.0;
      widget.account.expenses[expenseIndex].person = expensePerson;

      // Limpiar los controladores después de actualizar el gasto
      expenseTitleController.clear();
      expenseAmountController.clear();
      expensePerson = ''; // Limpiar la persona seleccionada
    });
  }

  void removeExpense(int expenseIndex) {
    setState(() {
      widget.account.expenses.removeAt(expenseIndex);
    });
  }
}
