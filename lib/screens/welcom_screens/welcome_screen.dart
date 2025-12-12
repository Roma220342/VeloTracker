import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velotracker/main.dart';
import 'package:velotracker/services/auth_service.dart';
import 'package:velotracker/screens/auth_screens/sign_in_screen.dart';
import 'package:velotracker/screens/auth_screens/sign_up_screen.dart';
 
class WelcomeScreen extends StatefulWidget { // Змінили на StatefulWidget для стану завантаження
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isGuestLoading = false;
   
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    
    return Scaffold (
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.122), 
              SvgPicture.asset(
                'assets/icons/logo_welcome_screen.svg',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'Ready to Ride?', 
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Track your rides easily.\nAll your routes and stats in one place.', 
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SignInScreen()),
                          );
                        }, 
                      child: const Text('Sign In')
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        }, 
                      child: const Text('Sign Up')
                    ),
                  ),

                  const SizedBox(height: 16),

                    _isGuestLoading
                      ? const CircularProgressIndicator()
                      : TextButton(
                          style: TextButton.styleFrom(
                            textStyle: theme.textTheme.bodyLarge,
                            foregroundColor: theme.colorScheme.onSurface, 
                          ),
                          onPressed: () async {
                            setState(() => _isGuestLoading = true);
                            
                            final authService = AuthService(); 
                            
                            final success = await authService.loginAnonymously();
                            
                           if (!context.mounted) return;

                            if (success) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const MainScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to login as guest')),
                              );
                            }
                          }, 
                          child: const Text('Continue as Guest')
                        ),
                ],
              )
            ],
          ),
        )
      )
    );
  }
}