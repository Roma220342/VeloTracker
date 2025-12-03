import 'package:flutter/material.dart';
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
  //Заглужка
  final List<RideModel> _allRides = [
    RideModel(id: '1', title: 'Morning Lake Loop', date: DateTime.now(), distance: 45.53, duration: '1:30:43', avgSpeed: 34.3),
    RideModel(id: '2', title: 'City Commute', date: DateTime.now().subtract(const Duration(days: 1)), distance: 12.4, duration: '0:45:10', avgSpeed: 18.5),
    RideModel(id: '3', title: 'Night Ride', date: DateTime.now().subtract(const Duration(days: 5)), distance: 22.0, duration: '1:10:00', avgSpeed: 20.1),
  ];
  
  // Заглужка порожня 
  // final List<RideModel> _allRides = []; 

  List<RideModel> _filteredRides = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Зберігаємо, яка кнопка фільтра обрана (0=All, 1=Week, 2=Month)
  int _selectedFilterIndex = 0; 

  @override
  void initState() {
    super.initState();
    _filteredRides = _allRides;
  }

  // Логіка пошуку поїздок за назвою
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); 
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,

        // app bar
        appBar: _isSearching
            ? AppBar( //шукаєм
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearching = false; // Виходимо з пошуку
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
            : AppBar(//дефолт
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
                  // Показуємо лупу тільки якщо є поїздки
                  if (hasRides)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearching = true; // Вмикаємо пошук
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      ),
                    )
                ],
              ),

        // тіло екрану
        body: SafeArea(
          child: hasRides
              ? _buildDataContent(theme) // Показуємо список
              : _buildEmptyState(theme), // Показуємо "No Rides Yet"
        ),
      ),
    );
  }

  // Віджет, коли є дані
  Widget _buildDataContent(ThemeData theme) {
    return Column(
      children: [
        // Якщо не шукаємо, показуємо фільтри і статистику
        if (!_isSearching) ...[
          const SizedBox(height: 16),
          
          // 1. філтр
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SlidingSegmentedControl(
              selectedIndex: _selectedFilterIndex,
              values: const ['All', 'Week', 'Month'],
              onValueChanged: (index) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),

          // 2. стаистика
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

        // 3. список поїздок
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
                        // TODO: Перехід на деталі
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Віджет, коли пусто 
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          
          // Фільтр все одно показуємо
          SlidingSegmentedControl(
            selectedIndex: _selectedFilterIndex,
            values: const ['All', 'Week', 'Month'],
            onValueChanged: (index) {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
          ),
          
          // Картинка і текст "Пусто"
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/logo_welcome_screen.svg',
                  width: 200,
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
                  'Your adventures will appear here. Start your first ride now!',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Кнопка "Почати"
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
}