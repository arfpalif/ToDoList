import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:to_do_list/Model/todo.dart';

class ApiService {
  static const String baseUrl = "https://jsonplaceholder.typicode.com/";

  // GET
  Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse("$baseUrl/todos"), headers: {"Accept": "application/json"});
    print(">>> Status: ${response.statusCode}");
    print(">>> Body: ${response.body}");
    if (response.statusCode == 200) {
      List body = jsonDecode(response.body);
      return body.map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception("Gagal memuat todos, Status: ${response.statusCode}" );
    }
  }

  // PUT
  Future<Todo> updateTodo(Todo todo) async {
    final response = await http.put(
      Uri.parse("$baseUrl/todos/${todo.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal mengupdate todo");
    }
  }

  // POST (tambah data)
  Future<Todo> addTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse("$baseUrl/todos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal menambah todo");
    }
  }


  // DELETE (hapus data by ID)
  Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/todos/$id"));

    if (response.statusCode != 200) {
      throw Exception("Gagal menghapus todo");
    }
  }
}
