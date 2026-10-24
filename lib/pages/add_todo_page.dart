import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/add_todo_bloc.dart';

class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => AddTodoBloc(),
        child: const _AddTodoView(),
      );
}

class _AddTodoView extends StatefulWidget {
  const _AddTodoView();
  @override
  State<_AddTodoView> createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<_AddTodoView> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();

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
      appBar: AppBar(title: const Text('Add To-Do')),
      body: BlocConsumer<AddTodoBloc, AddTodoState>(
        listener: (context, state) {
          if (state is AddTodoSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('To-do saved!')));
            _title.clear();
            _desc.clear();
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
                        if (_form.currentState!.validate()) {
                          context.read<AddTodoBloc>().add(AddTodoSubmitted(
                              _title.text.trim(), _desc.text.trim()));
                        }
                      },
                      child: const Text('Save'),
                    ),
            ]),
          ),
        ),
      ),
    );
  }
}
