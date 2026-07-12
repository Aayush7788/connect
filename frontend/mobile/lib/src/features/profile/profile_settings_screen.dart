import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final profile = state.profile?.profile;
    final hidden = profile?.visibilityStatus == 'hidden_by_user';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                onChanged: profile == null || state.isSaving
                    ? null
                    : (value) async {
                        final changed = await ref
                            .read(profileControllerProvider.notifier)
                            .setHidden(value);
                        if (!context.mounted || changed) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ref
                                      .read(profileControllerProvider)
                                      .errorMessage ??
                                  'Unable to update profile visibility',
                            ),
                          ),
                        );
                      },
              ),
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
}
