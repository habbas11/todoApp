import 'package:flutter/material.dart';
import 'package:todo/screens/to_do_list_screen.dart';
import 'constants.dart';

void main() => runApp(ToDo());

class ToDo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do App',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
      ),
      home: ToDoListScreen(),
    );
  }
}
