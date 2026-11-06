import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../state/smartvax_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});
  final SmartVaxController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool get _otpSent => widget.controller.authRepository?.codeSent ?? false;
  String? _error;

  @override
  void dispose() {
    widget.controller.authRepository?.removeListener(_authChanged);
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.authRepository?.addListener(_authChanged);
  }

  void _authChanged() {
    if (mounted) setState(() {});
  }

  void _sendOtp() {
    final auth = widget.controller.authRepository;
    if (auth == null) {
      setState(() => _error = 'Firebase authentication is unavailable.');
      return;
    }
    auth.send(_mobileController.text);
  }

  void _verify() {
    widget.controller.authRepository?.verify(_otpController.text.trim());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LiquidBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandMark()),
                  const SizedBox(height: 22),
                  LiquidGlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(
                      children: [
                        Text(
                          'On-time vaccinations',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 25),
                        ),
                        const DoctorChildArt(height: 155),
                        const Text(
                          'Keep your family’s health information organized in one friendly place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _otpSent
                              ? 'Verify your number'
                              : 'Enter mobile number',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 13),
                        TextField(
                          controller: _mobileController,
                          enabled:
                              !_otpSent &&
                              !(widget.controller.authRepository?.busy ??
                                  false),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.call_rounded,
                              color: AppColors.blue,
                            ),
                            hintText: '10-digit mobile number',
                            prefixText: '+91  ',
                          ),
                        ),
                        if (_otpSent) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'Enter the six-digit code',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              letterSpacing: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: const InputDecoration(
                              hintText: '• • • • • •',
                              counterText: '',
                            ),
                            maxLength: 6,
                          ),
                        ],
                        if ((_error ??
                                widget.controller.authRepository?.error ??
                                widget.controller.accountError) !=
                            null) ...[
                          const SizedBox(height: 8),
                          Text(
                            (_error ??
                                widget.controller.authRepository?.error ??
                                widget.controller.accountError)!,
                            style: const TextStyle(
                              color: Color(0xffbb315f),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (kDebugMode &&
                            widget
                                    .controller
                                    .authRepository
                                    ?.diagnosticErrorCode !=
                                null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Verification error: ${widget.controller.authRepository!.diagnosticErrorCode}'
                              '${widget.controller.authRepository!.diagnosticErrorMessage?.isNotEmpty == true ? '\n${widget.controller.authRepository!.diagnosticErrorMessage}' : ''}',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              key: const ValueKey('phone-auth-diagnostic'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        GradientButton(
                          label:
                              (widget.controller.authRepository?.busy ?? false)
                              ? 'Please wait…'
                              : _otpSent
                              ? 'Verify and continue'
                              : 'Continue',
                          icon: _otpSent
                              ? Icons.verified_rounded
                              : Icons.arrow_forward_rounded,
                          onPressed:
                              (widget.controller.authRepository?.busy ?? false)
                              ? () {}
                              : _otpSent
                              ? _verify
                              : _sendOtp,
                        ),
                        if (_otpSent) ...[
                          TextButton(
                            onPressed:
                                (widget.controller.authRepository?.busy ??
                                    false)
                                ? null
                                : () {
                                    widget.controller.authRepository
                                        ?.changeNumber();
                                    _otpController.clear();
                                    _error = null;
                                  },
                            child: const Text('Change mobile number'),
                          ),
                          TextButton(
                            onPressed: () => widget.controller.authRepository
                                ?.send(_mobileController.text, resend: true),
                            child: const Text('Resend code (after 60 seconds)'),
                          ),
                        ],
                        if (widget.controller.accountError != null)
                          TextButton(
                            onPressed: widget.controller.retryAccount,
                            child: const Text('Retry account loading'),
                          ),
                        if (widget.controller.accountLoading)
                          const LinearProgressIndicator(),
                        const SizedBox(height: 8),
                        appNotice(
                          'Verify with the code supplied by Firebase. Configured testing numbers receive no SMS.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Sample information is not an official vaccination record.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
