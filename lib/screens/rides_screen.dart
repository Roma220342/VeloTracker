import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  int _selectedFilterIndex = 0;
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              'assets/icons/logo_rides_screen.svg',
              height: 24,
              colorFilter: const ColorFilter.mode(textPrimaryColor, BlendMode.srcIn),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text('Rides'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildSlidingSegmentedControl(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logo_welcome_screen.svg',
                      height: 200,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Rides Yet?',
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your adventures will appear here. Start \nyour first ride now!',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Start Your First Ride'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlidingSegmentedControl() {
    final theme = Theme.of(context);
    const int itemsCount = 3;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: onSurfaceColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double segmentWidth = constraints.maxWidth / itemsCount;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: _selectedFilterIndex * segmentWidth,
                top: 0,
                bottom: 0,
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
                  _buildSingleTab('All', 0),
                  _buildSingleTab('Week', 1),
                  _buildSingleTab('Month', 2),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSingleTab(String text, int index) {
    final isSelected = _selectedFilterIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.bodyMedium!.copyWith(
              color: isSelected ? Colors.white : textSecondaryColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}