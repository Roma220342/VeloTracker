import 'package:flutter/material.dart';
import 'package:velotracker/services/settings_service.dart';
import 'package:velotracker/screens/welcom_screens/welcome_screen.dart'; 
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/widgets/settings_widgets/setting_item.dart';
import 'package:velotracker/widgets/settings_widgets/unit_option_button.dart';
import 'package:velotracker/widgets/settings_widgets/logout_dialog.dart'; 
import 'package:velotracker/screens/auth_screens/sign_up_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _controller = SettingsController();

  @override
  void initState() {
    super.initState();
    _controller.loadSettings();
  }

  void _showLogoutDialog() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const LogoutDialog(),
    );

    if (confirm == true) {
      await _controller.logout(); 
      
      if (!mounted) return;
  
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        
        if (_controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text('Settings'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App Preferences', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  
                  // --- БЛОК 1: НАЛАШТУВАННЯ ДОДАТКУ ---
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: onSurfaceColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        const SettingItem(
                          icon: Icons.straighten,
                          title: 'Units of Measure',
                        ),
                        const SizedBox(height: 16),
                        
                        // Перемикач Km/Miles
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double segmentWidth = constraints.maxWidth / 2;
                              return Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    top: 0, bottom: 0,
                                    left: _controller.isKmSelected ? 0 : segmentWidth,
                                    width: segmentWidth,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      UnitOptionButton(
                                        title: 'Km',
                                        isActive: _controller.isKmSelected,
                                        onTap: () => _controller.toggleUnit(true),
                                      ),
                                      UnitOptionButton(
                                        title: 'Miles',
                                        isActive: !_controller.isKmSelected,
                                        onTap: () => _controller.toggleUnit(false),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  Text('Account Actions', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  
                  // --- БЛОК 2: АКАУНТ ---
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: onSurfaceColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        if (_controller.isGuest) ...[
                      
                          SettingItem(
                            icon: Icons.person_add_alt_1,
                            title: 'Finish Registration',
                            subtitle: 'Save your data permanently',
                            iconColor: theme.colorScheme.primary,
                            iconBgColor: primaryContainerColor,
                            onTap: null, 
                          ),
                          
                          const SizedBox(height: 12),

                          // 2. Кнопка "Sign Up" 
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton( 
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(isGuestConversion: true),
                                  ),
                                );
                              }, 
                              child: const Text('Sign Up'),
                            ),
                          ),
                        ] else ...[
                          // === ВАРІАНТ ДЛЯ ЗАРЕЄСТРОВАНОГО ===
                          SettingItem(
                            icon: Icons.person_outline,
                            title: 'Email',
                            subtitle: _controller.userEmail,
                            iconColor: textSecondaryColor,
                            iconBgColor: outlineColor,
                          ),
                        ],

                        const SizedBox(height: 32),
                        const Divider(height: 1, color: outlineColor),
                        const SizedBox(height: 32),
                        
                        // Кнопка Log Out
                        SettingItem(
                          icon: Icons.logout,
                          title: 'Log Out',
                          iconColor: errorColor,
                          iconBgColor: errorContainerColor,
                          isDestructive: true,
                          onTap: _showLogoutDialog, 
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}