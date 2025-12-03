import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velotracker/main.dart';
import 'package:velotracker/screens/auth_screens/sign_in_screen.dart';
import 'package:velotracker/screens/auth_screens/sign_up_screen.dart';
 
class WelcomeScreen extends StatelessWidget{
  const WelcomeScreen({super.key});
   
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
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: theme.textTheme.bodyLarge,
                      // ВИПРАВЛЕННЯ 3: Замінено неіснуючий textTertiaryColor на колір з теми (наприклад, onSurface.withOpacity(0.6))
                      foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6), 
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
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