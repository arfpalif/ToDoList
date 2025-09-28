import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Controller/todo_controller.dart';
import 'package:to_do_list/View/add_page.dart';
import 'package:to_do_list/View/update_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TodoController>(context, listen: false).fetchTodos());
  }

  @override
  Widget build(BuildContext context) {
    final todoController = Provider.of<TodoController>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Todo App")),
      body: Consumer<TodoController>(
        builder: (context, controller, _) {
          if (controller.todos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: controller.todos.length,
            itemBuilder: (context, index) {
              final todo = controller.todos[index];
              return ListTile(
                title: Text(todo.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      todo.completed ? Icons.check_circle : Icons.cancel,
                      color: todo.completed ? Colors.green : Colors.red,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "toggle") {
                          todoController.toggleStatus(todo);
                        } else if (value == "edit") {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController(text: todo.title);
                              return AlertDialog(
                                title: const Text("Edit Tugas"),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(hintText: "Masukkan judul baru"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Batal"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (controller.text.isNotEmpty) {
                                        Provider.of<TodoController>(context, listen: false)
                                            .updateTitle(todo, controller.text);
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Simpan"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (value == "delete") {
                          todoController.deleteTodo(todo.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: "edit", child: Text("Edit Task")),
                        PopupMenuItem(
                          value: "toggle",
                          child: Text(todo.completed
                              ? "Tandai Belum Selesai"
                              : "Tandai Selesai"),
                        ),
                        const PopupMenuItem(
                            value: "delete", child: Text("Hapus Task")),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
        tooltip: 'Increment',
        onPressed: (){
          Navigator.push(context, MaterialPageRoute<void>(builder:(context) => addPage() ));
        },
        label: Text("Tambah tugas"),
      ),
    );
  }
}
