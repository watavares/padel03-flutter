// Enhanced Log Match Flow - Fast, Reliable & Friendly
// 4-step process: Match Info → Add Players → Enter Score → Confirmation
// Advanced micro-interactions and energetic design

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../design_system/modern_components.dart';

class LogMatchScreen extends StatefulWidget {
  const LogMatchScreen({super.key});

  @override
  State<LogMatchScreen> createState() => _LogMatchScreenState();
}

class _LogMatchScreenState extends State<LogMatchScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _successAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Match data
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedClub;
  String _matchType = '2v2 Match';
  
  // Score data
  final List<Map<String, int>> _sets = [
    {'your': 0, 'opponent': 0},
    {'your': 0, 'opponent': 0},
    {'your': 0, 'opponent': 0},
  ];
  int _currentSet = 0;
  int _setsPlayed = 1;
  
  // Players data
  String _partner = '';
  String _opponent1 = '';
  String _opponent2 = '';
  
  // UI state
  bool _isSubmitting = false;
  bool _showSuccess = false;
  
  final List<String> _clubs = [
    'PadelClub Madrid Centro',
    'Elite Padel Barcelona', 
    'Valencia Padel Arena',
    'Seville Sports Center',
    'Bilbao Padel Complex',
  ];
  
  final List<String> _matchTypes = [
    '2v2 Match',
    '1v1 Training', 
    'Tournament',
    'League Match',
  ];
  
  final List<Map<String, String>> _recentPlayers = [
    {'name': 'Alex Rodriguez', 'avatar': 'AR'},
    {'name': 'Maria Santos', 'avatar': 'MS'},
    {'name': 'Pedro Silva', 'avatar': 'PS'},
    {'name': 'Sarah Wilson', 'avatar': 'SW'},
    {'name': 'Carlos Mendez', 'avatar': 'CM'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _successAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _buildSuccessScreen();
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PadelColors.primary),
          onPressed: _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
        ),
        title: Text(
          'Log Match',
          style: PadelTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: PadelColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            child: Row(
              children: List.generate(_totalSteps, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? PadelColors.accent : PadelColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEntryScreen(),
                _buildScoreScreen(),
                _buildPlayersScreen(),
                _buildReviewScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _triggerPulse();
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _triggerPulse() {
    _pulseAnimationController.forward().then((_) {
      _pulseAnimationController.reverse();
    });
  }

  Future<void> _submitMatch() async {
    setState(() {
      _isSubmitting = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _isSubmitting = false;
      _showSuccess = true;
    });
    
    _successAnimationController.forward();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  String get _finalScore {
    final playedSets = _sets.take(_setsPlayed);
    return playedSets.map((set) => '${set['your']}-${set['opponent']}').join(', ');
  }

  String get _matchResult {
    int mySets = 0;
    int opponentSets = 0;
    
    // Count sets won
    for (int i = 0; i < _setsPlayed; i++) {
      if (_sets[i]['your']! > _sets[i]['opponent']!) {
        mySets++;
      } else {
        opponentSets++;
      }
    }
    
    if (mySets > opponentSets) {
      return 'Victory';
    } else if (opponentSets > mySets) {
      return 'Good Fight';
    } else {
      return 'Draw';
    }
  }

  Widget _buildQuickSelectItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PadelSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: PadelColors.grey300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PadelSpacing.sm),
              decoration: BoxDecoration(
                color: PadelColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: PadelColors.primary, size: 20),
            ),
            const SizedBox(width: PadelSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: PadelTypography.caption.copyWith(
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
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: PadelColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PadelModernCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PadelColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: PadelColors.primary, size: 24),
            ),
            const SizedBox(height: PadelSpacing.md),
            Text(
              title,
              style: PadelTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PadelSpacing.xs),
            Text(
              subtitle,
              style: PadelTypography.caption.copyWith(
                color: PadelColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClubPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Club',
              style: PadelTypography.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: PadelSpacing.lg),
            ...(_clubs.map((club) => ListTile(
              leading: Icon(Icons.location_on, color: PadelColors.primary),
              title: Text(club),
              onTap: () {
                setState(() {
                  _selectedClub = club;
                });
                Navigator.pop(context);
              },
            ))),
          ],
        ),
      ),
    );
  }

  void _showMatchTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Match Type',
              style: PadelTypography.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: PadelSpacing.lg),
            ...(_matchTypes.map((type) => ListTile(
              leading: Icon(Icons.group, color: PadelColors.primary),
              title: Text(type),
              onTap: () {
                setState(() {
                  _matchType = type;
                });
                Navigator.pop(context);
              },
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.lg),
      child: Column(
        children: [
          // Set Selector
          Container(
            padding: const EdgeInsets.all(PadelSpacing.sm),
            decoration: BoxDecoration(
              color: PadelColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(3, (index) {
                final isActive = index == _currentSet;
                final isPlayed = index < _setsPlayed;
                return Expanded(
                  child: GestureDetector(
                    onTap: isPlayed ? () {
                      setState(() {
                        _currentSet = index;
                      });
                    } : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: PadelSpacing.md),
                      decoration: BoxDecoration(
                        color: isActive ? PadelColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SET ${index + 1}',
                        textAlign: TextAlign.center,
                        style: PadelTypography.labelMedium.copyWith(
                          color: isActive ? Colors.white : 
                                 isPlayed ? PadelColors.primary : PadelColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: PadelSpacing.xl),

          // Score Display
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Your Team',
                      style: PadelTypography.labelLarge.copyWith(
                        color: PadelColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: PadelColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: PadelColors.primary, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${_sets[_currentSet]['your']}',
                          style: PadelTypography.h2.copyWith(
                            color: PadelColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 120,
                color: PadelColors.grey300,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Opponents',
                      style: PadelTypography.labelLarge.copyWith(
                        color: PadelColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: PadelColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: PadelColors.secondary, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${_sets[_currentSet]['opponent']}',
                          style: PadelTypography.h2.copyWith(
                            color: PadelColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: PadelSpacing.xl),

          // Keypad
          _buildKeypad(),

          const SizedBox(height: PadelSpacing.xl),

          // Set Controls
          if (_currentSet < 2) ...[
            Row(
              children: [
                Text(
                  'Set ${_currentSet + 2} Played?',
                  style: PadelTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _setsPlayed > _currentSet + 1,
                  onChanged: (value) {
                    setState(() {
                      if (value && _setsPlayed == _currentSet + 1) {
                        _setsPlayed++;
                      } else if (!value && _setsPlayed > _currentSet + 1) {
                        _setsPlayed = _currentSet + 1;
                      }
                    });
                  },
                  activeColor: PadelColors.accent,
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.lg),
          ],

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: PadelModernButton(
              text: 'Continue to Players',
              onPressed: _nextStep,
              style: PadelButtonStyle.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        // Number buttons
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: PadelSpacing.md),
            child: Row(
              children: [
                for (int col = 0; col < 3; col++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: col < 2 ? PadelSpacing.md : 0,
                      ),
                      child: _buildNumberButton(row * 3 + col + 1),
                    ),
                  ),
              ],
            ),
          ),
        // Zero button
        Row(
          children: [
            const Expanded(child: SizedBox()),
            Expanded(child: _buildNumberButton(0)),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _updateScore(number),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadelColors.grey200),
            ),
            child: Center(
              child: Text(
                '$number',
                style: PadelTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PadelColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateScore(int score) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Score'),
        content: Text('Set score to $score for:'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _sets[_currentSet]['your'] = score;
              });
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: Text('Your Team'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _sets[_currentSet]['opponent'] = score;
              });
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: Text('Opponents'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PadelSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PadelColors.primary.withOpacity(0.1),
                  PadelColors.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: PadelColors.accent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.sports_tennis,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: PadelSpacing.lg),
                Text(
                  'Ready to Log Your\nLatest Victory?',
                  textAlign: TextAlign.center,
                  style: PadelTypography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: PadelSpacing.md),
                Text(
                  'Let\'s capture those winning moments!',
                  textAlign: TextAlign.center,
                  style: PadelTypography.bodyLarge.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: PadelSpacing.xl),

          // Quick Setup Card
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Setup',
                    style: PadelTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.lg),
                  
                  // Date Selection
                  _buildQuickSelectItem(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: _selectedDate.day == DateTime.now().day 
                        ? 'Today' 
                        : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: PadelSpacing.md),
                  
                  // Time Selection
                  _buildQuickSelectItem(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _selectedTime.format(context),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: PadelSpacing.md),
                  
                  // Club Selection
                  _buildQuickSelectItem(
                    icon: Icons.location_on,
                    label: 'Club',
                    value: _selectedClub ?? 'Select Club',
                    onTap: () => _showClubPicker(),
                  ),
                  
                  const SizedBox(height: PadelSpacing.md),
                  
                  // Match Type
                  _buildQuickSelectItem(
                    icon: Icons.group,
                    label: 'Match Type',
                    value: _matchType,
                    onTap: () => _showMatchTypePicker(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: PadelSpacing.xl),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan QR',
                  subtitle: 'Quick setup',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR Scanner coming soon!')),
                    );
                  },
                ),
              ),
              const SizedBox(width: PadelSpacing.md),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.history,
                  title: 'Recent',
                  subtitle: 'Use last setup',
                  onTap: () {
                    setState(() {
                      _selectedClub = _clubs.first;
                      _partner = _recentPlayers[0]['name']!;
                      _opponent1 = _recentPlayers[1]['name']!;
                      _opponent2 = _recentPlayers[2]['name']!;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Loaded recent match setup!')),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: PadelSpacing.xl),

          // Continue Button
          ScaleTransition(
            scale: _pulseAnimation,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: PadelModernButton(
                text: 'Continue to Score',
                onPressed: _selectedClub != null ? _nextStep : null,
                style: PadelButtonStyle.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Who Played?',
            style: PadelTypography.h5.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Add your teammates and opponents',
            style: PadelTypography.bodyLarge.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: PadelSpacing.xl),

          // Your Partner
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(PadelSpacing.sm),
                        decoration: BoxDecoration(
                          color: PadelColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.person, color: PadelColors.primary, size: 20),
                      ),
                      const SizedBox(width: PadelSpacing.md),
                      Text(
                        'Your Partner',
                        style: PadelTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  TextFormField(
                    initialValue: _partner,
                    decoration: InputDecoration(
                      hintText: 'Enter partner name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _showPlayerPicker((name) {
                          setState(() {
                            _partner = name;
                          });
                        }),
                      ),
                    ),
                    onChanged: (value) {
                      _partner = value;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: PadelSpacing.lg),

          // Opponents
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(PadelSpacing.sm),
                        decoration: BoxDecoration(
                          color: PadelColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.sports_tennis, color: PadelColors.secondary, size: 20),
                      ),
                      const SizedBox(width: PadelSpacing.md),
                      Text(
                        'Opponents',
                        style: PadelTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  TextFormField(
                    initialValue: _opponent1,
                    decoration: InputDecoration(
                      hintText: 'Opponent 1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _showPlayerPicker((name) {
                          setState(() {
                            _opponent1 = name;
                          });
                        }),
                      ),
                    ),
                    onChanged: (value) {
                      _opponent1 = value;
                    },
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  TextFormField(
                    initialValue: _opponent2,
                    decoration: InputDecoration(
                      hintText: 'Opponent 2',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _showPlayerPicker((name) {
                          setState(() {
                            _opponent2 = name;
                          });
                        }),
                      ),
                    ),
                    onChanged: (value) {
                      _opponent2 = value;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: PadelSpacing.lg),

          // Recent Players
          Text(
            'Recent Players',
            style: PadelTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          
          Wrap(
            spacing: PadelSpacing.md,
            runSpacing: PadelSpacing.md,
            children: _recentPlayers.map((player) {
              return GestureDetector(
                onTap: () => _showPlayerPicker((name) {
                  // Let user choose where to assign this player
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PadelSpacing.md,
                    vertical: PadelSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: PadelColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PadelColors.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        player['avatar']!,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: PadelSpacing.xs),
                      Text(
                        player['name']!,
                        style: PadelTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: PadelSpacing.xl),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: PadelModernButton(
              text: 'Continue to Review',
              onPressed: _partner.isNotEmpty && _opponent1.isNotEmpty && _opponent2.isNotEmpty 
                ? _nextStep : null,
              style: PadelButtonStyle.accent,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerPicker(Function(String) onPlayerSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Player',
              style: PadelTypography.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: PadelSpacing.lg),
            ...(_recentPlayers.map((player) => ListTile(
              leading: CircleAvatar(
                backgroundColor: PadelColors.accent.withOpacity(0.2),
                child: Text(player['avatar']!),
              ),
              title: Text(player['name']!),
              onTap: () {
                onPlayerSelected(player['name']!);
                Navigator.pop(context);
              },
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Review Match',
            style: PadelTypography.h5.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Double-check everything before logging',
            style: PadelTypography.bodyLarge.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),

          const SizedBox(height: PadelSpacing.xl),

          // Match Summary
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Summary',
                    style: PadelTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.lg),
                  
                  _buildReviewItem(
                    'Date & Time',
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedTime.format(context)}',
                    Icons.event,
                  ),
                  _buildReviewItem(
                    'Club',
                    _selectedClub ?? 'Not set',
                    Icons.location_on,
                  ),
                  _buildReviewItem(
                    'Match Type',
                    _matchType,
                    Icons.group,
                  ),
                  _buildReviewItem(
                    'Final Score',
                    _finalScore,
                    Icons.scoreboard,
                  ),
                  _buildReviewItem(
                    'Result',
                    _matchResult,
                    _matchResult.contains('Victory') ? Icons.emoji_events : 
                    _matchResult.contains('Fight') ? Icons.trending_down : Icons.handshake,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: PadelSpacing.lg),

          // Players Summary
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Players',
                    style: PadelTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.lg),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Team',
                              style: PadelTypography.labelMedium.copyWith(
                                color: PadelColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: PadelSpacing.sm),
                            Text('You'),
                            if (_partner.isNotEmpty) Text(_partner),
                          ],
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 60,
                        color: PadelColors.grey300,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opponents',
                              style: PadelTypography.labelMedium.copyWith(
                                color: PadelColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: PadelSpacing.sm),
                            if (_opponent1.isNotEmpty) Text(_opponent1),
                            if (_opponent2.isNotEmpty) Text(_opponent2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: PadelSpacing.xl),

          // Submit Button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: PadelModernButton(
                    text: _isSubmitting ? 'Logging Match...' : 'Log Match',
                    onPressed: _isSubmitting ? null : _submitMatch,
                    style: PadelButtonStyle.accent,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PadelSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(PadelSpacing.sm),
            decoration: BoxDecoration(
              color: PadelColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: PadelColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: PadelSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PadelTypography.labelMedium.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
                const SizedBox(height: PadelSpacing.xs),
                Text(
                  value,
                  style: PadelTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PadelColors.primary,
            PadelColors.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PadelSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: PadelColors.accent,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: PadelColors.accent.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: PadelSpacing.xl),

              // Success Text
              FadeTransition(
                opacity: _scaleAnimation,
                child: Column(
                  children: [
                    Text(
                      'Match Logged!',
                      style: PadelTypography.h4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    Text(
                      'Your victory has been recorded',
                      style: PadelTypography.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: PadelSpacing.xl),

              // Results Card
              FadeTransition(
                opacity: _scaleAnimation,
                child: PadelModernCard(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(PadelSpacing.lg),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Final Score:',
                              style: PadelTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _finalScore,
                              style: PadelTypography.labelLarge.copyWith(
                                color: PadelColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PadelSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Result:',
                              style: PadelTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _matchResult,
                              style: PadelTypography.labelLarge.copyWith(
                                color: _matchResult.contains('Victory') ? Colors.green : 
                                       _matchResult.contains('Fight') ? Colors.orange : PadelColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: PadelSpacing.lg * 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Elo:',
                              style: PadelTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '1450',
                                  style: PadelTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: PadelSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: PadelSpacing.sm,
                                    vertical: PadelSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+15 ⬆',
                                    style: PadelTypography.caption.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: PadelSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rank:',
                              style: PadelTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Advanced',
                              style: PadelTypography.labelLarge.copyWith(
                                color: PadelColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: PadelSpacing.xl),

              // Action Buttons
              FadeTransition(
                opacity: _scaleAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: PadelModernButton(
                        text: 'Share Victory',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share feature coming soon!')),
                          );
                        },
                        style: PadelButtonStyle.accent,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: PadelModernButton(
                        text: 'Log Another Match',
                        onPressed: () {
                          setState(() {
                            _showSuccess = false;
                            _currentStep = 0;
                          });
                          _successAnimationController.reset();
                          _pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: PadelButtonStyle.outline,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: PadelModernButton(
                        text: 'Back to Home',
                        onPressed: () => Navigator.pop(context),
                        style: PadelButtonStyle.ghost,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}