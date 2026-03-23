import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';
import 'draft_quiz_screen.dart';
import 'quiz_builder_screen.dart';
import 'quiz_draft_store.dart';
import 'quiz_take_screen.dart';

class QuizRoomScreen extends StatefulWidget {
  const QuizRoomScreen({
    super.key,
    required this.mode,
    required this.currentAccessKey,
    required this.currentOwnerLabel,
  });

  final PerformanceMode mode;
  final String currentAccessKey;
  final String currentOwnerLabel;

  @override
  State<QuizRoomScreen> createState() => _QuizRoomScreenState();
}

class _QuizRoomScreenState extends State<QuizRoomScreen>
    with SingleTickerProviderStateMixin {
  static final TextEditingController _linkController = TextEditingController();

  bool _speedDialOpen = false;
  late final AnimationController _dialAnim;

  @override
  void initState() {
    super.initState();
    _dialAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _dialAnim.dispose();
    super.dispose();
  }

  void _toggleDial() {
    setState(() {
      _speedDialOpen = !_speedDialOpen;
      if (_speedDialOpen) {
        _dialAnim.forward();
      } else {
        _dialAnim.reverse();
      }
    });
  }

  void _closeDial() {
    if (!_speedDialOpen) return;
    setState(() {
      _speedDialOpen = false;
      _dialAnim.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;

    final cards = [
      _QuizCardData('Daily Quiz Blitz', '10 questions, 1 reward chest'),
      _QuizCardData('Weekly Championship', '50 questions, tier bonus XP'),
      _QuizCardData('Live Company Challenge', 'Private code + leaderboard'),
    ];
    return Stack(
      children: [
        ListView(
          key: ValueKey(widget.mode.name),
          children: [
            for (final card in cards)
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 20)),
                    const SizedBox(height: 8),
                    Text(card.subtitle),
                    const SizedBox(height: 12),
                    NeoButton(
                      label: 'Join Quiz',
                      onPressed: () {},
                      color: colors.secondary,
                    ),
                  ],
                ),
              ),
            NeoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Access with Link',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      hintText: 'Paste quiz link or token',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  NeoButton(
                    label: 'Open Shared Quiz',
                    onPressed: () => _openSharedQuiz(context),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 84),
          ],
        ),
        // Dim overlay (Google Drive–style)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_speedDialOpen,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _dialAnim,
                curve: Curves.easeOut,
              ),
              child: GestureDetector(
                onTap: _closeDial,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: _dialAnim,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: _dialAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _NeoSpeedDialPill(
                        borderColor: borderColor,
                        surfaceColor: colors.surfaceContainerHighest,
                        icon: Icons.quiz_outlined,
                        label: 'Make Quiz',
                        onTap: () {
                          _closeDial();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuizBuilderScreen(
                                currentAccessKey: widget.currentAccessKey,
                                currentOwnerLabel: widget.currentOwnerLabel,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _NeoSpeedDialPill(
                        borderColor: borderColor,
                        surfaceColor: colors.surfaceContainerHigh,
                        icon: Icons.drafts_outlined,
                        label: 'Draft Quiz',
                        onTap: () {
                          _closeDial();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DraftQuizScreen(
                                currentAccessKey: widget.currentAccessKey,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _NeoSpeedDialFab(
                borderColor: borderColor,
                backgroundColor: colors.primary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                open: _speedDialOpen,
                onPressed: _toggleDial,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openSharedQuiz(BuildContext context) {
    final value = _linkController.text.trim();
    final draft = QuizDraftStore.fromShareLink(value);
    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No shared quiz found for this link.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => draft.ownerAccessKey == widget.currentAccessKey
            ? QuizBuilderScreen(
                initialDraft: draft,
                currentAccessKey: widget.currentAccessKey,
                currentOwnerLabel: widget.currentOwnerLabel,
              )
            : QuizTakeScreen(quiz: draft),
      ),
    );
  }
}

/// Pill row: icon + label, right-aligned like Google Drive speed dial.
class _NeoSpeedDialPill extends StatelessWidget {
  const _NeoSpeedDialPill({
    required this.borderColor,
    required this.surfaceColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color borderColor;
  final Color surfaceColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(minWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: borderColor,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: borderColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.3,
                  color: borderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeoSpeedDialFab extends StatelessWidget {
  const _NeoSpeedDialFab({
    required this.borderColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.open,
    required this.onPressed,
  });

  final Color borderColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool open;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const RoundedRectangleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        customBorder: const RoundedRectangleBorder(),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: borderColor,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: Icon(
              open ? Icons.close : Icons.add,
              key: ValueKey(open),
              size: 36,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizCardData {
  const _QuizCardData(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
