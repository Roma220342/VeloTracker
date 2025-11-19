import 'package:flutter/material.dart';
// import 'package:velotracker/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget 
{
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> 
{
  
  @override
  Widget build(BuildContext context) 
  {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () 
      {
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
            // 1. SingleChildScrollView ВИДАЛЕНО
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Password playing\nhide & seek?',
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Enter your registered email, and we\'ll help you get back in.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 44),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your registered email',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 8),
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: [AutofillHints.email],
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  obscureText: false,
                ),
    
                // 2. Spacer ТЕПЕР ПРАЦЮЄ, бо Column має фіксовану висоту
                const Spacer(), 
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Логіка відправки коду
                    },
                    
                    child: const Text('Send My Code'),
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