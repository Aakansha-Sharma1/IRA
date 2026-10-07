import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journal_editor_screen.dart';
import '../controllers/journal_controller.dart';

import '../../../../core/constants/app_dimensions.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const JournalEditorScreen())),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load journal: $error')),
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('Your journal starts here.'))
            : ListView.builder(
                padding: AppDimensions.screenPadding,
                itemCount: entries.length,
                itemBuilder: (_, index) {
                  final entry = entries[index];
                  return Card(
                    child: ListTile(
                      title: Text(entry.title),
                      subtitle: Text(entry.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => JournalEditorScreen(entry: entry))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref.read(journalControllerProvider.notifier).remove(entry.id),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
