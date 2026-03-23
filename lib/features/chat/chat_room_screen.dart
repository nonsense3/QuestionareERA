import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final List<String> _messages = <String>[
    'Moderator: Welcome to Questioare Arena chat.',
    'Player_07: Anyone joining the weekly challenge?',
    'Company_Admin: Invite code posted in community tab.',
  ];

  /// WhatsApp-style: tap smiley next to the field to show / hide the picker.
  bool _emojiPickerOpen = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Neo-brutalist colors; category strip is at the **top** of the picker, then grid, then search.
  Config _emojiConfig(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Colors.white : Colors.black;
    final muted = scheme.onSurface.withValues(alpha: 0.55);

    return Config(
      height: 268,
      checkPlatformCompatibility: false,
      // Category icons on top (like WhatsApp), then grid, then search/backspace.
      viewOrderConfig: const ViewOrderConfig(
        top: EmojiPickerItem.categoryBar,
        middle: EmojiPickerItem.emojiView,
        bottom: EmojiPickerItem.searchBar,
      ),
      categoryViewConfig: CategoryViewConfig(
        initCategory: Category.SMILEYS,
        tabBarHeight: 44,
        backgroundColor: scheme.surfaceContainerHigh,
        indicatorColor: scheme.primary,
        iconColor: muted,
        iconColorSelected: scheme.primary,
        backspaceColor: scheme.primary,
        dividerColor: border.withValues(alpha: 0.35),
      ),
      emojiViewConfig: EmojiViewConfig(
        columns: 8,
        emojiSizeMax: 26,
        backgroundColor: scheme.surfaceContainerHighest,
        verticalSpacing: 2,
        horizontalSpacing: 2,
        gridPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        buttonMode: ButtonMode.MATERIAL,
        noRecents: Text(
          'No recents yet',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      bottomActionBarConfig: BottomActionBarConfig(
        enabled: true,
        showBackspaceButton: true,
        showSearchViewButton: true,
        backgroundColor: scheme.surfaceContainerHigh,
        buttonColor: scheme.primary,
        buttonIconColor: Colors.black,
      ),
      searchViewConfig: SearchViewConfig(
        backgroundColor: scheme.surfaceContainerHighest,
        hintText: 'Search emoji',
        hintTextStyle: TextStyle(color: muted, fontWeight: FontWeight.w600),
        inputTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        buttonIconColor: muted,
      ),
      skinToneConfig: SkinToneConfig(
        enabled: true,
        dialogBackgroundColor: scheme.surface,
        indicatorColor: scheme.outline,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;
    return InputDecoration(
      hintText: 'Type message...',
      hintStyle: TextStyle(
        color: scheme.onSurface.withValues(alpha: 0.45),
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;

    return ListView(
      children: [
        NeoCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.circle, size: 14),
            title: const Text('Global Lobby'),
            subtitle: const Text('Live chat enabled - 124 online'),
            trailing: const Icon(Icons.chat_bubble_outline),
          ),
        ),
        NeoCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.circle, size: 14),
            title: const Text('Company War Room'),
            subtitle: const Text('Private room + quiz voice sync hooks'),
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.qr_code),
            ),
          ),
        ),
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live Feed',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 10),
              for (final msg in _messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(msg),
                ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: _inputDecoration(context),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message: _emojiPickerOpen ? 'Hide emoji keyboard' : 'Emoji',
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _emojiPickerOpen = !_emojiPickerOpen),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          border: Border.all(color: borderColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? borderColor
                                  : borderColor.withValues(alpha: 0.32),
                              offset: isDark
                                  ? const Offset(3, 3)
                                  : const Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _emojiPickerOpen
                              ? Icons.keyboard_alt_outlined
                              : Icons.emoji_emotions_outlined,
                          color: Colors.black,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? borderColor
                              : borderColor.withValues(alpha: 0.3),
                          offset:
                              isDark ? const Offset(5, 5) : const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: EmojiPicker(
                      textEditingController: _messageController,
                      config: _emojiConfig(context),
                    ),
                  ),
                ),
                crossFadeState: _emojiPickerOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
                sizeCurve: Curves.easeOutCubic,
              ),
              const SizedBox(height: 10),
              NeoButton(
                label: 'Send Message',
                onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    _messages.add('You: $text');
                    _messageController.clear();
                  });
                },
                color: scheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
