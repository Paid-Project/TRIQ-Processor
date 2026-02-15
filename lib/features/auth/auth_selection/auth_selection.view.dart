import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/language.service.dart';
import 'auth_selection.vm.dart';

class AuthSelectionView extends StatefulWidget {
  const AuthSelectionView({super.key});

  @override
  State<AuthSelectionView> createState() => _AuthSelectionViewState();
}

class _AuthSelectionViewState extends State<AuthSelectionView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations with delays
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthSelectionViewModel>.reactive(
      viewModelBuilder: () => AuthSelectionViewModel(),
      onViewModelReady: (AuthSelectionViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, AuthSelectionViewModel model, Widget? child) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Hero Image Section
                Expanded(
                  flex: 7,
                  child: _buildHeroSection(context, model),
                ),

                // Content Section
                Expanded(
                  flex: 3,
                  child: _buildContentSection(context, model),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context, AuthSelectionViewModel model) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.scaffoldBackground,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background decorative elements
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value * 0.6,
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 150,
                      left: 30,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Main hero content with animations
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated App Logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    height: AppSizes.v150,
                    width: AppSizes.v150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          spreadRadius: 5,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(AppImages.triqLogo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSizes.h30),

                // Animated App Name/Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    LanguageService.get('Triq Innovations') ?? 'Welcome',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: AppSizes.h10),

                // Animated Subtitle
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w40),
                      child: Text(
                        LanguageService.get('welcome_to_triq'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, AuthSelectionViewModel model) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(AppSizes.w20),
          child: Column(
            children: [
              // Animated Sign Up Button
              _buildAnimatedButton(
                width: double.infinity,
                height: AppSizes.h55,
                onPressed: model.navigateToSignUp,
                isPrimary: true,
                text: LanguageService.get('sign_up') ?? 'Sign up',
                delay: 800,
              ),

              SizedBox(height: AppSizes.h12),

              // Animated Log In Button
              _buildAnimatedButton(
                width: double.infinity,
                height: AppSizes.h50,
                onPressed: model.navigateToLogin,
                isPrimary: false,
                text: LanguageService.get('login'),
                delay: 900,
              ),

              SizedBox(height: AppSizes.h20),

              // Updated Terms and Privacy (matching register page style)
              _buildSignInPrompt(context, model),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required double width,
    required double height,
    required VoidCallback onPressed,
    required bool isPrimary,
    required String text,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: SizedBox(
              width: width,
              height: height,
              child: isPrimary
                  ? ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 2,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v25),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
                  : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.lightGrey.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v25),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Could not launch $url: $e');
      // Optionally show error to the user
    }
  }


  Widget _buildSignInPrompt(BuildContext context, AuthSelectionViewModel model) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.w10),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "${LanguageService.get('i_agree_to_the')} ",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: LanguageService.get('terms_of_service'),
                        style: TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openUrl('https://www.freeprivacypolicy.com/live/38ff3e0d-37fd-440f-a2a0-a92c7c14fc89');
                          },
                      ),
                      TextSpan(text: "${LanguageService.get('and')} "),
                      TextSpan(
                        text: LanguageService.get('privacy_policy'),
                        style: TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openUrl('https://www.freeprivacypolicy.com/live/4fbd2c88-6839-4292-9a10-8c331bd89deb');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}