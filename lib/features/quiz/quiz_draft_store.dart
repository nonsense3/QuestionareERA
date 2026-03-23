import 'package:flutter/foundation.dart';

class QuizDraftData {
  QuizDraftData({
    required this.id,
    required this.ownerAccessKey,
    required this.ownerLabel,
    required this.title,
    required this.description,
    required this.theme,
    required this.shuffleQuestions,
    required this.publishInstantly,
    required this.savedAt,
    required this.questions,
  });

  final String id;
  final String ownerAccessKey;
  final String ownerLabel;
  final String title;
  final String description;
  final String theme;
  final bool shuffleQuestions;
  final bool publishInstantly;
  final DateTime savedAt;
  final List<QuizQuestionData> questions;
}

class QuizQuestionData {
  QuizQuestionData({
    required this.text,
    required this.type,
    required this.options,
    required this.points,
    required this.required,
    required this.timerEnabled,
    this.timerSeconds,
  });

  final String text;
  final String type;
  final List<String> options;
  final int points;
  final bool required;
  final bool timerEnabled;
  final int? timerSeconds;
}

class QuizDraftStore {
  static final List<QuizDraftData> _drafts = <QuizDraftData>[];
  static final Map<String, QuizDraftData> _sharedByToken =
      <String, QuizDraftData>{};

  /// Bumps when drafts change so UI (e.g. bottom nav badge) can refresh.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void _bumpRevision() {
    revision.value++;
  }

  static List<QuizDraftData> allForOwner(String ownerAccessKey) => _drafts
      .where((d) => d.ownerAccessKey == ownerAccessKey)
      .toList()
      .reversed
      .toList();

  static void upsert(QuizDraftData draft) {
    final index = _drafts.indexWhere((d) => d.id == draft.id);
    if (index == -1) {
      _drafts.add(draft);
    } else {
      _drafts[index] = draft;
    }
    _bumpRevision();
  }

  static String submitAndCreateShareLink(QuizDraftData draft) {
    upsert(draft);
    final token = _tokenFromDraftId(draft.id);
    _sharedByToken[token] = draft;
    return 'https://questioare.app/quiz/$token';
  }

  static QuizDraftData? fromShareLink(String linkOrToken) {
    final token = _extractToken(linkOrToken);
    if (token == null) return null;
    return _sharedByToken[token];
  }

  static String? _extractToken(String linkOrToken) {
    final raw = linkOrToken.trim();
    if (raw.isEmpty) return null;
    if (!raw.contains('/')) return raw;
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.pathSegments.isEmpty) return null;
    return uri.pathSegments.last;
  }

  static String _tokenFromDraftId(String draftId) {
    final hash = draftId.hashCode.abs().toRadixString(36);
    return 'qz$hash';
  }
}
