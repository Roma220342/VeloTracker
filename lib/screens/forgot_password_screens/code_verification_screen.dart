import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

class CodeVerificationScreen extends StatefulWidget {
  const CodeVerificationScreen({super.key});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  Timer? _timer;
  int _start = 60;

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
    super.dispose();
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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          leading: const BackButton(),
        ),
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

                SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'We just sent a 4-digit rescue code to your inbox. Pop it in below to secure your account.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 44),

                Pinput(
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: onSurfaceActiveColor, 
                    ),
                  ),
                  onCompleted: (pin) {
                  //TODO:
                  },
                ),
                
                SizedBox(height: 16),

                TextButton(
                    onPressed: _start == 0
                        ? () {
                            // TODO: Логіка повторної відправки коду
                            setState(() {
                              _start = 60;
                            });
                            startTimer();
                          }
                        : null, 
                    
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
                             _start == 0
                                 ? 'Resend Code' 
                                 : 'Resend code in $_start' 's',
                             style: theme.textTheme.bodyLarge?.copyWith(
                               color: _start == 0
                                   ? Colors.blue 
                                   : textSecondaryColor,
                            ),
                          ),
                        ],
                    ),
                  ),

                Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO:
                    },
                    child: const Text('Verify and Ride'),
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
