import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo.dart';

sealed class TodosEvent {}

class TodosFetched extends TodosEvent {}

class TodoDeleted extends TodosEvent {
  TodoDeleted(this.id);
  final String id;
}

sealed class TodosState {}

class TodosInitial extends TodosState {}

class TodosLoading extends TodosState {}

class TodosSuccess extends TodosState {
  TodosSuccess(this.todos, {this.error});
  final List<Todo> todos;
  final String? error;
}

class TodosFailure extends TodosState {
  TodosFailure(this.message);
  final String message;
}

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc() : super(TodosInitial()) {
    on<TodosFetched>((event, emit) async {
      emit(TodosLoading());
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final snap = await FirebaseFirestore.instance
            .collection('todos')
            .where('userId', isEqualTo: uid)
            .get();

        final todos = snap.docs.map((d) {
          final m = d.data();
          return Todo(
            id: d.id,
            title: m['title'] ?? '',
            description: m['description'] ?? '',
            createdAt:
                (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        emit(TodosSuccess(todos));
      } catch (e) {
        emit(TodosFailure('Could not load your to-dos.'));
      }
    });

    on<TodoDeleted>((event, emit) async {
      final currentState = state;
      if (currentState is TodosSuccess) {
        try {
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(event.id)
              .delete();
          final updatedTodos =
              currentState.todos.where((t) => t.id != event.id).toList();
          emit(TodosSuccess(updatedTodos));
        } catch (e) {
          emit(TodosSuccess(currentState.todos,
              error: 'Could not delete to-do.'));
        }
      }
    });
  }
}
