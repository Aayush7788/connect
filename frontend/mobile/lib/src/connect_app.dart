import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/features/auth/auth_screens.dart';
import 'package:connect_app/src/features/home/home_screen.dart';
import 'package:connect_app/src/features/profile/profile_form_screen.dart';
import 'package:connect_app/src/features/profile/profile_settings_screen.dart';
import 'package:connect_app/src/features/work_cards/work_card_form_screen.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConnectApp extends StatelessWidget {
  const ConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Connect',
      debugShowCheckedModeBanner: false,
      theme: buildConnectTheme(),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: AppRoute.splash.path,
  routes: [
    GoRoute(
      path: AppRoute.splash.path,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoute.createAccount.path,
      builder: (context, state) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: AppRoute.otp.path,
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: AppRoute.selectRole.path,
      builder: (context, state) => const SelectRoleScreen(),
    ),
    GoRoute(
      path: AppRoute.confirmRole.path,
      builder: (context, state) => const RoleConfirmationScreen(),
    ),
    GoRoute(
      path: AppRoute.blocked.path,
      builder: (context, state) => const AccountBlockedScreen(),
    ),
    GoRoute(
      path: AppRoute.home.path,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoute.completeProfile.path,
      builder: (context, state) => const ProfileFormScreen(),
    ),
    GoRoute(
      path: AppRoute.settings.path,
      builder: (context, state) => const ProfileSettingsScreen(),
    ),
    GoRoute(
      path: AppRoute.addWorkCard.path,
      builder: (context, state) => const WorkCardFormScreen(),
    ),
    GoRoute(
      path: '/work-cards/:workCardId/edit',
      builder: (context, state) =>
          WorkCardFormScreen(workCardId: state.pathParameters['workCardId']),
    ),
  ],
);
