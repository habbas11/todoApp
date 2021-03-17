import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/helpers/database_helper.dart';
import 'package:todo/models/task_model.dart';
import '../constants.dart';
import 'add_task_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18.0,
                decoration: task.status == 1
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(
              '${_dateFormat.format(task.date)} * ${task.priority}',
              style: TextStyle(
                fontSize: 15.0,
                decoration: task.status == 1
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(task);
                _updateTaskList();
              },
              value: task.status == 1 ? true : false,
              activeColor: Theme.of(context).primaryColor,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(
                  task: task,
                  updateList: _updateTaskList,
                ),
              ),
            ),
          ),
          Divider(
            thickness: 0.8,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  _delete(Task task) {
    DatabaseHelper.instance.deleteTask(task);
    _updateTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add),
          elevation: 12.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(
                  updateList: _updateTaskList,
                ),
              ),
            );
          },
        ),
        body: FutureBuilder(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final int completedTasks = snapshot.data
                .where((Task task) => task.status == 1)
                .toList()
                .length;
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 80.0),
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 50.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Tasks',
                          style: kMainHeaderStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          '$completedTasks of ${snapshot.data.length}',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  );
                }
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.2,
                  actions: [
                    IconSlideAction(
                      caption: 'Delete',
                      color: kPrimaryColor,
                      icon: Icons.delete,
                      onTap: () => _delete(snapshot.data[index - 1]),
                    ),
                  ],
                  secondaryActions: [
                    IconSlideAction(
                      caption: 'Edit',
                      color: kPrimaryColor,
                      icon: Icons.edit,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskScreen(
                            task: snapshot.data[index - 1],
                            updateList: _updateTaskList,
                          ),
                        ),
                      ),
                    ),
                  ],
                  child: _buildTask(snapshot.data[index - 1]),
                );
              },
            );
          },
        ));
  }
}
