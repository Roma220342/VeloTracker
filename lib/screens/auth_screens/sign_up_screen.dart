import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velotracker/main.dart';
import 'package:velotracker/screens/auth_screens/sign_in_screen.dart';
import 'package:velotracker/services/auth_service.dart';
import 'package:velotracker/theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  final bool isGuestConversion;
  
  const SignUpScreen({
    super.key,
    this.isGuestConversion = false,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ЛОГІКА ДЛЯ ГОЛОВНОЇ КНОПКИ (Email)
  Future<void> _handleMainAction() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Логіка залишається різною!
    if (widget.isGuestConversion) {
      // А) ГІСТЬ: Зберігаємо (оновлюємо) поточний акаунт
      final error = await _authService.convertGuest(name, email, password);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } else {
      // Б) НОВАЧОК: Створюємо новий акаунт
      final success = await _authService.register(name, email, password);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Registration failed. Email might be taken.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  // ЛОГІКА ДЛЯ КНОПКИ GOOGLE 
  Future<void> _handleGoogleAction() async {
    setState(() => _isLoading = true);
    
    // Логіка залишається різною!
    if (widget.isGuestConversion) {
      // А) ГІСТЬ: Прив'язуємо Google
      final error = await _authService.linkGoogle();
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google account linked successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } else {
      // Б) НОВАЧОК: Входимо через Google
      final success = await _authService.continueWithGoogle();
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign In failed')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(leading: const BackButton()),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Welcome aboard!', // Статичний текст
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Let\'s start your new journey today', // Статичний текст
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 44),

                  // --- ПОЛЯ ВВОДУ ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Enter your name', style: theme.textTheme.bodyLarge),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController, 
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Enter your email', style: theme.textTheme.bodyLarge),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController, 
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Create a password', style: theme.textTheme.bodyLarge),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController, 
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                    obscureText: _isPasswordObscured,
                  ),
          
                  const SizedBox(height: 32), 
                  
                  // --- ГОЛОВНА КНОПКА (Sign Up) ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleMainAction, 
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign Up'), // Статичний текст
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // --- РОЗДІЛЮВАЧ ---
                  Row(
                    children: [
                      const Expanded(child: Divider(color: textTertiaryColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('or', style: theme.textTheme.bodyMedium?.copyWith(color: textSecondaryColor)),
                      ),
                      const Expanded(child: Divider(color: textTertiaryColor)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- КНОПКА GOOGLE ---
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleAction, 
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        side: const BorderSide(color: textTertiaryColor),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text('Continue with Google'), // Статичний текст
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

                  // --- ПОСИЛАННЯ НА ВХІД ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?', style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                             MaterialPageRoute(builder: (context) => const SignInScreen()),
                          );
                        },
                        child: Text(
                          'Sign in',
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}