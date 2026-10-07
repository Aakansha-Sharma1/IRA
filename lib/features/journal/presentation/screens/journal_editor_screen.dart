import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/journal_entry.dart';
import '../controllers/journal_controller.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  final JournalEntry? entry;
  const JournalEditorScreen({super.key, this.entry});
  @override
  ConsumerState<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _mood;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.entry?.title);
    _content = TextEditingController(text: widget.entry?.content);
    _mood = TextEditingController(text: widget.entry?.mood);
  }

  @override
  void dispose() { _title.dispose(); _content.dispose(); _mood.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) return;
    final saved = await ref.read(journalControllerProvider.notifier).save(
      id: widget.entry?.id, title: _title.text.trim(), content: _content.text.trim(),
      mood: _mood.text.trim().isEmpty ? null : _mood.text.trim(),
    );
    if (mounted && saved) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.entry == null ? 'New journal entry' : 'Edit journal entry')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
      const SizedBox(height: 16),
      TextField(controller: _mood, decoration: const InputDecoration(labelText: 'Mood (optional)')),
      const SizedBox(height: 16),
      TextField(controller: _content, minLines: 10, maxLines: 16, decoration: const InputDecoration(labelText: 'What is on your mind?')),
      const SizedBox(height: 24),
      FilledButton(onPressed: _save, child: const Text('Save entry')),
    ]),
  );
}
