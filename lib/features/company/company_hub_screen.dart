import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neo_button.dart';
import '../../shared/widgets/neo_card.dart';

class CompanyHubScreen extends StatelessWidget {
  const CompanyHubScreen({super.key, required this.userType});

  final UserType userType;

  @override
  Widget build(BuildContext context) {
    final isCompany = userType == UserType.company;
    return ListView(
      children: [
        NeoCard(
          child: Text(
            isCompany
                ? 'Invite users via QR, shareable link, or unique code.'
                : 'Join any company using private code, QR, or community page.',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ),
        NeoCard(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCompany ? 'Create Private Server' : 'Join Private Server',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Enter unique server code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              NeoButton(
                label: isCompany ? 'Generate Invite' : 'Join with Code',
                onPressed: () {},
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
