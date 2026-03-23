import 'package:flutter/material.dart';

import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import 'quiz_draft_store.dart';

class QuizTakeScreen extends StatefulWidget {
  const QuizTakeScreen({
    super.key,
    required this.quiz,
  });

  final QuizDraftData quiz;

  @override
  State<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends State<QuizTakeScreen> {
  late final List<TextEditingController> _answers;

  @override
  void initState() {
    super.initState();
    _answers = widget.quiz.questions.map((_) => TextEditingController()).toList();
  }

  @override
  void dispose() {
    for (final c in _answers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title.isEmpty ? 'Shared Quiz' : widget.quiz.title)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          NeoCard(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(
              'Shared by ${widget.quiz.ownerLabel}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          for (var i = 0; i < widget.quiz.questions.length; i++)
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${i + 1}. ${widget.quiz.questions[i].text}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _answers[i],
                    decoration: const InputDecoration(
                      hintText: 'Your answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          NeoButton(
            label: 'Submit Quiz',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz submitted successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
