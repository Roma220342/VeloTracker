import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velotracker/models/ride_model.dart';
import 'package:velotracker/widgets/stats_card.dart';
import 'package:velotracker/widgets/ride_card.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  // --- ДАНІ (ЗАГЛУШКИ) ---
  final List<RideModel> _allRides = [
    RideModel(id: '1', title: 'Morning Lake Loop', date: DateTime.now(), distance: 45.53, duration: '1:30:43', avgSpeed: 34.3),
    RideModel(id: '2', title: 'City Commute', date: DateTime.now().subtract(const Duration(days: 1)), distance: 12.4, duration: '0:45:10', avgSpeed: 18.5),
    RideModel(id: '3', title: 'Night Ride', date: DateTime.now().subtract(const Duration(days: 5)), distance: 22.0, duration: '1:10:00', avgSpeed: 20.1),
  ];
  // final List<RideModel> _allRides = []; // Для тестування Empty State

  List<RideModel> _filteredRides = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; 
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _filteredRides = _allRides;
  }

  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRides = _allRides;
      } else {
        _filteredRides = _allRides
            .where((ride) => ride.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasRides = _allRides.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      // --- APP BAR (Динамічний) ---
      appBar: _isSearching
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _filteredRides = _allRides;
                  });
                },
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _runSearch,
                decoration: const InputDecoration(
                  hintText: 'Search rides...',
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            )
          : AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Rides'),
              centerTitle: true,
              actions: [
                if (hasRides)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                  )
              ],
            ),

      // --- BOTTOM NAVIGATION BAR (Placeholder) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Rides'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),

      // --- BODY ---
      body: SafeArea(
        child: hasRides
            ? _buildDataContent(theme) 
            : _buildEmptyState(theme), 
      ),
    );
  }

  // --- ВІДЖЕТ: КОНТЕНТ З ДАНИМИ ---
  Widget _buildDataContent(ThemeData theme) {
    return Column(
      children: [
        // Приховуємо фільтри під час пошуку
        if (!_isSearching) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSlidingSegmentedControl(),
          ),
          const SizedBox(height: 16),
          
          // Статистика (Горизонтальний скрол)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                StatsCard(label: 'Total Dist.', value: '150.5 km'),
                StatsCard(label: 'Total Rides', value: '12'),
                StatsCard(label: 'Max Speed', value: '45.2', unit: 'km/h'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Список Поїздок
        Expanded(
          child: _filteredRides.isEmpty
              ? Center(
                  child: Text(
                    'No rides found',
                    style: theme.textTheme.bodyLarge?.copyWith(color: textSecondaryColor),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredRides.length,
                  itemBuilder: (context, index) {
                    return RideCard(
                      ride: _filteredRides[index],
                      onTap: () {
                        // TODO: Go to Details
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- ВІДЖЕТ: EMPTY STATE (З вашого коду) ---
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
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
                  width: 200,
                  colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
                ),
                const SizedBox(height: 24),
                Text('No Rides Yet?', style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Your adventures will appear here. Start your first ride now!', style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
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
    );
  }

  // --- ВІДЖЕТ: СЛАЙДЕР ФІЛЬТРУ ---
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
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.bodyMedium!.copyWith(
              color: isSelected ? Colors.white : textSecondaryColor
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}