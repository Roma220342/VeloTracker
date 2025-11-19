import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart'; 
import 'package:flutter_svg/flutter_svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  
  bool _isPasswordObscured = true; 

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Hey,\ngood to see you again!',
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Let\'s get you back into your account.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 44),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter your email',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const TextField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: [AutofillHints.email],
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter your password',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
              
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                     
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                    obscureText: _isPasswordObscured,
                  ),
                  const SizedBox(height: 16),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: textTertiaryColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('or', style: theme.textTheme.bodyMedium?.copyWith(
                          color: textSecondaryColor,
                        )),
                      ),
                      const Expanded(child: Divider(color: textTertiaryColor)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        side: const BorderSide(color: textTertiaryColor),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text('Continue with Google'),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset(
                              'assets/icons/Google_logo.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Sign up',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.037),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}