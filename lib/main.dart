import 'package:flutter/material.dart';
import 'models.dart';
import 'screens.dart';

void main() {
  runApp(MyApp());
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
