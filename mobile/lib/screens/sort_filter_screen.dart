import 'package:flutter/material.dart';
import '../models/sort_filter_data.dart';
import '../theme/app_theme.dart';

class SortFilterScreen extends StatefulWidget {
  final SortFilterData? initialFilter;

  const SortFilterScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<SortFilterScreen> createState() => _SortFilterScreenState();
}

class _SortFilterScreenState extends State<SortFilterScreen> {
  late String _selectedSort;
  late String _selectedCategory;
  late String _selectedRegion;
  late String _selectedGenre;
  late String _selectedYear;

  bool _isGenreExpanded = false;
  bool _isYearExpanded = false;

  // Options matching screenshot
  static const List<String> _sortOptions = ['Popularity', 'Latest Release'];
  static const List<String> _categoryOptions = ['Episode', 'Movie'];
  static const List<String> _regionOptions = ['All', 'Japan', 'Chinese', 'Others'];

  static const List<String> _initialGenres = [
    'All',
    'Action',
    'Slice of Life',
    'Magic',
    'Sci-Fi',
    'Mystery',
    'Comedy',
    'Romance',
    'Drama',
  ];

  static const List<String> _moreGenres = [
    'Fantasy',
    'Adventure',
    'Supernatural',
    'Horror',
    'Sports',
    'Isekai',
    'Psychological',
    'Thriller',
    'Mecha',
    'School',
    'Shounen',
    'Seinen',
    'Ecchi',
    'Music',
    'Historical',
    'Martial Arts',
    'Harem',
    'Demons',
  ];

  static const List<String> _initialYears = ['All', '2022', '2021'];

  static const List<String> _moreYears = [
    '2026',
    '2025',
    '2024',
    '2023',
    '2020',
    '2019',
    '2018',
    '2017',
    '2016',
    '2015',
  ];

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter ?? SortFilterData.fromScreenshot();
    _selectedSort = filter.sort;
    _selectedCategory = filter.category;
    _selectedRegion = filter.region;
    _selectedGenre = filter.genre;
    _selectedYear = filter.releaseYear;
  }

  void _onReset() {
    setState(() {
      _selectedSort = 'Popularity';
      _selectedCategory = 'Episode';
      _selectedRegion = 'All';
      _selectedGenre = 'All';
      _selectedYear = 'All';
    });
  }

  void _onApply() {
    final result = SortFilterData(
      sort: _selectedSort,
      category: _selectedCategory,
      region: _selectedRegion,
      genre: _selectedGenre,
      releaseYear: _selectedYear,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final visibleGenres = _isGenreExpanded
        ? [..._initialGenres, ..._moreGenres]
        : _initialGenres;

    final visibleYears = _isYearExpanded
        ? [..._initialYears, ..._moreYears]
        : _initialYears;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sort & Filter',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 1. Sort Section
                    _buildSectionTitle('Sort'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _sortOptions.map((opt) {
                        return _buildPillChip(
                          label: opt,
                          isSelected: _selectedSort == opt,
                          onTap: () => setState(() => _selectedSort = opt),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 2. Categories Section
                    _buildSectionTitle('Categories'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _categoryOptions.map((opt) {
                        return _buildPillChip(
                          label: opt,
                          isSelected: _selectedCategory == opt,
                          onTap: () => setState(() => _selectedCategory = opt),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 3. Region Section
                    _buildSectionTitle('Region'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _regionOptions.map((opt) {
                        return _buildPillChip(
                          label: opt,
                          isSelected: _selectedRegion == opt,
                          onTap: () => setState(() => _selectedRegion = opt),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 4. Genre Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Genre'),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isGenreExpanded = !_isGenreExpanded;
                            });
                          },
                          child: Text(
                            _isGenreExpanded ? 'See less' : 'See all',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: visibleGenres.map((g) {
                        return _buildPillChip(
                          label: g,
                          isSelected: _selectedGenre == g,
                          onTap: () => setState(() => _selectedGenre = g),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 5. Release Year Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Release Year'),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isYearExpanded = !_isYearExpanded;
                            });
                          },
                          child: Text(
                            _isYearExpanded ? 'See less' : 'See all',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: visibleYears.map((yr) {
                        return _buildPillChip(
                          label: yr,
                          isSelected: _selectedYear == yr,
                          onTap: () => setState(() => _selectedYear = yr),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),

            // Bottom Buttons (Reset & Apply)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.border
                        : AppColors.accent.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Reset Button (Mint background, green text)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        onPressed: _onReset,
                        style: TextButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF1B2B20)
                              : const Color(0xFFE8F8EE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Apply Button (Solid green background, white text)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildPillChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.accent,
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.accent,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
