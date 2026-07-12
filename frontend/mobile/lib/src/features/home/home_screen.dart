import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return ScreenFrame(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
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
          _HomeTab(displayName: state.displayName),
          const _PlaceholderTab(
            icon: Icons.search_outlined,
            title: 'Search',
            message: 'Search for profile/work',
          ),
          const _PlaceholderTab(
            icon: Icons.bookmark_border_outlined,
            title: 'Saved',
            message: 'No saved profiles',
          ),
          _MyProfileTab(displayName: state.displayName, state: state),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.displayName});

  final String displayName;

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
              onPressed: () {},
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
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _FindCard(
          icon: Icons.handyman_outlined,
          title: 'Find Job Worker, Value Adder',
          subtitle: 'Find flat hemming, embroidery, print and more',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _FindCard(
          icon: Icons.person_search_outlined,
          title: 'Find Skilled Worker, Karigar',
          subtitle: 'Find skilled people for workshop work',
          onTap: () {},
        ),
        const SizedBox(height: 22),
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
              TextButton(onPressed: () {}, child: const Text('Start')),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Popular searches',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _SearchChip(label: 'Flat hemming'),
            _SearchChip(label: 'Digital print'),
            _SearchChip(label: 'Embroidery'),
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
  const _SearchChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {},
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

class _MyProfileTab extends StatelessWidget {
  const _MyProfileTab({required this.displayName, required this.state});

  final String displayName;
  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final role = state.me?.user.role ?? state.selectedRole ?? 'Not selected';
    final completion = state.me?.profile?.completionScore ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName.isEmpty ? 'Your profile' : displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_roleLabel(role)),
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: completion / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Text('$completion% complete'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PrimaryActionButton(label: 'Complete profile', onPressed: () {}),
      ],
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'business' => 'Manufacturer / Business',
      'job_worker' => 'Job Worker / Value Adder',
      'skilled_worker' => 'Skilled Worker / Karigar',
      _ => role,
    };
  }
}
