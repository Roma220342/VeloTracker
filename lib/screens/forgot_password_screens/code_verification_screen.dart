import 'package:flutter/material.dart';
import 'package:velotracker/screens/forgot_password_screens/reset_password_screen.dart';
import 'package:velotracker/services/auth_service.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

class CodeVerificationScreen extends StatefulWidget {
  final String email; // Приймаємо email

  const CodeVerificationScreen({super.key, required this.email});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _pinController = TextEditingController(); // Контролер для коду
  
  Timer? _timer;
  int _start = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  // --- ЛОГІКА ПЕРЕВІРКИ КОДУ ---
  Future<void> _verifyCode() async {
    final code = _pinController.text.trim();
    if (code.length != 4) return;

    setState(() => _isLoading = true);

    // Викликаємо сервіс
    final success = await _authService.verifyResetCode(widget.email, code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Успіх -> Йдемо міняти пароль
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            code: code, // Передаємо код далі як "токен" для зміни
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid code. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // --- ПОВТОРНА ВІДПРАВКА ---
  Future<void> _resendCode() async {
    setState(() {
      _start = 60; // Скидаємо таймер
    });
    startTimer();
    
    await _authService.sendPasswordResetCode(widget.email);
    
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code resent to your email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    final defaultPinTheme = PinTheme(
      width: 72,
      height: 72,
      textStyle: theme.textTheme.headlineMedium,
      decoration: BoxDecoration(
        color: onSurfaceColor,
        borderRadius: BorderRadius.circular(15),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(leading: const BackButton()),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Check Your Inbox!',
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'We sent a code to ${widget.email}. Enter it below.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 44),

                Pinput(
                  length: 4,
                  controller: _pinController, // Підключили контролер
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: onSurfaceActiveColor, 
                    ),
                  ),
                  onCompleted: (pin) {
                    _verifyCode(); // Автоматична перевірка
                  },
                ),
                
                const SizedBox(height: 16),

                TextButton(
                    onPressed: _start == 0 ? _resendCode : null, // Активно тільки коли таймер 0
                    child: Row(
                         mainAxisSize: MainAxisSize.min, 
                         children: [
                           Text(
                             'Didn’t see it? ',
                             style: theme.textTheme.bodyLarge?.copyWith(
                               color: textSecondaryColor, 
                             ),
                           ),
                           Text(
                             _start == 0 ? 'Resend Code' : 'Resend in $_start s',
                             style: theme.textTheme.bodyLarge?.copyWith(
                               color: _start == 0 ? Colors.blue : textSecondaryColor,
                            ),
                          ),
                        ],
                    ),
                  ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Verify and Ride'),
                  ),
                ),
                SizedBox(height: screenHeight * 0.037),
              ],
            ),
          ),
        ),
      ),
    );
  }
}