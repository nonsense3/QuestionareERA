import 'package:flutter/material.dart';

import '../../shared/widgets/neo_card.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        NeoCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Weekly Reward Pool'),
            subtitle: Text('Complete weekly quiz streak to unlock chest cards'),
            trailing: Icon(Icons.card_giftcard),
          ),
        ),
        NeoCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Role: Quiz Rookie'),
            subtitle: Text('Tier 1 - 0 to 500 XP'),
            trailing: Icon(Icons.emoji_events),
          ),
        ),
        NeoCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Role: Arena Master'),
            subtitle: Text('Tier 2 - 500 to 3000 XP'),
            trailing: Icon(Icons.workspace_premium),
          ),
        ),
        NeoCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Role: Legend Board'),
            subtitle: Text('Tier 3 - 3000+ XP + weekly bonus'),
            trailing: Icon(Icons.whatshot),
          ),
        ),
        NeoCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Role: Community Titan'),
            subtitle: Text('Tier 4 - Server host perks + boost multipliers'),
            trailing: Icon(Icons.military_tech),
          ),
        ),
        NeoCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Card Perks'),
            subtitle: Text('Quick Hint Card, Double XP Card, Revive Card'),
            trailing: Icon(Icons.style),
          ),
        ),
      ],
    );
  }
}
