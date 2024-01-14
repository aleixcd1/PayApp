import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Person {
  String name;
  double money;

  Person(this.name, this.money);
}

class Account {
  String name;
  List<Person> people;

  Account(this.name, this.people);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Split Expenses App',
      home: SplitExpensesScreen(),
    );
  }
}

class SplitExpensesScreen extends StatefulWidget {
  @override
  _SplitExpensesScreenState createState() => _SplitExpensesScreenState();
}

class _SplitExpensesScreenState extends State<SplitExpensesScreen> {
  List<Account> accounts = [];
  TextEditingController accountNameController = TextEditingController();
  TextEditingController personNameController = TextEditingController();
  TextEditingController moneyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Expenses App'),
      ),
      body: accounts.isEmpty
          ? Center(
        child: ElevatedButton(
          onPressed: () {
            addAccount();
          },
          child: Text('Add Account'),
        ),
      )
          : ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(accounts[index].name),
              onTap: () {
                navigateToAccountDetails(accounts[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: accounts.isEmpty
          ? null
          : FloatingActionButton(
        onPressed: () {
          // Implement your logic for settling expenses here
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Settlement'),
                content: Text('Display settlement details here.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }

  void addAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Account'),
          content: Column(
            children: [
              TextField(
                controller: accountNameController,
                decoration: InputDecoration(labelText: 'Account Name'),
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
                addAccountWithName();
                Navigator.pop(context);
              },
              child: Text('Add Account'),
            ),
          ],
        );
      },
    );
  }

  void addPersonToAccount(int accountIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Person to Account'),
          content: Column(
            children: [
              TextField(
                controller: personNameController,
                decoration: InputDecoration(labelText: 'Person Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: moneyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Money'),
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
                addPersonToExistingAccount(accountIndex);
                Navigator.pop(context);
              },
              child: Text('Add Person'),
            ),
          ],
        );
      },
    );
  }

  void addAccountWithName() {
    setState(() {
      final newAccount = Account(accountNameController.text, []);
      accounts.add(newAccount);

      accountNameController.clear();
    });
  }

  void addPersonToExistingAccount(int accountIndex) {
    setState(() {
      final newPerson = Person(personNameController.text, double.parse(moneyController.text));
      accounts[accountIndex].people.add(newPerson);

      personNameController.clear();
      moneyController.clear();
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
  TextEditingController personMoneyController = TextEditingController();

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
              itemCount: widget.account.people.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(widget.account.people[index].name),
                    subtitle: Text('Money: \$${widget.account.people[index].money.toString()}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        editPersonMoney(index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              addPersonToAccountDetails();
            },
            child: Text('Add Person'),
          ),
        ],
      ),
    );
  }

  void editPersonMoney(int personIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Money'),
          content: Column(
            children: [
              TextField(
                controller: personMoneyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Money'),
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
                updatePersonMoney(personIndex);
                Navigator.pop(context);
              },
              child: Text('Update Money'),
            ),
          ],
        );
      },
    );
  }

  void addPersonToAccountDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String personName = '';
        double personMoney = 0.0;

        return AlertDialog(
          title: Text('Add Person'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  personName = value;
                },
                decoration: InputDecoration(labelText: 'Person Name'),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  personMoney = double.tryParse(value) ?? 0.0;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Money'),
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
                addPersonToExistingAccountDetails(personName, personMoney);
                Navigator.pop(context);
              },
              child: Text('Add Person'),
            ),
          ],
        );
      },
    );
  }

  void addPersonToExistingAccountDetails(String personName, double personMoney) {
    setState(() {
      final newPerson = Person(personName, personMoney);
      widget.account.people.add(newPerson);
    });
  }


  void updatePersonMoney(int personIndex) {
    setState(() {
      widget.account.people[personIndex].money = double.parse(personMoneyController.text);

      personMoneyController.clear();
    });
  }
}
