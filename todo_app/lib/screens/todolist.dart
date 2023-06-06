import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/screens/addtask.dart';
import 'package:http/http.dart' as http;

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => ToDoListState();
}

class Item {
  final int id;
  final String title;
  final String description;

  // Add other properties according to your API model

  Item({required this.id, required this.title, required this.description});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'], title: json['title'], description: json['description']
        // Map other properties from JSON to class fields
        );
  }
}

class ToDoListState extends State<ToDoList> {
  List<dynamic> items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
        child: Text('Todo List'),
      )),
      body: RefreshIndicator(
        onRefresh: fetchTodo,
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item.id;
              return ListTile(
                leading: Text('${index + 1}'),
                title: Text(item.title),
                subtitle: Text(item.description),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'delete') {
                      deletebyId(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      )
                    ];
                  },
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text('Add Todo'),
      ),
    );
  }

  void navigateToAddPage() {
    final route = MaterialPageRoute(
      builder: (context) => AddTask(),
    );
    Navigator.push(context, route);
  }

  Future<void> deletebyId(int id) async {
    final url = 'https://10.0.2.2:7216/api/todo/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element(id) != id).toList();
      setState(() {
        items = filtered;
      });
    } else {}
  }

  Future<void> fetchTodo() async {
    final url = 'https://10.0.2.2:7216/api/todo';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        items = responseData.map((json) => Item.fromJson(json)).toList();
      });
    } else {
      // ignore: use_build_context_synchronously
    }
  }
}
