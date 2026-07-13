import 'package:connect_app/src/features/engagement/engagement_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> shareProfile(
  BuildContext context,
  WidgetRef ref,
  String profileId,
) async {
  var text = 'View this textile profile on Connect';
  try {
    final result = await ref
        .read(engagementRepositoryProvider)
        .shareProfile(profileId);
    text = result.shareText;
  } catch (_) {
    text = '$text: https://connect.example/profiles/$profileId';
  }
  try {
    await SharePlus.instance.share(ShareParams(text: text));
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open sharing')));
    }
  }
}

Future<void> reportProfile(
  BuildContext context,
  WidgetRef ref,
  String profileId,
) async {
  final reason = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _ReportReasonSheet(),
  );
  if (reason == null || !context.mounted) {
    return;
  }
  try {
    await ref
        .read(engagementRepositoryProvider)
        .reportProfile(profileId, reason);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted')));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to submit report, please retry')),
      );
    }
  }
}

Future<void> logThenLaunchContact({
  required BuildContext context,
  required WidgetRef ref,
  required String profileId,
  required String actionType,
  required Uri uri,
  String? sourceType,
  String? sourceId,
}) async {
  try {
    await ref
        .read(engagementRepositoryProvider)
        .logContact(
          profileId: profileId,
          actionType: actionType,
          sourceType: sourceType,
          sourceId: sourceId,
        );
  } catch (_) {}
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open this action')));
  }
}

class _ReportReasonSheet extends StatefulWidget {
  const _ReportReasonSheet();

  @override
  State<_ReportReasonSheet> createState() => _ReportReasonSheetState();
}

class _ReportReasonSheetState extends State<_ReportReasonSheet> {
  String? selectedReason;

  static const reasons = <(String, String)>[
    ('wrong_contact', 'Wrong contact'),
    ('wrong_category', 'Wrong category'),
    ('inappropriate_photo', 'Inappropriate photo'),
    ('wrong_details', 'Wrong details'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Report profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            for (final reason in reasons)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(reason.$2),
                trailing: Icon(
                  selectedReason == reason.$1
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                onTap: () => setState(() => selectedReason = reason.$1),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: selectedReason == null
                  ? null
                  : () => Navigator.pop(context, selectedReason),
              child: const Text('Submit report'),
            ),
          ],
        ),
      ),
    );
  }
}
