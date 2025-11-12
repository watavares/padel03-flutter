import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../design_system/design_system.dart';
import '../design_system/modern_components.dart';
import '../models/lobby_model.dart';
import '../models/user_model.dart';
import '../providers/auth_providers.dart';
import '../services/lobby_service.dart';

class CreateLobbyScreen extends ConsumerStatefulWidget {
  const CreateLobbyScreen({super.key});

  @override
  ConsumerState<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends ConsumerState<CreateLobbyScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Form data
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedClub;
  String? _selectedCourt;
  String? _selectedLevel;
  String? _selectedType;
  int _playerCapacity = 4;
  double _price = 0.0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _clubs = [
    'PadelClub Madrid Centro',
    'Elite Padel Barcelona',
    'Valencia Padel Arena',
    'Seville Sports Center',
    'Bilbao Padel Complex',
  ];

  final List<String> _courts = [
    'Court 1 - Indoor Glass',
    'Court 2 - Outdoor Premium',
    'Court 3 - Indoor Standard',
    'Court 4 - Outdoor Basic',
  ];

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  final List<String> _types = [
    'Friendly',
    'Competitive',
    'Training',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
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

  void _submitLobby() async {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')),
        );
        return;
      }

      if (_selectedClub == null || _selectedCourt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select club and court')),
        );
        return;
      }

      if (_selectedLevel == null || _selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select skill level and match type')),
        );
        return;
      }

      try {
        // Show loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creating lobby...')),
        );

        // Get current user - try UserModel first, fallback to Firebase user
        final currentUserAsync = ref.read(currentUserProvider);
        UserModel? currentUser = currentUserAsync.when(
          data: (user) => user,
          loading: () => null,
          error: (_, __) => null,
        );
        
        // Fallback to Firebase user if UserModel not available
        if (currentUser == null) {
          final firebaseUser = ref.read(currentFirebaseUserProvider);
          if (firebaseUser != null) {
            // Create a minimal UserModel from Firebase user for lobby creation
            final fallbackDisplayName = firebaseUser.displayName ?? 
                firebaseUser.email?.split('@')[0] ?? 
                'Padel Player';
            currentUser = UserModel(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: fallbackDisplayName,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }
        
        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        // Convert datetime
        final dateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // Convert enums
        final skillLevel = SkillLevel.values.firstWhere(
          (e) => e.displayName == _selectedLevel,
        );
        final matchType = MatchType.values.firstWhere(
          (e) => e.displayName == _selectedType,
        );

        // Create request
        final request = CreateLobbyRequest(
          title: _titleController.text.trim(),
          dateTime: dateTime,
          clubName: _selectedClub!,
          courtName: _selectedCourt!,
          skillLevel: skillLevel,
          matchType: matchType,
          maxPlayers: _playerCapacity,
          pricePerPlayer: _price,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

        // Create lobby
        final lobbyId = await LobbyService.createLobby(request, currentUser);
        
        // Success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Lobby created successfully!'),
              backgroundColor: PadelColors.success,
            ),
          );
          Navigator.pop(context, lobbyId); // Return lobby ID
        }
      } catch (e) {
        // Error feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create lobby: ${e.toString()}'),
              backgroundColor: PadelColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PadelColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade700,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'Create Lobby',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  PadelColors.primary,
                  PadelColors.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        style: PadelTypography.labelMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                        style: PadelTypography.labelMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PadelSpacing.sm),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(PadelColors.accent),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),

          // Form Steps
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTitleStep(),
                  _buildDateTimeStep(),
                  _buildLocationStep(),
                  _buildMatchDetailsStep(),
                  _buildNotesStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: PadelModernButton(
                      text: 'Back',
                      onPressed: _previousStep,
                      style: PadelButtonStyle.outline,
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: PadelModernButton(
                    text: _currentStep == _totalSteps - 1 ? 'Create Lobby' : 'Next',
                    onPressed: _currentStep == _totalSteps - 1 ? _submitLobby : _nextStep,
                    style: PadelButtonStyle.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Let\'s Create Your Lobby',
            style: PadelTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Start by giving your lobby a catchy title that will attract other players.',
            style: PadelTypography.bodyLarge.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.xl),
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lobby Title',
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g., "Fun Sunday Morning Match"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: PadelColors.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title for your lobby';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(PadelSpacing.md),
                    decoration: BoxDecoration(
                      color: PadelColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: PadelColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: PadelSpacing.sm),
                        Expanded(
                          child: Text(
                            'Good titles include time, skill level, or match type!',
                            style: PadelTypography.caption.copyWith(
                              color: PadelColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildDateTimeStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'When do you want to play?',
            style: PadelTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Choose the date and time for your match.',
            style: PadelTypography.bodyLarge.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.xl),
          
          // Date Selection
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PadelSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: PadelColors.grey300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: PadelColors.primary,
                          ),
                          const SizedBox(width: PadelSpacing.md),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select date',
                            style: PadelTypography.bodyMedium.copyWith(
                              color: _selectedDate != null
                                  ? PadelColors.textPrimary
                                  : PadelColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: PadelSpacing.lg),
          
          // Time Selection
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 18, minute: 0),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PadelSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: PadelColors.grey300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: PadelColors.primary,
                          ),
                          const SizedBox(width: PadelSpacing.md),
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Select time',
                            style: PadelTypography.bodyMedium.copyWith(
                              color: _selectedTime != null
                                  ? PadelColors.textPrimary
                                  : PadelColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where will you play?',
            style: PadelTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Select the club and court for your match.',
            style: PadelTypography.bodyLarge.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.xl),
          
          // Club Selection
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Club',
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  DropdownButtonFormField<String>(
                    value: _selectedClub,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: PadelColors.primary),
                      ),
                    ),
                    hint: const Text('Select a club'),
                    items: _clubs.map((club) {
                      return DropdownMenuItem(
                        value: club,
                        child: Text(club),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClub = value;
                        _selectedCourt = null; // Reset court selection
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a club';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: PadelSpacing.lg),
          
          // Court Selection
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Court',
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  DropdownButtonFormField<String>(
                    value: _selectedCourt,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: PadelColors.primary),
                      ),
                    ),
                    hint: Text(_selectedClub == null ? 'Select a club first' : 'Select a court'),
                    items: _selectedClub != null ? _courts.map((court) {
                      return DropdownMenuItem(
                        value: court,
                        child: Text(court),
                      );
                    }).toList() : null,
                    onChanged: _selectedClub != null ? (value) {
                      setState(() {
                        _selectedCourt = value;
                      });
                    } : null,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a court';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMatchDetailsStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Details',
            style: PadelTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Set the skill level and match type.',
            style: PadelTypography.bodyLarge.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.xl),
          
          // Skill Level
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skill Level',
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: PadelColors.primary),
                      ),
                    ),
                    hint: const Text('Select skill level'),
                    items: _levels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a skill level';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: PadelSpacing.lg),
          
          // Match Type
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Type',
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  Row(
                    children: _types.map((type) {
                      final isSelected = _selectedType == type;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: type != _types.last ? PadelSpacing.sm : 0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedType = type;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(PadelSpacing.md),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? PadelColors.primary
                                    : PadelColors.grey100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? PadelColors.primary
                                      : PadelColors.grey300,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    type == 'Friendly'
                                        ? Icons.sports_handball
                                        : Icons.emoji_events,
                                    color: isSelected
                                        ? Colors.white
                                        : PadelColors.textSecondary,
                                  ),
                                  const SizedBox(width: PadelSpacing.sm),
                                  Text(
                                    type,
                                    style: PadelTypography.labelMedium.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : PadelColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: PadelSpacing.lg),
          
          // Player Capacity and Price
          Row(
            children: [
              Expanded(
                child: PadelModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(PadelSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Players',
                          style: PadelTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: PadelSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _playerCapacity > 2
                                  ? () {
                                      setState(() {
                                        _playerCapacity--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text(
                              '$_playerCapacity',
                              style: PadelTypography.h5.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _playerCapacity < 4
                                  ? () {
                                      setState(() {
                                        _playerCapacity++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: PadelSpacing.md),
              Expanded(
                child: PadelModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(PadelSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price (€)',
                          style: PadelTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: PadelSpacing.md),
                        TextFormField(
                          initialValue: _price.toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: PadelColors.primary),
                            ),
                            hintText: '0.00',
                          ),
                          onChanged: (value) {
                            _price = double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildNotesStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: PadelTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Add any special instructions or notes for other players.',
            style: PadelTypography.bodyLarge.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.xl),
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes (Optional)',
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'e.g., "Bring your own racket", "Beginners welcome", "Post-match drinks"...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: PadelColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(PadelSpacing.md),
                    decoration: BoxDecoration(
                      color: PadelColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: PadelColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: PadelSpacing.sm),
                        Expanded(
                          child: Text(
                            'Notes help other players know what to expect!',
                            style: PadelTypography.caption.copyWith(
                              color: PadelColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Lobby',
            style: PadelTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Double-check everything looks good before creating your lobby.',
            style: PadelTypography.bodyLarge.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.xl),
          Expanded(
            child: SingleChildScrollView(
              child: PadelModernCard(
                child: Padding(
                  padding: const EdgeInsets.all(PadelSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReviewItem(
                        'Title',
                        _titleController.text.isNotEmpty ? _titleController.text : 'Not set',
                        Icons.title,
                      ),
                      _buildReviewItem(
                        'Date & Time',
                        _selectedDate != null && _selectedTime != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at ${_selectedTime!.format(context)}'
                            : 'Not set',
                        Icons.event,
                      ),
                      _buildReviewItem(
                        'Location',
                        _selectedClub != null && _selectedCourt != null
                            ? '$_selectedClub - $_selectedCourt'
                            : 'Not set',
                        Icons.location_on,
                      ),
                      _buildReviewItem(
                        'Skill Level',
                        _selectedLevel ?? 'Not set',
                        Icons.sports,
                      ),
                      _buildReviewItem(
                        'Match Type',
                        _selectedType ?? 'Not set',
                        _selectedType == 'Friendly' ? Icons.sports_handball : Icons.emoji_events,
                      ),
                      _buildReviewItem(
                        'Player Capacity',
                        '$_playerCapacity players',
                        Icons.group,
                      ),
                      _buildReviewItem(
                        'Price',
                        _price > 0 ? '€${_price.toStringAsFixed(2)} per person' : 'Free',
                        Icons.euro,
                      ),
                      if (_notesController.text.isNotEmpty)
                        _buildReviewItem(
                          'Notes',
                          _notesController.text,
                          Icons.notes,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PadelSpacing.lg),
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
}