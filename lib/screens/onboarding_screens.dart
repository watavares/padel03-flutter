import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../design_system/components.dart';
import '../services/analytics_service.dart';

// Splash Screen with Logo Animation
class PadelSplashScreen extends StatefulWidget {
  const PadelSplashScreen({super.key});

  @override
  State<PadelSplashScreen> createState() => _PadelSplashScreenState();
}

class _PadelSplashScreenState extends State<PadelSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _logoController.forward();
    await Future.delayed(Duration(milliseconds: 1000));
    await _fadeController.forward();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PadelWelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: PadelAnimations.normal,
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: PadelColors.primaryGradient,
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: PadelColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [PadelShadows.xl],
                          ),
                          child: Icon(
                            Icons.sports_tennis,
                            size: 60,
                            color: PadelColors.textOnAccent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Welcome Screen
class PadelWelcomeScreen extends StatefulWidget {
  const PadelWelcomeScreen({super.key});

  @override
  State<PadelWelcomeScreen> createState() => _PadelWelcomeScreenState();
}

class _PadelWelcomeScreenState extends State<PadelWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PadelColors.primary,
              PadelColors.secondary,
              PadelColors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(PadelSpacing.lg),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: PadelColors.accent,
                                  shape: BoxShape.circle,
                                  boxShadow: [PadelShadows.xl],
                                ),
                                child: Icon(
                                  Icons.sports_tennis,
                                  size: 80,
                                  color: PadelColors.textOnAccent,
                                ),
                              ),
                              SizedBox(height: PadelSpacing.xxl),
                              Text(
                                'PadelArena',
                                style: PadelTypography.h1.copyWith(
                                  color: PadelColors.white,
                                  fontSize: 48,
                                ),
                              ),
                              SizedBox(height: PadelSpacing.md),
                              Text(
                                'Find your next match.\nClimb the ladder.',
                                style: PadelTypography.h5.copyWith(
                                  color: PadelColors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PadelButton(
                                text: 'Sign Up',
                                style: PadelButtonStyle.accent,
                                size: PadelButtonSize.large,
                                isExpanded: true,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PadelSignUpScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: PadelSpacing.md),
                              PadelButton(
                                text: 'Log In',
                                style: PadelButtonStyle.outline,
                                size: PadelButtonSize.large,
                                isExpanded: true,
                                onPressed: () {
                                  // Navigate to login screen
                                },
                              ),
                              SizedBox(height: PadelSpacing.lg),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Sign Up Screen
class PadelSignUpScreen extends StatelessWidget {
  const PadelSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PadelColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PadelColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(PadelSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join PadelArena',
                style: PadelTypography.h2.copyWith(
                  color: PadelColors.primary,
                ),
              ),
              SizedBox(height: PadelSpacing.sm),
              Text(
                'Connect with players and compete in your city',
                style: PadelTypography.bodyLarge.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
              SizedBox(height: PadelSpacing.xxl),
              
              // Social Login Buttons
              PadelButton(
                text: 'Continue with Google',
                icon: Icons.g_mobiledata,
                style: PadelButtonStyle.outline,
                size: PadelButtonSize.large,
                isExpanded: true,
                onPressed: () => _signUpWithGoogle(context),
              ),
              SizedBox(height: PadelSpacing.md),
              PadelButton(
                text: 'Continue with Apple',
                icon: Icons.apple,
                style: PadelButtonStyle.primary,
                size: PadelButtonSize.large,
                isExpanded: true,
                onPressed: () => _signUpWithApple(context),
              ),
              SizedBox(height: PadelSpacing.md),
              PadelButton(
                text: 'Continue with Email',
                icon: Icons.email_outlined,
                style: PadelButtonStyle.secondary,
                size: PadelButtonSize.large,
                isExpanded: true,
                onPressed: () => _signUpWithEmail(context),
              ),
              
              Spacer(),
              
              // Terms and Privacy
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: PadelTypography.bodySmall.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: PadelColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: PadelColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: PadelSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _signUpWithGoogle(BuildContext context) async {
    try {
      await AnalyticsService.logEvent(
        name: 'sign_up_method_selected', 
        parameters: {'method': 'google'}
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PadelCityPickerScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign up failed: $e')),
      );
    }
  }

  void _signUpWithApple(BuildContext context) async {
    try {
      await AnalyticsService.logEvent(
        name: 'sign_up_method_selected', 
        parameters: {'method': 'apple'}
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PadelCityPickerScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple sign up failed: $e')),
      );
    }
  }

  void _signUpWithEmail(BuildContext context) async {
    try {
      await AnalyticsService.logEvent(
        name: 'sign_up_method_selected', 
        parameters: {'method': 'email'}
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PadelCityPickerScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sign up failed: $e')),
      );
    }
  }
}

// City Picker Screen
class PadelCityPickerScreen extends StatefulWidget {
  const PadelCityPickerScreen({super.key});

  @override
  State<PadelCityPickerScreen> createState() => _PadelCityPickerScreenState();
}

class _PadelCityPickerScreenState extends State<PadelCityPickerScreen> {
  String? selectedCity;
  bool isUsingGPS = false;
  
  final List<String> cities = [
    'Madrid',
    'Barcelona',
    'Valencia',
    'Sevilla',
    'Bilbao',
    'Málaga',
    'Zaragoza',
    'Murcia',
    'Palma',
    'Las Palmas',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PadelColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PadelColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(PadelSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your City',
                style: PadelTypography.h2.copyWith(
                  color: PadelColors.primary,
                ),
              ),
              SizedBox(height: PadelSpacing.sm),
              Text(
                'Find players and courts in your area',
                style: PadelTypography.bodyLarge.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
              SizedBox(height: PadelSpacing.xxl),
              
              // GPS Detection
              PadelCard(
                onTap: _detectLocation,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: PadelColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(PadelRadius.md),
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: PadelColors.accent,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: PadelSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use Current Location',
                            style: PadelTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Automatically detect your city',
                            style: PadelTypography.bodySmall.copyWith(
                              color: PadelColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUsingGPS)
                      Icon(
                        Icons.check_circle,
                        color: PadelColors.success,
                        size: 24,
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: PadelSpacing.lg),
              
              Text(
                'Or choose from popular cities:',
                style: PadelTypography.labelLarge.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
              SizedBox(height: PadelSpacing.md),
              
              // City List
              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (context, index) => SizedBox(height: PadelSpacing.sm),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = selectedCity == city;
                    
                    return PadelCard(
                      backgroundColor: isSelected 
                          ? PadelColors.primary.withOpacity(0.1)
                          : PadelColors.white,
                      border: isSelected
                          ? Border.all(color: PadelColors.primary, width: 2)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedCity = city;
                          isUsingGPS = false;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            city,
                            style: PadelTypography.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? PadelColors.primary : PadelColors.textPrimary,
                            ),
                          ),
                          Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: PadelColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Continue Button
              PadelButton(
                text: 'Continue',
                style: PadelButtonStyle.accent,
                size: PadelButtonSize.large,
                isExpanded: true,
                onPressed: (selectedCity != null || isUsingGPS) ? _continue : null,
              ),
              SizedBox(height: PadelSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _detectLocation() async {
    setState(() {
      isUsingGPS = true;
      selectedCity = null;
    });
    
    await AnalyticsService.logEvent(name: 'city_detection_used');
    
    // Simulate GPS detection
    await Future.delayed(Duration(seconds: 1));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location detected: Madrid'),
        backgroundColor: PadelColors.success,
      ),
    );
  }

  void _continue() async {
    final city = isUsingGPS ? 'Madrid' : selectedCity!;
    await AnalyticsService.logEvent(
      name: 'city_selected', 
      parameters: {'city': city}
    );
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PadelLevelSelectorScreen()),
      );
    }
  }
}

// Level Selector Screen
class PadelLevelSelectorScreen extends StatefulWidget {
  const PadelLevelSelectorScreen({super.key});

  @override
  State<PadelLevelSelectorScreen> createState() => _PadelLevelSelectorScreenState();
}

class _PadelLevelSelectorScreenState extends State<PadelLevelSelectorScreen> {
  double selectedLevel = 3.5;
  
  final Map<double, String> levelDescriptions = {
    1.0: 'Complete Beginner',
    1.5: 'Beginner',
    2.0: 'Beginner+',
    2.5: 'Intermediate-',
    3.0: 'Intermediate',
    3.5: 'Intermediate+',
    4.0: 'Advanced-',
    4.5: 'Advanced',
    5.0: 'Advanced+',
    5.5: 'Expert-',
    6.0: 'Expert',
    6.5: 'Expert+',
    7.0: 'Professional',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PadelColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PadelColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(PadelSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What\'s Your Level?',
                style: PadelTypography.h2.copyWith(
                  color: PadelColors.primary,
                ),
              ),
              SizedBox(height: PadelSpacing.sm),
              Text(
                'Help us match you with players of similar skill',
                style: PadelTypography.bodyLarge.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Level Display
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: PadelColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [PadelShadows.xl],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedLevel.toString(),
                            style: PadelTypography.h1.copyWith(
                              color: PadelColors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            levelDescriptions[selectedLevel] ?? '',
                            style: PadelTypography.bodyMedium.copyWith(
                              color: PadelColors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: PadelSpacing.xxl),
                    
                    // Level Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: PadelColors.accent,
                        inactiveTrackColor: PadelColors.grey200,
                        thumbColor: PadelColors.accent,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 16),
                        overlayColor: PadelColors.accent.withOpacity(0.2),
                        trackHeight: 8,
                      ),
                      child: Slider(
                        value: selectedLevel,
                        min: 1.0,
                        max: 7.0,
                        divisions: 12,
                        onChanged: (value) {
                          setState(() {
                            selectedLevel = value;
                          });
                        },
                      ),
                    ),
                    
                    SizedBox(height: PadelSpacing.md),
                    
                    // Level Hints
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Beginner',
                          style: PadelTypography.bodySmall.copyWith(
                            color: PadelColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Intermediate',
                          style: PadelTypography.bodySmall.copyWith(
                            color: PadelColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Advanced',
                          style: PadelTypography.bodySmall.copyWith(
                            color: PadelColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Pro',
                          style: PadelTypography.bodySmall.copyWith(
                            color: PadelColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Continue Button
              PadelButton(
                text: 'Continue',
                style: PadelButtonStyle.accent,
                size: PadelButtonSize.large,
                isExpanded: true,
                onPressed: _continue,
              ),
              SizedBox(height: PadelSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() async {
    await AnalyticsService.logEvent(
      name: 'level_selected', 
      parameters: {'level': selectedLevel}
    );
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PadelPhotoUploadScreen()),
      );
    }
  }
}

// Photo Upload & Summary Screen
class PadelPhotoUploadScreen extends StatefulWidget {
  const PadelPhotoUploadScreen({super.key});

  @override
  State<PadelPhotoUploadScreen> createState() => _PadelPhotoUploadScreenState();
}

class _PadelPhotoUploadScreenState extends State<PadelPhotoUploadScreen> {
  bool hasPhoto = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PadelColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PadelColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'Skip',
              style: PadelTypography.bodyMedium.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(PadelSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Your Photo',
                style: PadelTypography.h2.copyWith(
                  color: PadelColors.primary,
                ),
              ),
              SizedBox(height: PadelSpacing.sm),
              Text(
                'Help other players recognize you on the court',
                style: PadelTypography.bodyLarge.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Photo Upload Area
                    GestureDetector(
                      onTap: _uploadPhoto,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: hasPhoto 
                              ? PadelColors.accent.withOpacity(0.1)
                              : PadelColors.grey100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasPhoto ? PadelColors.accent : PadelColors.grey300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: hasPhoto
                            ? Icon(
                                Icons.check_circle,
                                size: 80,
                                color: PadelColors.accent,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 60,
                                    color: PadelColors.grey400,
                                  ),
                                  SizedBox(height: PadelSpacing.sm),
                                  Text(
                                    'Tap to add photo',
                                    style: PadelTypography.bodyMedium.copyWith(
                                      color: PadelColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    SizedBox(height: PadelSpacing.xxl),
                    
                    // Summary Card
                    PadelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Summary',
                            style: PadelTypography.h6.copyWith(
                              color: PadelColors.primary,
                            ),
                          ),
                          SizedBox(height: PadelSpacing.md),
                          _buildSummaryRow('City', 'Madrid'),
                          SizedBox(height: PadelSpacing.sm),
                          _buildSummaryRow('Level', '3.5 - Intermediate+'),
                          SizedBox(height: PadelSpacing.sm),
                          _buildSummaryRow('Photo', hasPhoto ? 'Added' : 'Not added'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Enter Arena Button
              PadelButton(
                text: 'Enter the Arena',
                style: PadelButtonStyle.accent,
                size: PadelButtonSize.large,
                isExpanded: true,
                onPressed: _completeOnboarding,
              ),
              SizedBox(height: PadelSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: PadelTypography.bodyMedium.copyWith(
            color: PadelColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: PadelTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _uploadPhoto() {
    setState(() {
      hasPhoto = true;
    });
    
    AnalyticsService.logEvent(name: 'photo_uploaded');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo uploaded successfully!'),
        backgroundColor: PadelColors.success,
      ),
    );
  }

  void _skip() {
    AnalyticsService.logEvent(name: 'photo_upload_skipped');
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    await AnalyticsService.logEvent(name: 'sign_up_completed');
    
    if (mounted) {
      // Navigate to main app
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Container(), // Replace with main app
        ),
        (route) => false,
      );
    }
  }
}