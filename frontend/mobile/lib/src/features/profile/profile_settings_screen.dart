import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/features/engagement/engagement_controller.dart';
import 'package:connect_app/src/features/engagement/engagement_repository.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  bool _isUpdatingVisibility = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).load();
      ref.read(engagementControllerProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final profile = state.profile?.profile;
    final hidden = profile?.visibilityStatus == 'hidden_by_user';
    final engagement = ref.watch(engagementControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AppCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Push notifications'),
                subtitle: const Text(
                  'In-app notifications remain available when this is off.',
                ),
                value: engagement.pushNotificationsEnabled,
                onChanged: engagement.isSaving
                    ? null
                    : (value) async {
                        final changed = await ref
                            .read(engagementControllerProvider.notifier)
                            .setPushNotifications(value);
                        if (!changed && context.mounted) {
                          _showError(context);
                        }
                      },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Profile visibility',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AppCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hide from search'),
                subtitle: const Text(
                  'Your profile will not appear in search or recommendations.',
                ),
                value: hidden,
                onChanged:
                    profile == null || state.isSaving || _isUpdatingVisibility
                    ? null
                    : (value) async {
                        setState(() => _isUpdatingVisibility = true);
                        try {
                          await ref
                              .read(engagementRepositoryProvider)
                              .updateSettings(hiddenFromSearch: value);
                          await ref
                              .read(profileControllerProvider.notifier)
                              .load(force: true);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to update profile visibility',
                                ),
                              ),
                            );
                          }
                        }
                        if (mounted) {
                          setState(() => _isUpdatingVisibility = false);
                        }
                      },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact support',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _supportWhatsApp.isEmpty
                        ? null
                        : () => _openSupport(
                            context,
                            Uri.parse('https://wa.me/$_supportWhatsApp'),
                          ),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _supportPhone.isEmpty
                        ? null
                        : () => _openSupport(
                            context,
                            Uri(scheme: 'tel', path: _supportPhone),
                          ),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: ref.watch(authControllerProvider).isLoading
                  ? null
                  : () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(AppRoute.createAccount.path);
                      }
                    },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(engagementControllerProvider).errorMessage ??
              'Unable to update notification settings',
        ),
      ),
    );
  }

  static Future<void> _openSupport(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open support')));
    }
  }
}

const _supportPhone = String.fromEnvironment(
  'SUPPORT_PHONE_NUMBER',
  defaultValue: '',
);
const _supportWhatsApp = String.fromEnvironment(
  'SUPPORT_WHATSAPP_NUMBER',
  defaultValue: '',
);
