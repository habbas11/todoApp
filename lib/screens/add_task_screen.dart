import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/constants.dart';
import 'package:todo/helpers/database_helper.dart';
import 'package:todo/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  final Function updateList;

  AddTaskScreen({this.task, this.updateList});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Med', 'High'];

  @override
  void initState() {
    super.initState();
    _dateController.text = _dateFormat.format(_date);
    if (widget.task != null) {
      Task passedTask = widget.task;
      _title = passedTask.title;
      _priority = passedTask.priority;
      _date = passedTask.date;
    }
  }

  _datePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
    }
    _dateController.text = _dateFormat.format(date);
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title $_date $_priority');
      Task task = Task(title: _title, priority: _priority, date: _date);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.addTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }
      widget.updateList();
      Navigator.pop(context);
    }
  }

  _delete () {
    DatabaseHelper.instance.deleteTask(widget.task);
    widget.updateList();
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.arrow_back,
                      color: kPrimaryColor,
                      size: 40.0,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    widget.task == null ? 'Add Task' : 'Update Task',
                    style: kMainHeaderStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            style: kLabelsStyle,
                            decoration: InputDecoration(
                              labelText: 'Task Title',
                              labelStyle: kLabelsStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (input) => input.trim().isEmpty
                                ? 'Please enter a task title'
                                : null,
                            initialValue: _title,
                            onSaved: (input) => _title = input,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: TextFormField(
                            controller: _dateController,
                            onTap: _datePicker,
                            readOnly: true,
                            style: kLabelsStyle,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: kLabelsStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: DropdownButtonFormField(
                            isDense: true,
                            icon: Icon(
                              Icons.arrow_drop_down_circle,
                              color: kPrimaryColor,
                            ),
                            iconSize: 20.0,
                            items: _priorities.map((String priority) {
                              return DropdownMenuItem(
                                child: Text(
                                  priority.toString(),
                                  style: TextStyle(color: Colors.black),
                                ),
                                value: priority,
                              );
                            }).toList(),
                            style: kLabelsStyle,
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: kLabelsStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (input) => _priority == null
                                ? 'Please enter a priority level'
                                : null,
                            onChanged: (value) => _priority = value,
                            value: _priority,
                          ),
                        ),
                        Container(
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: kPrimaryColor),
                          child: TextButton(
                            onPressed: _submit,
                            child: Text(
                              widget.task == null ? 'Add Task' : 'Update Task',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ),
                        widget.task == null
                            ? SizedBox.shrink()
                            : Container(
                                margin: EdgeInsets.symmetric(vertical: 20.0),
                                height: 60.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: kPrimaryColor),
                                child: TextButton(
                                  onPressed: _delete,
                                  child: Text(
                                    'Delete Task',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
