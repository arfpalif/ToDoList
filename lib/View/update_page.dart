import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Controller/todo_controller.dart';
import 'package:to_do_list/Model/todo.dart';

class updatePage extends StatefulWidget {
  const updatePage({super.key});

  @override
  State<updatePage> createState() => _updatePageState();
}

class _updatePageState extends State<updatePage> {
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambahkan Tugas"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Masukkan judul tugas",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;

                final newTask = Todo(
                  userId: 1,
                  id: DateTime.now().millisecondsSinceEpoch, // biar unik lokal
                  title: titleController.text,
                  completed: false,
                );

                try {
                  await Provider.of<TodoController>(context, listen: false)
                      .addTodo(newTask);

                  Navigator.pop(context); // balik ke homepage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tugas berhasil ditambahkan!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text("Masukkan Tugas"),
            ),
          ],
        ),
      ),
    );
  }
}
