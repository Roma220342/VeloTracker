import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/widgets/setting_item.dart';
import 'package:velotracker/widgets/unit_option_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isKmSelected = true;
  bool _isDarkMode = false;
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

                    // Custom Animated Switcher (Km / Miles)
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
                              // Анімований Фон (Зелений)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                top: 0,
                                bottom: 0,
                                // Якщо вибрано Km (true) -> left: 0
                                // Якщо вибрано Miles (false) -> left: segmentWidth
                                left: _isKmSelected ? 0 : segmentWidth,
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
                                    isActive: _isKmSelected, // Якщо true - активна
                                    onTap: () {
                                      setState(() {
                                        _isKmSelected = true;
                                      });
                                    },
                                  ),
                                  UnitOptionButton(
                                    title: 'Miles',
                                    isActive: !_isKmSelected, // Якщо false - активна (Miles)
                                    onTap: () {
                                      setState(() {
                                        _isKmSelected = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(height: 1, color: outlineColor),
                    const SizedBox(height: 32),

                    // Dark Mode Switch
                    SettingItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: _isDarkMode,
                        activeThumbColor: primaryColor,
                        inactiveThumbColor: textPrimaryColor,
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                            // TODO: Реалізувати зміну теми
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Text('Account Actions', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: onSurfaceColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    // Email (Non-editable)
                    // Ми використовуємо SettingItem, але іконка буде зеленою (стандартною)
                    const SettingItem(
                      icon: Icons.person_outline,
                      title: 'Email',
                      subtitle: 'user@example.com',
                      iconColor: textSecondaryColor, 
                      iconBgColor: outlineColor,
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(height: 1, color: outlineColor),
                    const SizedBox(height: 32),

                    // Log Out Button
                    SettingItem(
                      icon: Icons.logout,
                      title: 'Log Out',
                      iconColor: errorColor, // Сірий
                      iconBgColor: errorContainerColor,
                      isDestructive: true, // Червоний текст
                      onTap: () {
                        // TODO: Логіка виходу (очистка токена і перехід на Welcome)
                        // Navigator.of(context).pushAndRemoveUntil(...)
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // TODO: Тут можна додати логіку переходу на інші екрани:
          // if (index == 0) Navigator.pushNamed(context, '/track');
          // if (index == 1) Navigator.pushNamed(context, '/rides');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_checked),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

}