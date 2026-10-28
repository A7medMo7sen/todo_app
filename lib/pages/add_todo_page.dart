import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/add_todo_bloc.dart';
import '../models/todo.dart';

class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key, this.todo});
  final Todo? todo;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => AddTodoBloc(),
        child: _AddTodoView(todo: todo),
      );
}

class _AddTodoView extends StatefulWidget {
  const _AddTodoView({this.todo});
  final Todo? todo;
  @override
  State<_AddTodoView> createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<_AddTodoView> {
  final _form = GlobalKey<FormState>();
  // fill the fields with old values when editing
  late final _title = TextEditingController(text: widget.todo?.title);
  late final _desc = TextEditingController(text: widget.todo?.description);

  bool get _isEdit => widget.todo != null;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit To-Do' : 'Add To-Do')),
      body: BlocConsumer<AddTodoBloc, AddTodoState>(
        listener: (context, state) {
          if (state is AddTodoSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(_isEdit ? 'To-do updated!' : 'To-do saved!')));
            if (_isEdit) {
              Navigator.pop(context); // back to Home, list reloads
            } else {
              _title.clear();
              _desc.clear();
            }
          } else if (state is AddTodoFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: _required,
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: _required,
              ),
              const SizedBox(height: 24),
              state is AddTodoLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (!_form.currentState!.validate()) return;
                        final title = _title.text.trim();
                        final desc = _desc.text.trim();
                        final bloc = context.read<AddTodoBloc>();
                        if (_isEdit) {
                          bloc.add(
                              UpdateTodoSubmitted(widget.todo!.id, title, desc));
                        } else {
                          bloc.add(AddTodoSubmitted(title, desc));
                        }
                      },
                      child: Text(_isEdit ? 'Save changes' : 'Save'),
                    ),
            ]),
          ),
        ),
      ),
    );
  }
}
