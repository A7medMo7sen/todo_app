import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/todos_bloc.dart';
import 'add_todo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => TodosBloc()..add(TodosFetched()),
        child: const _HomeView(),
      );
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddTodoPage()));
          // back from Add screen -> load list again
          if (context.mounted) {
            context.read<TodosBloc>().add(TodosFetched());
          }
        },
      ),
      body: BlocBuilder<TodosBloc, TodosState>(
        builder: (context, state) => switch (state) {
          TodosInitial() || TodosLoading() =>
            const Center(child: CircularProgressIndicator()),
          TodosFailure(:final message) => Center(child: Text(message)),
          TodosSuccess(:final todos) => todos.isEmpty
              ? const Center(child: Text('No to-dos yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(todos[i].title),
                    subtitle: Text(todos[i].description),
                    trailing:
                        Text(todos[i].createdAt.toString().substring(0, 16)),
                  ),
                ),
        },
      ),
    );
  }
}
