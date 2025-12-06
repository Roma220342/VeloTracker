import 'package:flutter/material.dart';
import 'package:velotracker/screens/rides_screens/ride_details_screen.dart'; // Екран деталей
import 'package:velotracker/services/ride_service.dart'; // Сервіс
import 'package:velotracker/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velotracker/models/ride_model.dart';
import 'package:velotracker/widgets/rides_widgets/stats_card.dart';
import 'package:velotracker/widgets/rides_widgets/ride_card.dart';
import 'package:velotracker/widgets/rides_widgets/sliding_segmented_control.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final RideService _rideService = RideService();
  
  List<RideModel> _allRides = []; // Тут будуть реальні дані
  List<RideModel> _filteredRides = [];
  bool _isLoading = true; // Стан завантаження
  
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; 

  @override
  void initState() {
    super.initState();
    _loadRides(); // Завантажуємо дані при старті
  }

  // Функція завантаження
  Future<void> _loadRides() async {
    setState(() => _isLoading = true);
    
    // Стукаємо на сервер
    final rides = await _rideService.getUserRides();
    
    // Сортуємо: нові зверху
    rides.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _allRides = rides;
        _filteredRides = rides; // Спочатку показуємо всі
        _isLoading = false;
      });
      // Застосуємо фільтр, якщо він був обраний
      _applyFilter(_selectedFilterIndex);
    }
  }

  // Логіка пошуку
  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _applyFilter(_selectedFilterIndex); // Повертаємо поточний фільтр
      } else {
        _filteredRides = _allRides
            .where((ride) => ride.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Логіка фільтрів (All / Week / Month)
  void _applyFilter(int index) {
    setState(() {
      _selectedFilterIndex = index;
      final now = DateTime.now();
      
      if (index == 0) {
        // All
        _filteredRides = _allRides;
      } else if (index == 1) {
        // Week (останні 7 днів)
        _filteredRides = _allRides.where((ride) {
          return now.difference(ride.date).inDays <= 7;
        }).toList();
      } else if (index == 2) {
        // Month (останні 30 днів)
        _filteredRides = _allRides.where((ride) {
          return now.difference(ride.date).inDays <= 30;
        }).toList();
      }
    });
  }
  
  // Оновлення списку при поверненні з деталей (на випадок видалення/зміни)
  Future<void> _refreshList() async {
    await _loadRides();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Показуємо пустий стан тільки якщо завантаження завершилось і список пустий
    final bool isEmptyState = !_isLoading && _allRides.isEmpty; 

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,

        // --- APP BAR ---
        appBar: _isSearching
            ? AppBar( 
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearching = false; 
                      _searchController.clear();
                      _applyFilter(_selectedFilterIndex);
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
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/velo_logo.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(textPrimaryColor, BlendMode.srcIn),
                    ),
                  ),
                ),
                leadingWidth: 48,
                title: const Text('Rides'),
                centerTitle: true,
                actions: [
                  if (!isEmptyState) // Ховаємо пошук, якщо нема чого шукати
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),
                    )
                ],
              ),

        // --- BODY ---
        body: SafeArea(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) // Крутилка
              : isEmptyState
                  ? _buildEmptyState(theme) // Пустий екран
                  : RefreshIndicator( // Можливість потягнути вниз для оновлення
                      onRefresh: _refreshList,
                      child: _buildDataContent(theme),
                    ),
        ),
      ),
    );
  }

  Widget _buildDataContent(ThemeData theme) {
    // Рахуємо загальну статистику для карток зверху
    double totalDist = 0;
    double maxSpeed = 0;
    for (var r in _allRides) {
      totalDist += r.distance;
      if (r.maxSpeed > maxSpeed) maxSpeed = r.maxSpeed;
    }

    return Column(
      children: [
        if (!_isSearching) ...[
          const SizedBox(height: 16),
          
          // Фільтр
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SlidingSegmentedControl(
              selectedIndex: _selectedFilterIndex,
              values: const ['All', 'Week', 'Month'],
              onValueChanged: _applyFilter,
            ),
          ),
          
          const SizedBox(height: 16),

          // Статистика (динамічна!)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                StatsCard(label: 'Total Dist.', value: '${totalDist.toStringAsFixed(1)} km'),
                StatsCard(label: 'Total Rides', value: '${_allRides.length}'),
                StatsCard(label: 'Max Speed', value: maxSpeed.toStringAsFixed(1), unit: 'km/h'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Список
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
                    final ride = _filteredRides[index];
                    return RideCard(
                      ride: ride,
                      onTap: () async {
                        // Перехід на деталі
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RideDetailsScreen(ride: ride),
                          ),
                        );
                        // Оновити список, якщо повернулись (раптом там буде видалення)
                        _refreshList(); 
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SlidingSegmentedControl(
            selectedIndex: _selectedFilterIndex,
            values: const ['All', 'Week', 'Month'],
            onValueChanged: (index) {}, // Неактивний
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/logo_welcome_screen.svg', // Твоя картинка
                  width: 200,
                ),
                const SizedBox(height: 24),
                Text(
                  'No Rides Yet?',
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your adventures will appear here. Start your first ride now!',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}