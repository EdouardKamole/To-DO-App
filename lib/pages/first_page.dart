import 'package:first_flutter_step/data/database.dart';
import 'package:first_flutter_step/util/dialog_box.dart';
import 'package:first_flutter_step/util/todo_tile.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Box? _myBox; // Nullable to prevent initialization issues
  final TextEditingController _controller = TextEditingController();
  final ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _myBox = await Hive.openBox("myBox");

    if (_myBox!.get("TODOLIST") == null) {
      db.createInitialData();
      await db.updateDatabase();
    } else {
      db.loadData();
    }

    setState(() {}); // Refresh UI after loading data
  }

  // Checkbox toggle
  void checkboxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDatabase();
  }

  // Save new task
  void saveNewTask() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        db.toDoList.add([_controller.text, false]);
        _controller.clear();
      });
      db.updateDatabase();
    }
    Navigator.of(context).pop();
  }

  // Create new Task (Dialog Box)
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // Delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text(
          "TO DO",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: _myBox == null
          ? const Center(
              child: CircularProgressIndicator()) // Show loader while waiting
          : db.toDoList.isEmpty
              ? const Center(
                  child: Text(
                    "No tasks added yet!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: db.toDoList.length,
                  itemBuilder: (context, index) {
                    return TodoTile(
                      taskName: db.toDoList[index][0],
                      taskCompleted: db.toDoList[index][1],
                      onChanged: (value) => checkboxChanged(value, index),
                      deleteFunction: (context) => deleteTask(index),
                    );
                  },
                ),
    );
  }
}
