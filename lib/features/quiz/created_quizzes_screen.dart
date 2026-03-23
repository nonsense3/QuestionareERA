import 'package:flutter/material.dart';

import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import 'quiz_builder_screen.dart';
import 'quiz_draft_store.dart';

/// Lists every quiz saved for this account (same in-memory store as Drafts / builder).
class CreatedQuizzesScreen extends StatefulWidget {
  const CreatedQuizzesScreen({
    super.key,
    required this.currentAccessKey,
    required this.currentOwnerLabel,
  });

  final String currentAccessKey;
  final String currentOwnerLabel;

  @override
  State<CreatedQuizzesScreen> createState() => _CreatedQuizzesScreenState();
}

class _CreatedQuizzesScreenState extends State<CreatedQuizzesScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<int>(
      valueListenable: QuizDraftStore.revision,
      builder: (context, revision, _) {
        final drafts =
            QuizDraftStore.allForOwner(widget.currentAccessKey);
        final count = drafts.length;

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            NeoCard(
              backgroundColor: colors.secondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your quizzes',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    count == 0
                        ? 'No quizzes created yet. Tap the button below or use Quiz → + to build one.'
                        : 'You have created $count quiz${count == 1 ? '' : 'zes'}. Tap a card to edit or share from the builder.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total: $count',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: colors.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
            NeoButton(
              label: 'Create new quiz',
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => QuizBuilderScreen(
                      currentAccessKey: widget.currentAccessKey,
                      currentOwnerLabel: widget.currentOwnerLabel,
                    ),
                  ),
                );
                if (mounted) setState(() {});
              },
              color: colors.primary,
            ),
            if (drafts.isEmpty)
              NeoCard(
                child: Text(
                  'Saved quizzes appear here after you save from the quiz builder.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              )
            else
              for (final d in drafts)
                NeoCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      d.title.isEmpty ? 'Untitled quiz' : d.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${d.questions.length} questions • ${d.theme} • saved ${_formatDate(d.savedAt)}',
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => QuizBuilderScreen(
                            initialDraft: d,
                            currentAccessKey: widget.currentAccessKey,
                            currentOwnerLabel: d.ownerLabel,
                          ),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime t) {
    final local = t.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
