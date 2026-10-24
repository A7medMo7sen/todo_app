import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
sealed class AddTodoEvent {}

class AddTodoSubmitted extends AddTodoEvent {
  AddTodoSubmitted(this.title, this.description);
  final String title, description;
}

// States
sealed class AddTodoState {}

class AddTodoInitial extends AddTodoState {}

class AddTodoLoading extends AddTodoState {}

class AddTodoSuccess extends AddTodoState {}

class AddTodoFailure extends AddTodoState {
  AddTodoFailure(this.message);
  final String message;
}

// Bloc
class AddTodoBloc extends Bloc<AddTodoEvent, AddTodoState> {
  AddTodoBloc() : super(AddTodoInitial()) {
    on<AddTodoSubmitted>((event, emit) async {
      emit(AddTodoLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Not signed in.');
        await FirebaseFirestore.instance.collection('todos').add({
          'userId': user.uid, // link todo to user
          'title': event.title,
          'description': event.description,
          'createdAt': FieldValue.serverTimestamp(), // auto date
        });
        emit(AddTodoSuccess());
      } catch (e) {
        emit(AddTodoFailure('Could not save to-do. Try again.'));
      }
    });
  }
}
