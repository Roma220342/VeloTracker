import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

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
              SizedBox(height: screenHeight * 0.056), 
              SvgPicture.asset(
                'assets/icons/logo_welcome_screen.svg',
                height: 200,
                width: 200,
              ),
              SizedBox(height: 24),
              Text(
                'Ready to Ride?', 
                 style: theme.textTheme.headlineLarge,
                ),
              SizedBox(height: 16),
              Text(
                'Track your rides easily.\nAll your routes and stats in one place.', 
                 style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
                ),
              Spacer(),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: () {}, child: const Text('Sign In')),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: () {}, child: const Text('Sign Up')),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: theme.textTheme.bodyLarge,
                      foregroundColor: textTertiaryColor,
                    ),
                    onPressed: () {}, child: const Text('Continue as Guest')
                  ),
                  SizedBox(height: screenHeight * 0.037),
                ],
              )
             ],  
        ),
       )
      )
    );
  }
}