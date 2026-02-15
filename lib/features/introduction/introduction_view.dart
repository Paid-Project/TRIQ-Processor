import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../services/language.service.dart';
import '../auth/login/login.view.dart';

class IntroductionView extends StatefulWidget {
  const IntroductionView({Key? key}) : super(key: key);

  @override
  State<IntroductionView> createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _imageTransitionController; // New animation controller for image transitions
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _imageScaleAnimation; // New animation for image scaling
  late Animation<double> _imageFadeAnimation; // New animation for image fading

  List<IntroPage> get _pages => [
    IntroPage(
      title: LanguageService.get("tracking"),
      subtitle: "T",
      subtitleImagePath: "assets/images/T.png",
      description: LanguageService.get("tracking_description"),
      icon: Icons.track_changes_rounded,
      primaryColor: Color(0xFF042c74),
      secondaryColor: Color(0xFF013ead),
      gradient: [Color(0xFF042c74), Color(0xFF013ead), Color(0xFF1B176D)],
      emojis: ["📊", "🔍", "📈", "⚡"],
      particles: 8,
      imagePath: "assets/images/intro1.png",
    ),
    IntroPage(
      title: LanguageService.get("resolution"),
      subtitle: "R",
      subtitleImagePath: "assets/images/R.png",
      description: LanguageService.get("resolution_description"),
      icon: Icons.check_circle_rounded,
      primaryColor: Color(0xFF388E3C),
      secondaryColor: Color(0xFF4CAF50),
      gradient: [Color(0xFF388E3C), Color(0xFF4CAF50), Color(0xFF66BB6A)],
      emojis: ["⚡", "✅", "🎯", "🚀"],
      particles: 8,
      imagePath: "assets/images/intro2.png",
    ),
    IntroPage(
      title: LanguageService.get("integration"),
      subtitle: "I",
      subtitleImagePath: "assets/images/I.png",
      description: LanguageService.get("integration_description"),
      icon: Icons.hub_rounded,
      primaryColor: Color(0xFF1976D2),
      secondaryColor: Color(0xFF2196F3),
      gradient: [Color(0xFF1976D2), Color(0xFF2196F3), Color(0xFF42A5F5)],
      emojis: ["🔗", "🤝", "🌐", "🔄"],
      particles: 8,
      imagePath: "assets/images/intro3.png",
    ),
    IntroPage(
      title: LanguageService.get("quality"),
      subtitle: "Q",
      subtitleImagePath: "assets/images/Q.png",
      description: LanguageService.get("quality_description"),
      icon: Icons.diamond_rounded,
      primaryColor: Color(0xFFff6b6b),
      secondaryColor: Color(0xFFFFA8A8),
      gradient: [Color(0xFFff6b6b), Color(0xFFFFA8A8), Color(0xFFFFCDD2)],
      emojis: ["💎", "🏆", "⭐", "🎖️"],
      particles: 8,
      imagePath: "assets/images/intro4.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Main content animation
    _animationController = AnimationController(duration: Duration(milliseconds: 1500), vsync: this);

    // Background animation
    _backgroundController = AnimationController(duration: Duration(milliseconds: 2000), vsync: this);

    // Floating elements animation
    _floatingController = AnimationController(duration: Duration(milliseconds: 3000), vsync: this);

    // Pulse animation for interactive elements
    _pulseController = AnimationController(duration: Duration(milliseconds: 1500), vsync: this);

    // Ripple animation for touch feedback
    _rippleController = AnimationController(duration: Duration(milliseconds: 600), vsync: this);

    // Image transition animation controller
    _imageTransitionController = AnimationController(duration: Duration(milliseconds: 800), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.2, 1.0, curve: Curves.easeInOut)));

    _slideUpAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut));

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _rippleController, curve: Curves.easeOut));

    // Image transition animations
    _imageScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _imageTransitionController, curve: Curves.easeInOut));

    _imageFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _imageTransitionController, curve: Curves.easeInOut));

    _animationController.forward();
    _backgroundController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _imageTransitionController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _imageTransitionController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animationController.reset();
    _animationController.forward();

    // Animate image transition
    _imageTransitionController.reset();
    _imageTransitionController.forward();

    // Haptic feedback for better interaction
    HapticFeedback.lightImpact();
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginView()));
    }

    // Trigger ripple animation
    _rippleController.forward().then((_) => _rippleController.reset());
    HapticFeedback.mediumImpact();
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    }

    // Trigger ripple animation
    _rippleController.forward().then((_) => _rippleController.reset());
    HapticFeedback.lightImpact();
  }

  Color _getAppBarColor(int index) {
    switch (index) {
      case 0:
        return AppColors.peachPuff; // Index 1: #FEF2E6
      case 1:
        return AppColors.mistyRose; // Index 2: #FFEAEA
      case 2:
        return AppColors.teaGreen; // Index 3: #F0F6EB
      case 3:
        return AppColors.lavenderBlue; // Index 4: #E9ECFB
      default:
        return AppColors.white; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentIndex];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.scaffoldBackground,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: _getAppBarColor(_currentIndex),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Image.asset('assets/images/logo2.png', height: 32, width: 65, fit: BoxFit.contain),
                  );
                },
              ),

              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginView()));
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(LanguageService.get("skip"), style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildNavigationButtons(currentPage),
        body: SafeArea(
          child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [_buildHeader(), _buildPageContent()])),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: SizedBox(
        height: Get.height * 0.5,
        width: Get.width,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _imageTransitionController,
              builder: (context, child) {
                return Positioned(
                  top: -65,
                  child: AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _imageScaleAnimation.value * (1.0 + _backgroundAnimation.value * 0.03), // Subtle breathing effect
                        child: Opacity(
                          opacity: _imageFadeAnimation.value,
                          child: Image.asset(_pages[_currentIndex].imagePath, height: Get.height * 0.5, width: Get.width, fit: BoxFit.fill),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Floating particles effect based on current page
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Stack(
                  children: List.generate(_pages[_currentIndex].particles, (index) {
                    final random = math.Random(index);
                    final xPosition = random.nextDouble() * 350;
                    final yPosition = random.nextDouble() * 300;
                    final animationOffset = random.nextDouble() * 2 * math.pi;

                    return Positioned(
                      left: xPosition + math.sin(_floatingAnimation.value * 2 * math.pi + animationOffset) * 20,
                      top: yPosition + math.cos(_floatingAnimation.value * 2 * math.pi + animationOffset) * 15,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 600),
                        opacity: 0.3,
                        child: Container(
                          width: 4 + random.nextDouble() * 6,
                          height: 4 + random.nextDouble() * 6,
                          decoration: BoxDecoration(
                            color: Color(0xFF042c74),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Color(0xFF042c74).withOpacity(0.3), blurRadius: 8, spreadRadius: 2)],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPageItem(_pages[index]);
            },
          ),
        ),
        Positioned(left: 14, child: _buildCapitalLatter(_pages[_currentIndex].subtitleImagePath ?? "")),
      ],
    );
  }

  Widget _buildCapitalLatter(String subtitleImagePath) {
    return Image.asset(
      subtitleImagePath,
      height: subtitleImagePath == "assets/images/Q.png" ? 140 : 128,
      width:
          subtitleImagePath == "assets/images/Q.png"
              ? 115
              : subtitleImagePath == "assets/images/I.png"
              ? 70
              : subtitleImagePath == "assets/images/R.png"
              ? 90
              : 105,
    );
  }

  Widget _buildPageItem(IntroPage page) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPageIndicators(),
              Text(page.title, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.black), textAlign: TextAlign.center),
              SizedBox(height: 20),

              Text(
                page.description,
                style: TextStyle(fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageIndicators() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (index) => _buildDotIndicator(index))),
    );
  }

  Widget _buildDotIndicator(int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _pageController.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 3),
        width: isActive ? 34 : 5,
        height: 5,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryVariant : AppColors.primaryVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(IntroPage page) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child:
                _currentIndex > 0
                    ? GestureDetector(
                      key: ValueKey('back'),
                      onTap: _previousPage,
                      child: Container(
                        child: Text(
                          LanguageService.get("back"),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                        ),
                      ),
                    )
                    : SizedBox(width: 60, key: ValueKey('empty')),
          ),

          // Next/Start button with progress indicator OR Continue button
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child:
                _currentIndex == _pages.length - 1
                    ? // Continue button for last page
                    GestureDetector(
                      key: ValueKey('continue'),
                      onTap: _nextPage, // or your completion handler
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF042c74), Color(0xFF013ead)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Color(0xFF042c74).withOpacity(0.3), blurRadius: 12, offset: Offset(0, 4))],
                        ),
                        child: Text(
                          LanguageService.get("continue"),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    )
                    : // Circular progress button for other pages
                    GestureDetector(
                      key: ValueKey('next'),
                      onTap: _nextPage,
                      child: AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 60,
                            height: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Circular progress indicator
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    value: (_currentIndex + 1) / _pages.length,
                                    backgroundColor: Color(0xFFE5E7EB),
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF042c74)),
                                    strokeWidth: 3,
                                  ),
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF042c74), Color(0xFF013ead)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Color(0xFF042c74).withOpacity(0.3), blurRadius: 12, offset: Offset(0, 4))],
                                  ),
                                  child: Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                ),

                                // Ripple effect
                                if (_rippleAnimation.value > 0)
                                  Container(
                                    width: 60 + (_rippleAnimation.value * 20),
                                    height: 60 + (_rippleAnimation.value * 20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Color(0xFF042c74).withOpacity(0.3 * (1 - _rippleAnimation.value)), width: 2),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class IntroPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradient;
  final List<String> emojis;
  final int particles;
  final String imagePath;
  final String? subtitleImagePath;

  IntroPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradient,
    required this.emojis,
    required this.particles,
    required this.imagePath,
    required this.subtitleImagePath,
  });
}
