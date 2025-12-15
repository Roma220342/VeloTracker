import 'package:flutter/material.dart';
import 'package:velotracker/screens/forgot_password_screens/code_verification_screen.dart';
import 'package:velotracker/services/auth_service.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService(); 
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Логіка відправки
  Future<void> _sendCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Викликаємо метод сервісу
    final success = await _authService.sendPasswordResetCode(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // 3. Якщо ОК -> Переходимо далі і передаємо email
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodeVerificationScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to send code. User might not exist.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

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
                  child: Text('Your registered email', style: theme.textTheme.bodyLarge),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'example@gmail.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
    
                const Spacer(), 
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendCode, // Підключили функцію
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Send My Code'),
                  ),
                ),
                SizedBox(height: isKeyboardOpen ? 0 : screenHeight * 0.037),
              ],
            ),
          ),
        ),
      ),
    );
  }
}