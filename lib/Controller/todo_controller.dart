import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/Model/api_service.dart';
import 'package:to_do_list/Model/todo.dart';

class TodoController with ChangeNotifier {
  final ApiService apiService = ApiService();
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  static const String _storageKey = 'local_todos_v1';

  Future<void> fetchTodos() async {
    try {
      final remote = await apiService.getTodos();
      final local = await _loadFromStorage();

      if (local.isNotEmpty) {
        _todos = [...local];
        final localIds = _todos.map((t) => t.id).toSet();
        _todos.addAll(remote.where((r) => !localIds.contains(r.id)));
      } else {
        _todos = remote;
      }
      notifyListeners();
    } catch (e) {
      print("Error fetch: $e");
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final newTodo = await apiService.addTodo(todo);

      _todos.insert(0, newTodo);
      notifyListeners();
    } catch (e) {
      print("Error add: $e");
    }
  }

  Future<void> updateTitle(Todo todo, String newTitle) async {
    try {
      final updated = Todo(
        userId: todo.userId,
        id: todo.id,
        title: newTitle,
        completed: todo.completed,
      );

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updated;
        notifyListeners();
      }

      await apiService.updateTodo(updated);
    } catch (e) {
      print("Error update title: $e");
    }
  }

  Future<void> updateTodoLocal(Todo updatedTodo) async {
    final idx = _todos.indexWhere((t) => t.id == updatedTodo.id);
    if (idx == -1) return;

    final old = _todos[idx];
    _todos[idx] = updatedTodo;
    notifyListeners();

    try {
      final server = await apiService.updateTodo(updatedTodo);
      _todos[idx] = Todo(
        id: server.id != 0 ? server.id : updatedTodo.id,
        userId: server.userId,
        title: server.title,
        completed: server.completed,
      );
      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      _todos[idx] = old;
      notifyListeners();
      print("Update failed, rollback: $e");
      rethrow;
    }
  }

  Future<void> toggleStatus(Todo todo) async {
    try {
      final updated = Todo(
        userId: todo.userId,
        id: todo.id,
        title: todo.title,
        completed: !todo.completed,
      );
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updated;
        notifyListeners();
      }
      await apiService.updateTodo(updated);
    } catch (e) {
      print("Error update: $e");
    }
  }

  Future<void> deleteTodo(int id) async {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final removed = _todos.removeAt(idx);
    notifyListeners();

    try {
      await apiService.deleteTodo(id);
      await _saveToStorage();
    } catch (e) {
      _todos.insert(idx, removed);
      notifyListeners();
      print("Delete failed, rollback: $e");
      rethrow;
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_todos.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<List<Todo>> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List data = jsonDecode(jsonStr);
    return data.map((e) => Todo.fromJson(e)).toList();
  }

  Future<void> clearLocalSimulation() async {
    _todos = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }
}
