import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neo_card.dart';
import '../../shared/widgets/neo_loader.dart';
import '../auth/auth_service.dart';
import '../chat/chat_room_screen.dart';
import '../company/company_hub_screen.dart';
import '../profile/profile_screen.dart';
import '../quiz/created_quizzes_screen.dart';
import '../quiz/quiz_draft_store.dart';
import '../quiz/quiz_room_screen.dart';
import '../rewards/rewards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authService,
    required this.userType,
    required this.displayName,
    required this.username,
    this.onGuestExit,
  });
  final AuthService? authService;
  final UserType userType;
  final String displayName;
  final String username;

  /// When [authService] is null (offline guest), called from the logout action.
  final VoidCallback? onGuestExit;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  bool _tabLoading = false;
  PerformanceMode _mode = PerformanceMode.low;
  @override
  Widget build(BuildContext context) {
    final currentAccessKey = widget.userType == UserType.company
        ? 'company:${widget.displayName.trim().toLowerCase()}'
        : 'user:${widget.username.trim().toLowerCase()}';
    final currentOwnerLabel = widget.userType == UserType.company
        ? widget.displayName
        : '@${widget.username}';

    return ValueListenableBuilder<int>(
      valueListenable: QuizDraftStore.revision,
      builder: (context, revision, _) {
        final createdCount =
            QuizDraftStore.allForOwner(currentAccessKey).length;

        final tabs = [
          QuizRoomScreen(
            mode: _mode,
            currentAccessKey: currentAccessKey,
            currentOwnerLabel: currentOwnerLabel,
          ),
          CreatedQuizzesScreen(
            currentAccessKey: currentAccessKey,
            currentOwnerLabel: currentOwnerLabel,
          ),
          const ChatRoomScreen(),
          CompanyHubScreen(userType: widget.userType),
          const RewardsScreen(),
          ProfileScreen(
            userType: widget.userType,
            displayName: widget.displayName,
            username: widget.username,
            authService: widget.authService,
          ),
        ];

        return Scaffold(
      appBar: AppBar(
        title: Text('Questioare ERA - ${widget.userType.name.toUpperCase()}'),
        actions: [
          PopupMenuButton<PerformanceMode>(
            icon: const Icon(Icons.speed),
            initialValue: _mode,
            onSelected: (value) => setState(() => _mode = value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: PerformanceMode.low,
                child: Text('LOW (default, low-end devices)'),
              ),
              PopupMenuItem(
                value: PerformanceMode.medium,
                child: Text('MEDIUM (slightly high-end)'),
              ),
            ],
          ),
          IconButton(
            onPressed: widget.authService != null
                ? widget.authService!.signOut
                : widget.onGuestExit,
            icon: const Icon(Icons.logout),
            tooltip: widget.authService != null ? 'Sign out' : 'Leave guest mode',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            NeoCard(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.userType == UserType.individual
                    ? 'Welcome ${widget.displayName} (@${widget.username}). Daily + Weekly quiz cards and live rooms are ready.'
                    : 'Welcome ${widget.displayName}. Daily + Weekly quiz cards and live rooms are ready.',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: _duration,
                child: _tabLoading
                    ? const Center(
                        child: NeoLoader(label: 'Loading section', size: 42),
                      )
                    : tabs[_index],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _changeTab,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.quiz), label: 'Quiz'),
          NavigationDestination(
            icon: _myQuizzesNavIcon(
              Icons.library_books_outlined,
              createdCount,
            ),
            selectedIcon: _myQuizzesNavIcon(
              Icons.library_books,
              createdCount,
            ),
            label: 'My quizzes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Live Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups),
            label: 'Community',
          ),
          const NavigationDestination(
            icon: Icon(Icons.workspace_premium),
            label: 'Rewards',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
      },
    );
  }

  /// Badge shows how many quizzes this account has saved (in-memory store).
  Widget _myQuizzesNavIcon(IconData icon, int count) {
    if (count <= 0) return Icon(icon);
    return Badge(
      label: Text('$count'),
      child: Icon(icon),
    );
  }

  Duration get _duration => _mode == PerformanceMode.low
      ? const Duration(milliseconds: 140)
      : const Duration(milliseconds: 260);
  Future<void> _changeTab(int nextIndex) async {
    if (_index == nextIndex || _tabLoading) return;
    setState(() => _tabLoading = true);
    await Future<void>.delayed(
      _mode == PerformanceMode.low
          ? const Duration(milliseconds: 250)
          : const Duration(milliseconds: 420),
    );
    if (!mounted) return;
    setState(() {
      _index = nextIndex;
      _tabLoading = false;
    });
  }
}
