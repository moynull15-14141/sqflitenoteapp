import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(test());
}

class test extends StatelessWidget {
  const test({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Database database;
  List<Map<String, dynamic>> todos = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() async {
    final path = join(await getDatabasesPath(), 'todoss.db');
    database = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE todoss(id INTEGER PRIMARY KEY, name TEXT, note TEXT)",
        );
      },
      version: 1,
    );
    refreshTodoList();
  }

  void refreshTodoList() {
    database.query('todoss', columns: ['id', 'name', 'note']).then((todoList) {
      setState(() {
        todos = todoList;
      });
    });
  }

  void addName() {
    final String name = namecontroller.text;
    final String note = notecontroller.text;
    if (name.isNotEmpty && note.isNotEmpty) {
      database.insert('todoss', {'name': name, 'note': note});
      refreshTodoList();
      namecontroller.clear();
      notecontroller.clear();
    }
  }

  void removeName(int id) {
    database.delete('todoss', where: 'id= ?', whereArgs: [id]);
    refreshTodoList();
  }

  TextEditingController namecontroller = TextEditingController();
  TextEditingController notecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test2"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: namecontroller,
              decoration: InputDecoration(
                labelText: "Name",
                contentPadding: EdgeInsets.all(16.0),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 1, color: Colors.black), //<-- SEE HERE
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: notecontroller,
              decoration: InputDecoration(
                labelText: "Note",
                contentPadding: EdgeInsets.all(30.0),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 1, color: Colors.black), //<-- SEE HERE
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      title: Text(
                        todo['name'],
                      ),
                      subtitle: Text(todo['note'].toString()),
                      trailing: IconButton(
                          onPressed: () {
                            removeName(todo['id']);
                          },
                          icon: Icon(Icons.delete)),
                    );
                  })),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addName,
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    database.close();
    super.dispose();
  }
}
