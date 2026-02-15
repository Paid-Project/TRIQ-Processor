import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/user.service.dart';
import 'package:manager/services/language.service.dart';
import '../introduction/introduction_view.dart';

class LanguageSelectionView extends StatefulWidget {
  @override
  _LanguageSelectionViewState createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView>
    with TickerProviderStateMixin {
  String selectedLanguage = '';
  String searchQuery = '';
  bool isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  final List<Map<String, String>> languages = [
    {
      'code': 'en',
      'name': 'English',
      'native': 'English',
      'country': 'United States',
      'flag': '🇺🇸',
    },
    {
      'code': 'en-GB',
      'name': 'English (UK)',
      'native': 'English',
      'country': 'United Kingdom',
      'flag': '🇬🇧',
    },
    {
      'code': 'zh',
      'name': 'Chinese (Simplified)',
      'native': '中文',
      'country': 'China',
      'flag': '🇨🇳',
    },
    {
      'code': 'hi',
      'name': 'Hindi',
      'native': 'हिन्दी',
      'country': 'India',
      'flag': '🇮🇳',
    },
    {
      'code': 'ja',
      'name': 'Japanese',
      'native': '日本語',
      'country': 'Japan',
      'flag': '🇯🇵',
    },
    {
      'code': 'de',
      'name': 'German',
      'native': 'Deutsch',
      'country': 'Germany',
      'flag': '🇩🇪',
    },
    {
      'code': 'fr',
      'name': 'French',
      'native': 'Français',
      'country': 'France',
      'flag': '🇫🇷',
    },
    {
      'code': 'es',
      'name': 'Spanish',
      'native': 'Español',
      'country': 'Spain',
      'flag': '🇪🇸',
    },
    {
      'code': 'pt',
      'name': 'Portuguese',
      'native': 'Português',
      'country': 'Brazil',
      'flag': '🇧🇷',
    },
    {
      'code': 'ru',
      'name': 'Russian',
      'native': 'Русский',
      'country': 'Russia',
      'flag': '🇷🇺',
    },
    {
      'code': 'ar',
      'name': 'Arabic',
      'native': 'العربية',
      'country': 'Saudi Arabia',
      'flag': '🇸🇦',
    },
    {
      'code': 'bn',
      'name': 'Bengali',
      'native': 'বাংলা',
      'country': 'Bangladesh',
      'flag': '🇧🇩',
    },
    {
      'code': 'tr',
      'name': 'Turkish',
      'native': 'Türkçe',
      'country': 'Turkey',
      'flag': '🇹🇷',
    },
    {
      'code': 'it',
      'name': 'Italian',
      'native': 'Italiano',
      'country': 'Italy',
      'flag': '🇮🇹',
    },
    {
      'code': 'ko',
      'name': 'Korean',
      'native': '한국어',
      'country': 'South Korea',
      'flag': '🇰🇷',
    },
    {
      'code': 'vi',
      'name': 'Vietnamese',
      'native': 'Tiếng Việt',
      'country': 'Vietnam',
      'flag': '🇻🇳',
    },
    {
      'code': 'th',
      'name': 'Thai',
      'native': 'ไทย',
      'country': 'Thailand',
      'flag': '🇹🇭',
    },
    {
      'code': 'nl',
      'name': 'Dutch',
      'native': 'Nederlands',
      'country': 'Netherlands',
      'flag': '🇳🇱',
    },
    {
      'code': 'pl',
      'name': 'Polish',
      'native': 'Polski',
      'country': 'Poland',
      'flag': '🇵🇱',
    },
    {
      'code': 'id',
      'name': 'Malay/Indonesian',
      'native': 'Bahasa Indonesia',
      'country': 'Indonesia',
      'flag': '🇮🇩',
    },
    {
      'code': 'uk',
      'name': 'Ukrainian',
      'native': 'Українська',
      'country': 'Ukraine',
      'flag': '🇺🇦',
    },
  ];

  List<Map<String, String>> get filteredLanguages {
    if (searchQuery.isEmpty) {
      return languages;
    }
    return languages.where((language) {
      final name = language['name'] ?? '';
      final native = language['native'] ?? '';
      final country = language['country'] ?? '';
      return name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          native.toLowerCase().contains(searchQuery.toLowerCase()) ||
          country.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (isSearchVisible) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        searchQuery = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.scaffoldBackground,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                _buildSearchDropdown(),
                const SizedBox(height: 20),
                Expanded(child: _buildLanguageGrid()),
                const SizedBox(height: 20),
                _buildBottomSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageService.get('welcome'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),

                ],
              ),
              Text(
                LanguageService.get('choose_language_description'),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child:
            !isSearchVisible
                ? IconButton(
              icon: SvgPicture.asset(
                'assets/svg/search-normal.svg',
                width: 30,
                height: 30,
              ),
              onPressed: _toggleSearch,
            )
                : IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.black,
                size: 20,
              ),
              onPressed: _toggleSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchDropdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isSearchVisible ? 80 : 0,
      child: SizeTransition(
        sizeFactor: _searchAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: LanguageService.get('search_language'),
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                suffixIcon:
                    searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemCount: filteredLanguages.length,
        itemBuilder: (context, index) {
          final language = filteredLanguages[index];
          final isSelected = selectedLanguage == (language['name'] ?? '');

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedLanguage = language['name'] ?? '';
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flag
                      Center(
                        child: SizedBox(
                          height: 33,
                          child: Center(
                            child: Text(
                              language['flag'] ?? '🏳️',
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Country name
                      Text(
                        language['country'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        language['native'] ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // Selection indicator
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E3A8A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 43,
        child: ElevatedButton(
          onPressed: selectedLanguage.isNotEmpty ? _onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedLanguage.isNotEmpty
                    ? const Color(0xFF1E3A8A)
                    : Colors.grey.shade300,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.w18,
              vertical: AppSizes.h8,
            ),
          ),
          child: Text(
            LanguageService.get('continue'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _onContinue() async {
    if (selectedLanguage.isEmpty) return;
    try {
      locator<UserService>().updateSelectedLanguage(selectedLanguage);
      await saveSelectedLanguage(selectedLanguage);
      await saveLanguageSelectionFlag();
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => IntroductionView(),
            settings: const RouteSettings(name: '/introduction'),
          ),
        );
      }
    } catch (e) {
      print('Error saving language selection: $e');
      // Consider showing a user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageService.get('language_save_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
