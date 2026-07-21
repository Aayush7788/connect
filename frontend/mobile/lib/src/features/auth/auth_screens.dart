import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final route = await ref.read(authControllerProvider.notifier).bootstrap();
    if (!mounted) {
      return;
    }
    context.go(route.path);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConnectLogoMark(size: 72),
              SizedBox(height: 18),
              Text(
                'Connect',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: connectInk,
                ),
              ),
              SizedBox(height: 8),
              Text('Find trusted textile work faster'),
              SizedBox(height: 28),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _nameError;
  String? _mobileError;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Please enter the name'
          : null;
      _mobileError = _mobileController.text.trim().isEmpty
          ? 'Please enter the mobile number'
          : null;
    });
    if (_nameError != null || _mobileError != null) {
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .requestOtp(
            name: _nameController.text,
            mobile: _mobileController.text,
          );
      if (mounted) {
        context.go(AppRoute.otp.path);
      }
    } catch (_) {
      if (mounted) {
        _showErrorSnackBar(
          context,
          ref.read(authControllerProvider).errorMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ConnectLogoMark(),
          const SizedBox(height: 28),
          Text(
            'Create account',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Enter your details to continue'),
          const SizedBox(height: 28),
          _LabeledTextField(
            label: 'Name',
            controller: _nameController,
            textInputAction: TextInputAction.next,
            placeholder: 'Enter your name',
            errorText: _nameError,
          ),
          const SizedBox(height: 18),
          _LabeledTextField(
            label: 'Mobile number',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            placeholder: 'Enter mobile number',
            errorText: _mobileError,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
            ],
          ),
          const SizedBox(height: 48),
          PrimaryActionButton(
            label: 'Continue',
            isLoading: state.isLoading,
            onPressed: _continue,
          ),
        ],
      ),
    );
  }
}

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6 || ref.read(authControllerProvider).isLoading) {
      return;
    }
    try {
      final route = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(otp);
      if (mounted) {
        context.go(route.path);
      }
    } catch (_) {
      if (mounted) {
        _showErrorSnackBar(context, 'Incorrect OTP');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return ScreenFrame(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoute.createAccount.path),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter OTP', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Code sent to ${state.pendingMobile}'),
          const SizedBox(height: 28),
          _OtpBoxesField(
            controller: _otpController,
            errorText: state.errorMessage == 'Incorrect OTP'
                ? 'Incorrect OTP'
                : null,
            onSubmitted: _verify,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                          .read(authControllerProvider.notifier)
                          .requestOtp(
                            name: state.pendingName,
                            mobile: state.pendingMobile,
                          ),
                child: const Text('Resend OTP'),
              ),
              const Spacer(),
              TextButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.go(AppRoute.createAccount.path),
                child: const Text('Change mobile number'),
              ),
            ],
          ),
          const SizedBox(height: 48),
          PrimaryActionButton(
            label: 'Verify',
            isLoading: state.isLoading,
            onPressed: _verify,
          ),
        ],
      ),
    );
  }
}

class SelectRoleScreen extends ConsumerWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(authControllerProvider.notifier);
    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your role',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Choose the profile you want to create'),
          const SizedBox(height: 24),
          _RoleCard(
            icon: Icons.factory_outlined,
            title: 'Manufacturer / Business',
            subtitle: 'I make or sell textile products',
            onTap: () {
              controller.selectRole('business');
              context.go(AppRoute.confirmRole.path);
            },
          ),
          const SizedBox(height: 14),
          _RoleCard(
            icon: Icons.handyman_outlined,
            title: 'Job Worker / Value Adder',
            subtitle: 'I do textile work for others',
            onTap: () {
              controller.selectRole('job_worker');
              context.go(AppRoute.confirmRole.path);
            },
          ),
          const SizedBox(height: 14),
          _RoleCard(
            icon: Icons.person_search_outlined,
            title: 'Skilled Worker / Karigar',
            subtitle: 'I am an individual skilled worker',
            onTap: () {
              controller.selectRole('skilled_worker');
              context.go(AppRoute.confirmRole.path);
            },
          ),
        ],
      ),
    );
  }
}

class RoleConfirmationScreen extends ConsumerWidget {
  const RoleConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final roleLabel = _roleLabel(state.selectedRole);
    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ConnectLogoMark(),
          const SizedBox(height: 28),
          Text(
            'Confirm role',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You selected'),
                const SizedBox(height: 8),
                Text(roleLabel, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'After you continue, this role will be saved with your profile.',
          ),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: state.isLoading
                ? null
                : () => context.go(AppRoute.selectRole.path),
            child: const Text('Change role'),
          ),
          const SizedBox(height: 12),
          PrimaryActionButton(
            label: 'Continue',
            isLoading: state.isLoading,
            onPressed: () async {
              try {
                final route = await ref
                    .read(authControllerProvider.notifier)
                    .confirmRole();
                if (context.mounted) {
                  context.go(route.path);
                }
              } catch (_) {
                if (context.mounted) {
                  _showErrorSnackBar(
                    context,
                    ref.read(authControllerProvider).errorMessage,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class AccountBlockedScreen extends ConsumerWidget {
  const AccountBlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account blocked',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          const Text('Please contact support to continue.'),
          const SizedBox(height: 48),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent_outlined),
            label: const Text('Contact support'),
          ),
          const SizedBox(height: 12),
          PrimaryActionButton(
            label: 'Logout',
            isLoading: state.isLoading,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoute.createAccount.path);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
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
            width: 48,
            height: 48,
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

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class _OtpBoxesField extends StatefulWidget {
  const _OtpBoxesField({
    required this.controller,
    required this.onSubmitted,
    this.errorText,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String? errorText;

  @override
  State<_OtpBoxesField> createState() => _OtpBoxesFieldState();
}

class _OtpBoxesFieldState extends State<_OtpBoxesField> {
  final _focusNode = FocusNode();
  String? _lastAutoSubmittedOtp;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final otp = widget.controller.text;
    setState(() {});
    if (otp.length < 6) {
      _lastAutoSubmittedOtp = null;
      return;
    }
    if (otp.length != 6 || otp == _lastAutoSubmittedOtp) {
      return;
    }
    _lastAutoSubmittedOtp = otp;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.text == otp) {
        widget.onSubmitted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text;
    final hasError = widget.errorText != null;
    final borderColor = hasError ? const Color(0xFFB91C1C) : connectLine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _focusNode.requestFocus,
          child: Stack(
            children: [
              Row(
                children: List.generate(6, (index) {
                  final digit = index < value.length ? value[index] : '';
                  return Expanded(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: index == 5 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        digit,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.01,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    maxLength: 6,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onSubmitted: (_) => widget.onSubmitted(),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
          ),
        ],
      ],
    );
  }
}

String _roleLabel(String? role) {
  return switch (role) {
    'business' => 'Manufacturer / Business',
    'job_worker' => 'Job Worker / Value Adder',
    'skilled_worker' => 'Skilled Worker / Karigar',
    _ => 'Selected role',
  };
}

void _showErrorSnackBar(BuildContext context, String? message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message ?? 'Something went wrong. Please retry.')),
  );
}
