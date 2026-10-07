import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/todo_controller.dart';
import '../../domain/entities/todo_item.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});
  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  Future<void> _add([TodoItem? item]) async {
    final title = TextEditingController(text: item?.title);
    final description = TextEditingController(text: item?.description);
    await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(item == null ? 'New todo' : 'Edit todo'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                    controller: description,
                    decoration:
                        const InputDecoration(labelText: 'Description')),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      if (title.text.trim().isNotEmpty) {
                        await ref.read(todoControllerProvider.notifier).save(
                            id: item?.id,
                            title: title.text.trim(),
                            description: description.text.trim().isEmpty
                                ? null
                                : description.text.trim(),
                            isCompleted: item?.isCompleted);
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Save')),
              ],
            ));
    title.dispose();
    description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todoControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      floatingActionButton:
          FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load todos: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Nothing on your list yet.'))
            : ListView(
                children: items
                    .map((item) => CheckboxListTile(
                          value: item.isCompleted,
                          title: Text(item.title,
                              style: TextStyle(
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null)),
                          subtitle: item.description == null
                              ? null
                              : Text(item.description!),
                          onChanged: (value) => ref
                              .read(todoControllerProvider.notifier)
                              .save(
                                  id: item.id,
                                  title: item.title,
                                  description: item.description,
                                  isCompleted: value),
                          secondary: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _add(item);
                                }
                                if (value == 'delete') {
                                  ref
                                      .read(todoControllerProvider.notifier)
                                      .remove(item.id);
                                }
                              },
                              itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'edit', child: Text('Edit')),
                                    PopupMenuItem(
                                        value: 'delete', child: Text('Delete'))
                                  ]),
                        ))
                    .toList(),
              ),
      ),
    );
  }
}
