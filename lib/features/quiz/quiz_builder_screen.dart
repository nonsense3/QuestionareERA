import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import 'quiz_draft_store.dart';

class QuizBuilderScreen extends StatefulWidget {
  const QuizBuilderScreen({
    super.key,
    this.initialDraft,
    required this.currentAccessKey,
    required this.currentOwnerLabel,
  });

  final QuizDraftData? initialDraft;
  final String currentAccessKey;
  final String currentOwnerLabel;

  @override
  State<QuizBuilderScreen> createState() => _QuizBuilderScreenState();
}

class _QuizBuilderScreenState extends State<QuizBuilderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final String _draftId;
  String _quizTheme = 'Neo Classic';
  bool _shuffleQuestions = false;
  bool _publishInstantly = false;
  final List<_QuestionDraft> _questions = [
    _QuestionDraft(type: 'Multiple Choice'),
  ];
  @override
  void initState() {
    super.initState();
    _draftId = widget.initialDraft?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final draft = widget.initialDraft;
    if (draft == null) return;
    _titleController.text = draft.title;
    _descriptionController.text = draft.description;
    _quizTheme = draft.theme;
    _shuffleQuestions = draft.shuffleQuestions;
    _publishInstantly = draft.publishInstantly;
    _questions
      ..clear()
      ..addAll(draft.questions.map(_QuestionDraft.fromData));
    if (_questions.isEmpty) {
      _questions.add(_QuestionDraft(type: 'Multiple Choice'));
    }
  }

  final List<_ImageAttachment> _attachments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          NeoCard(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Text(
              'Advanced Question Builder',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            ),
          ),
          NeoCard(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Quiz Title',
                    hintText: 'Weekly AI Sprint',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Give short instructions and rules.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _quizTheme,
                  decoration: const InputDecoration(
                    labelText: 'Question Theme',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Neo Classic',
                      child: Text('Neo Classic'),
                    ),
                    DropdownMenuItem(
                      value: 'Corporate Pro',
                      child: Text('Corporate Pro'),
                    ),
                    DropdownMenuItem(
                      value: 'Arcade Night',
                      child: Text('Arcade Night'),
                    ),
                    DropdownMenuItem(
                      value: 'Minimal Focus',
                      child: Text('Minimal Focus'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _quizTheme = value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Shuffle questions'),
                  value: _shuffleQuestions,
                  onChanged: (v) => setState(() => _shuffleQuestions = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Publish immediately'),
                  value: _publishInstantly,
                  onChanged: (v) => setState(() => _publishInstantly = v),
                ),
              ],
            ),
          ),
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quiz Banner / Images',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 10),
                NeoButton(
                  label: 'Upload Image',
                  onPressed: _pickImage,
                  color: Colors.white,
                ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attachments
                        .map(
                          (a) => Chip(
                            label: Text(a.name),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => setState(() {
                              _attachments.remove(a);
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          for (var i = 0; i < _questions.length; i++)
            _buildQuestionCard(_questions[i], i),
          NeoButton(
            label: 'Add Question',
            onPressed: () {
              setState(() {
                _questions.add(_QuestionDraft(type: 'Multiple Choice'));
              });
            },
          ),
          const SizedBox(height: 10),
          NeoButton(
            label: 'Save Quiz Draft',
            onPressed: () {
              QuizDraftStore.upsert(_toDraftData());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Draft saved with ${_questions.length} questions and ${_attachments.length} image(s).',
                  ),
                ),
              );
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 10),
          NeoButton(
            label: 'Submit Quiz',
            onPressed: _submitQuiz,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          NeoButton(
            label: 'Share Quiz Link',
            onPressed: _shareQuizLink,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(_QuestionDraft question, int index) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              IconButton(
                onPressed: _questions.length <= 1
                    ? null
                    : () {
                        setState(() {
                          final q = _questions.removeAt(index);
                          q.dispose();
                        });
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: question.questionController,
            decoration: const InputDecoration(
              labelText: 'Question text',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: question.type,
            decoration: const InputDecoration(
              labelText: 'Question Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Multiple Choice',
                child: Text('Multiple Choice'),
              ),
              DropdownMenuItem(value: 'Checkbox', child: Text('Checkbox')),
              DropdownMenuItem(value: 'Short Answer', child: Text('Short Answer')),
              DropdownMenuItem(value: 'Paragraph', child: Text('Paragraph')),
              DropdownMenuItem(value: 'True/False', child: Text('True/False')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => question.type = value);
            },
          ),
          const SizedBox(height: 10),
          if (question.usesOptions)
            ...question.optionControllers.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Option ${optionIndex + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: question.optionControllers.length <= 2
                          ? null
                          : () => setState(() {
                                question.removeOption(optionIndex);
                              }),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ],
                ),
              );
            }),
          if (question.usesOptions)
            TextButton.icon(
              onPressed: () => setState(question.addOption),
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: question.pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Points',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: question.timerController,
                  enabled: question.timerEnabled,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        question.timerEnabled ? 'Timer (sec)' : 'Timer Off',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable timer for this question'),
            value: question.timerEnabled,
            onChanged: (v) => setState(() => question.timerEnabled = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Required'),
            value: question.required,
            onChanged: (v) => setState(() => question.required = v),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    setState(() {
      _attachments.add(
        _ImageAttachment(
          name: file.name,
          bytes: file.bytes,
        ),
      );
    });
  }

  QuizDraftData _toDraftData() {
    return QuizDraftData(
      id: _draftId,
      ownerAccessKey: widget.currentAccessKey,
      ownerLabel: widget.currentOwnerLabel,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      theme: _quizTheme,
      shuffleQuestions: _shuffleQuestions,
      publishInstantly: _publishInstantly,
      savedAt: DateTime.now(),
      questions: _questions
          .map(
            (q) => QuizQuestionData(
              text: q.questionController.text.trim(),
              type: q.type,
              options:
                  q.optionControllers.map((c) => c.text.trim()).toList(),
              points: int.tryParse(q.pointsController.text.trim()) ?? 1,
              required: q.required,
              timerEnabled: q.timerEnabled,
              timerSeconds: q.timerEnabled
                  ? int.tryParse(q.timerController.text.trim()) ?? 30
                  : null,
            ),
          )
          .toList(),
    );
  }

  void _submitQuiz() {
    final draft = _toDraftData();
    final link = QuizDraftStore.submitAndCreateShareLink(draft);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz submitted. Share link ready: $link'),
      ),
    );
  }

  Future<void> _shareQuizLink() async {
    final draft = _toDraftData();
    final link = QuizDraftStore.submitAndCreateShareLink(draft);
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz link copied: $link'),
      ),
    );
  }
}

class _QuestionDraft {
  _QuestionDraft({required this.type})
      : questionController = TextEditingController(),
        pointsController = TextEditingController(text: '1'),
        timerController = TextEditingController(text: '30'),
        optionControllers = [
          TextEditingController(),
          TextEditingController(),
        ];

  _QuestionDraft.fromData(QuizQuestionData data)
      : type = data.type,
        required = data.required,
        timerEnabled = data.timerEnabled,
        questionController = TextEditingController(text: data.text),
        pointsController = TextEditingController(text: '${data.points}'),
        timerController = TextEditingController(
          text: '${data.timerSeconds ?? 30}',
        ),
        optionControllers = data.options.isEmpty
            ? [TextEditingController(), TextEditingController()]
            : data.options.map((o) => TextEditingController(text: o)).toList();

  String type;
  bool required = true;
  bool timerEnabled = true;
  final TextEditingController questionController;
  final TextEditingController pointsController;
  final TextEditingController timerController;
  final List<TextEditingController> optionControllers;

  bool get usesOptions =>
      type == 'Multiple Choice' || type == 'Checkbox' || type == 'True/False';

  void addOption() => optionControllers.add(TextEditingController());

  void removeOption(int index) {
    final controller = optionControllers.removeAt(index);
    controller.dispose();
  }

  void dispose() {
    questionController.dispose();
    pointsController.dispose();
    timerController.dispose();
    for (final option in optionControllers) {
      option.dispose();
    }
  }
}

class _ImageAttachment {
  _ImageAttachment({required this.name, required this.bytes});

  final String name;
  final Uint8List? bytes;
}
