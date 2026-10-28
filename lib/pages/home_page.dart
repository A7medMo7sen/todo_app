import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/todos_bloc.dart';
import '../models/todo.dart';
import 'add_todo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => TodosBloc()..add(TodosFetched()),
        child: const _HomeView(),
      );
}


Future<void> _openEditor(BuildContext context, [Todo? todo]) async {
  await Navigator.push(context,
      MaterialPageRoute(builder: (_) => AddTodoPage(todo: todo)));
  if (context.mounted) {
    context.read<TodosBloc>().add(TodosFetched());
  }
}

Future<void> _confirmDelete(BuildContext context, Todo todo) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete to-do?'),
      content: Text('"${todo.title}" will be deleted.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    context.read<TodosBloc>().add(TodoDeleted(todo.id));
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openEditor(context),
      ),
      body: BlocConsumer<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state is TodosSuccess && state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) => switch (state) {
          TodosInitial() || TodosLoading() =>
            const Center(child: CircularProgressIndicator()),
          TodosFailure(:final message) => Center(child: Text(message)),
          TodosSuccess(:final todos) => todos.isEmpty
              ? const Center(child: Text('No to-dos yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (_, i) {
                    final todo = todos[i];
                    return ListTile(
                      title: Text(todo.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(todo.description),
                          const SizedBox(height: 4),
                          Text(
                            todo.createdAt.toString().substring(0, 16),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      onTap: () => _openEditor(context, todo),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                            onPressed: () => _openEditor(context, todo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(context, todo),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        },
      ),
    );
  }
}
