import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List toDoList = [];

  final Box _myBox = Hive.box("myBox");

  // Create initial data
  void createInitialData() {
    toDoList = [
      ["Buy groceries", false],
      ["Do Flutter homework", false],
    ];
    updateDatabase();
  }

  // Load the data from Hive
  void loadData() {
    toDoList = _myBox.get("TODOLIST", defaultValue: []);
  }

  // Update database
  Future<void> updateDatabase() async {
    await _myBox.put("TODOLIST", toDoList);
  }
}
