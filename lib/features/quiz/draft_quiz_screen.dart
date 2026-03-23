import 'package:flutter/material.dart';

import '../../shared/widgets/neo_card.dart';
import 'quiz_builder_screen.dart';
import 'quiz_draft_store.dart';

class DraftQuizScreen extends StatelessWidget {
  const DraftQuizScreen({
    super.key,
    required this.currentAccessKey,
  });

  final String currentAccessKey;

  @override
  Widget build(BuildContext context) {
    final drafts = QuizDraftStore.allForOwner(currentAccessKey);
    return Scaffold(
      appBar: AppBar(title: const Text('Draft Quizzes')),
      body: drafts.isEmpty
          ? const Center(
              child: Text('No draft quizzes yet. Save one from quiz builder.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                final d = drafts[index];
                return NeoCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      d.title.isEmpty ? 'Untitled Draft' : d.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${d.questions.length} questions • ${d.theme}',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizBuilderScreen(
                            initialDraft: d,
                            currentAccessKey: currentAccessKey,
                            currentOwnerLabel: d.ownerLabel,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
