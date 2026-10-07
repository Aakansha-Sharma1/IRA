import 'package:flutter/material.dart';

class YogaScreen extends StatelessWidget {
  const YogaScreen({super.key});
  static const sessions = [
    ('Morning mobility', 'Beginner', '10 min', 'Gentle stretches for a calm start.'),
    ('Evening release', 'Beginner', '12 min', 'Slow movements to release daily tension.'),
    ('Breath and balance', 'Beginner', '8 min', 'A short standing practice for focus.'),
  ];
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Yoga')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Move with care', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Choose a short beginner-friendly practice. Stop if anything feels painful.'),
      const SizedBox(height: 20),
      ...sessions.map((session) => Card(child: ListTile(
        leading: const Icon(Icons.self_improvement_rounded),
        title: Text(session.$1),
        subtitle: Text('${session.$2} · ${session.$3}\n${session.$4}'),
        isThreeLine: true,
        trailing: const Icon(Icons.play_arrow_rounded),
        onTap: () => showModalBottomSheet<void>(context: context, builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(session.$1, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12), Text(session.$4), const SizedBox(height: 20), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Start session'))]))),
      ))),
    ]),
  );
}
