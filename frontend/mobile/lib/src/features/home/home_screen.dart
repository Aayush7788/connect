import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/features/engagement/saved_screen.dart';
import 'package:connect_app/src/features/profile/profile_dashboard.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _jobWorkerWorkListSelected = true;
  bool _businessWorkNeededSelected = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final role = state.me?.profile?.role;
    final showJobWorkerAdd =
        _selectedIndex == 3 &&
        role == 'job_worker' &&
        _jobWorkerWorkListSelected;
    final showBusinessAdd =
        _selectedIndex == 3 &&
        role == 'business' &&
        _businessWorkNeededSelected;
    return ScreenFrame(
      floatingActionButton: showJobWorkerAdd || showBusinessAdd
          ? FloatingActionButton(
              tooltip: showBusinessAdd ? 'Add work needed' : 'Add work',
              onPressed: () => context.push(
                showBusinessAdd
                    ? AppRoute.addWorkNeededPost.path
                    : AppRoute.addWorkCard.path,
              ),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          if (value == 1) {
            context.push(AppRoute.search.path);
            return;
          }
          setState(() => _selectedIndex = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_outlined),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'My Profile',
          ),
        ],
      ),
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(
            displayName: state.displayName,
            profileComplete: state.me?.profile?.completionScore == 100,
            onFind: (target) => context.push('/search?target=$target'),
            onPopularSearch: (query) => context.push(
              '/search?target=job_worker&q=${Uri.encodeQueryComponent(query)}',
            ),
          ),
          const _PlaceholderTab(
            icon: Icons.search_outlined,
            title: 'Search',
            message: 'Search for profile/work',
          ),
          const SavedScreen(),
          MyProfileDashboard(
            onWorkListSelectionChanged: (selected) {
              if (_jobWorkerWorkListSelected != selected) {
                setState(() => _jobWorkerWorkListSelected = selected);
              }
            },
            onWorkNeededSelectionChanged: (selected) {
              if (_businessWorkNeededSelected != selected) {
                setState(() => _businessWorkNeededSelected = selected);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.displayName,
    required this.profileComplete,
    required this.onFind,
    required this.onPopularSearch,
  });

  final String displayName;
  final bool profileComplete;
  final ValueChanged<String> onFind;
  final ValueChanged<String> onPopularSearch;

  @override
  Widget build(BuildContext context) {
    final greetingName = displayName.isEmpty ? 'there' : displayName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Connect', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => context.push(AppRoute.notifications.path),
              icon: const Icon(Icons.notifications_none_outlined),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Hi, $greetingName',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Who are you looking for?',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 20),
        _FindCard(
          icon: Icons.storefront_outlined,
          title: 'Find Manufacturers, Traders, Wholesalers',
          subtitle: 'Find people who make or sell textile products',
          onTap: () => onFind('business'),
        ),
        const SizedBox(height: 12),
        _FindCard(
          icon: Icons.handyman_outlined,
          title: 'Find Job Worker, Value Adder',
          subtitle: 'Find flat hemming, embroidery, print and more',
          onTap: () => onFind('job_worker'),
        ),
        const SizedBox(height: 12),
        _FindCard(
          icon: Icons.person_search_outlined,
          title: 'Find Skilled Worker, Karigar',
          subtitle: 'Find skilled people for workshop work',
          onTap: () => onFind('skilled_worker'),
        ),
        const SizedBox(height: 22),
        if (!profileComplete) ...[
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.task_alt_outlined, color: connectAmber),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete your profile',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 4),
                      Text('Add your details and photos to get business'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoute.completeProfile.path),
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        Text(
          'Popular searches',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SearchChip(
              label: 'Flat hemming',
              onPressed: () => onPopularSearch('Flat hemming'),
            ),
            _SearchChip(
              label: 'Digital print',
              onPressed: () => onPopularSearch('Digital print'),
            ),
            _SearchChip(
              label: 'Embroidery',
              onPressed: () => onPopularSearch('Embroidery'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FindCard extends StatelessWidget {
  const _FindCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: connectTeal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      side: const BorderSide(color: connectLine),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(icon, size: 42, color: connectTeal),
              const SizedBox(height: 12),
              Text(message, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
