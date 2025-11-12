import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../design_system/components.dart';
import '../services/analytics_service.dart';

class PadelAvailabilityEditor extends StatefulWidget {
  const PadelAvailabilityEditor({super.key});

  @override
  State<PadelAvailabilityEditor> createState() => _PadelAvailabilityEditorState();
}

class _PadelAvailabilityEditorState extends State<PadelAvailabilityEditor> {
  // Week days
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // Time slots (6 AM to 11 PM)
  final List<String> timeSlots = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'
  ];
  
  // Selected availability slots [day][hour] = isSelected
  Map<int, Set<int>> selectedSlots = {};
  
  // Recurring options
  bool isRecurring = false;
  String recurringType = 'weekly';
  
  // Drag selection state
  bool _isDragging = false;
  bool _dragSelectionMode = true; // true = select, false = deselect
  final Set<String> _draggedSlots = {};
  final GlobalKey _gridKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _loadExistingAvailability();
  }

  void _loadExistingAvailability() {
    // Load existing availability from storage
    // For demo, add some sample availability
    selectedSlots[1] = {18, 19, 20}; // Tuesday 6-9 PM
    selectedSlots[3] = {19, 20}; // Thursday 7-9 PM
    selectedSlots[5] = {10, 11, 18, 19}; // Saturday 10 AM-12 PM, 6-8 PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PadelColors.grey50,
      appBar: AppBar(
        backgroundColor: PadelColors.primary,
        foregroundColor: PadelColors.white,
        title: Text(
          'Set Availability',
          style: PadelTypography.h6.copyWith(color: PadelColors.white),
        ),
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: Text(
              'Clear',
              style: PadelTypography.bodyMedium.copyWith(
                color: PadelColors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(PadelSpacing.lg),
            decoration: BoxDecoration(
              color: PadelColors.white,
              boxShadow: [PadelShadows.sm],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'When are you available to play?',
                  style: PadelTypography.h6.copyWith(
                    color: PadelColors.primary,
                  ),
                ),
                SizedBox(height: PadelSpacing.sm),
                Text(
                  'Tap time slots to toggle your availability. Green slots will be visible to other players.',
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
                SizedBox(height: PadelSpacing.xs),
                Text(
                  'Tip: Drag across multiple slots to select/deselect them quickly!',
                  style: PadelTypography.bodySmall.copyWith(
                    color: PadelColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: PadelSpacing.md),
                
                // Recurring toggle
                Row(
                  children: [
                    Switch(
                      value: isRecurring,
                      onChanged: (value) {
                        setState(() {
                          isRecurring = value;
                        });
                      },
                      activeColor: PadelColors.accent,
                    ),
                    SizedBox(width: PadelSpacing.sm),
                    Text(
                      'Repeat weekly',
                      style: PadelTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    PadelChip(
                      label: '${_getTotalSelectedSlots()} slots',
                      style: PadelChipStyle.ghost,
                      color: PadelColors.primary,
                      size: PadelChipSize.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Availability Grid
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(PadelSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: PadelColors.white,
                  borderRadius: BorderRadius.circular(PadelRadius.lg),
                  boxShadow: [PadelShadows.md],
                ),
                child: Column(
                  children: [
                    // Days Header
                    Container(
                      padding: EdgeInsets.all(PadelSpacing.md),
                      decoration: BoxDecoration(
                        color: PadelColors.grey50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(PadelRadius.lg),
                          topRight: Radius.circular(PadelRadius.lg),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Time column header
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Time',
                              style: PadelTypography.labelMedium.copyWith(
                                color: PadelColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Day headers
                          ...weekDays.asMap().entries.map((entry) {
                            return Expanded(
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      entry.value,
                                      style: PadelTypography.labelMedium.copyWith(
                                        color: PadelColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: PadelSpacing.xs),
                                    Text(
                                      '${_getSelectedSlotsForDay(entry.key)}',
                                      style: PadelTypography.labelSmall.copyWith(
                                        color: PadelColors.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    
                    // Time slots grid
                    GestureDetector(
                      onPanStart: (details) {
                        _startDrag(details);
                      },
                      onPanUpdate: (details) {
                        _updateDrag(details);
                      },
                      onPanEnd: (details) {
                        _endDrag();
                      },
                      child: Container(
                        key: _gridKey,
                        child: Column(
                          children: timeSlots.asMap().entries.map((entry) {
                            final timeIndex = entry.key;
                            final timeSlot = entry.value;
                            
                            return Container(
                              key: ValueKey('time_$timeIndex'),
                              padding: EdgeInsets.symmetric(
                                horizontal: PadelSpacing.md,
                                vertical: PadelSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: PadelColors.grey200,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Time label
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      timeSlot,
                                      style: PadelTypography.bodySmall.copyWith(
                                        color: PadelColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Day slots
                                  ...weekDays.asMap().entries.map((dayEntry) {
                                    final dayIndex = dayEntry.key;
                                    final slotKey = '${dayIndex}_$timeIndex';
                                    final isSelected = selectedSlots[dayIndex]?.contains(timeIndex) ?? false;
                                    final isDragHighlighted = _isDragging && _draggedSlots.contains(slotKey);
                                    final wouldBeSelected = isDragHighlighted 
                                        ? _dragSelectionMode 
                                        : isSelected;
                                    
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 2),
                                        child: GestureDetector(
                                          onTap: () => _toggleSlot(dayIndex, timeIndex),
                                          child: AnimatedContainer(
                                            duration: PadelAnimations.fast,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: wouldBeSelected 
                                                  ? (isDragHighlighted 
                                                      ? PadelColors.accent.withOpacity(0.8)
                                                      : PadelColors.accent)
                                                  : (isDragHighlighted 
                                                      ? PadelColors.grey300
                                                      : PadelColors.grey100),
                                              borderRadius: BorderRadius.circular(PadelRadius.sm),
                                              border: Border.all(
                                                color: wouldBeSelected 
                                                    ? PadelColors.accent
                                                    : (isDragHighlighted
                                                        ? PadelColors.grey400
                                                        : PadelColors.grey200),
                                                width: isDragHighlighted ? 2 : 1,
                                              ),
                                              boxShadow: isDragHighlighted ? [
                                                BoxShadow(
                                                  color: PadelColors.accent.withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ] : null,
                                            ),
                                            child: Center(
                                              child: wouldBeSelected
                                                  ? Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: PadelColors.textOnAccent,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom actions
          Container(
            padding: EdgeInsets.all(PadelSpacing.lg),
            decoration: BoxDecoration(
              color: PadelColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: PadelButton(
                    text: 'Quick Add',
                    style: PadelButtonStyle.outline,
                    size: PadelButtonSize.medium,
                    icon: Icons.flash_on,
                    onPressed: _showQuickAddDialog,
                  ),
                ),
                SizedBox(width: PadelSpacing.md),
                Expanded(
                  flex: 2,
                  child: PadelButton(
                    text: 'Save Availability',
                    style: PadelButtonStyle.accent,
                    size: PadelButtonSize.medium,
                    icon: Icons.save,
                    onPressed: _saveAvailability,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSlot(int dayIndex, int timeIndex) {
    setState(() {
      if (selectedSlots[dayIndex] == null) {
        selectedSlots[dayIndex] = <int>{};
      }
      
      if (selectedSlots[dayIndex]!.contains(timeIndex)) {
        selectedSlots[dayIndex]!.remove(timeIndex);
      } else {
        selectedSlots[dayIndex]!.add(timeIndex);
      }
      
      // Remove empty day sets
      if (selectedSlots[dayIndex]!.isEmpty) {
        selectedSlots.remove(dayIndex);
      }
    });
  }

  // Drag selection methods
  void _startDrag(DragStartDetails details) {
    HapticFeedback.selectionClick();
    
    setState(() {
      _isDragging = true;
      _draggedSlots.clear();
    });
    
    // Determine drag mode based on the first slot
    final slotInfo = _getSlotFromPosition(details.localPosition);
    if (slotInfo != null) {
      final isCurrentlySelected = selectedSlots[slotInfo['day']]?.contains(slotInfo['time']) ?? false;
      _dragSelectionMode = !isCurrentlySelected; // Toggle mode
      
      final slotKey = '${slotInfo['day']}_${slotInfo['time']}';
      _draggedSlots.add(slotKey);
    }
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final slotInfo = _getSlotFromPosition(details.localPosition);
    if (slotInfo != null) {
      final slotKey = '${slotInfo['day']}_${slotInfo['time']}';
      
      // Only add if it's a new slot (to avoid unnecessary rebuilds)
      if (!_draggedSlots.contains(slotKey)) {
        HapticFeedback.lightImpact();
        setState(() {
          _draggedSlots.add(slotKey);
        });
      }
    }
  }

  void _endDrag() {
    if (!_isDragging) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      // Apply the drag selection
      for (String slotKey in _draggedSlots) {
        final parts = slotKey.split('_');
        final dayIndex = int.parse(parts[0]);
        final timeIndex = int.parse(parts[1]);
        
        if (selectedSlots[dayIndex] == null) {
          selectedSlots[dayIndex] = <int>{};
        }
        
        if (_dragSelectionMode) {
          // Select mode
          selectedSlots[dayIndex]!.add(timeIndex);
        } else {
          // Deselect mode
          selectedSlots[dayIndex]!.remove(timeIndex);
          if (selectedSlots[dayIndex]!.isEmpty) {
            selectedSlots.remove(dayIndex);
          }
        }
      }
      
      _isDragging = false;
      _draggedSlots.clear();
    });
  }

  Map<String, int>? _getSlotFromPosition(Offset position) {
    // Get the render box of the grid to calculate precise positions
    final RenderBox? renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    
    // Constants based on the layout structure
    const double timeSlotHeight = 48.0; // 40 (slot) + 8 (padding)
    const double timeColumnWidth = 60.0;
    
    // Calculate available width for day columns
    final double availableWidth = renderBox.size.width - timeColumnWidth - (PadelSpacing.md * 2);
    final double daySlotWidth = availableWidth / weekDays.length;
    
    // Calculate which time slot (row)
    final int timeIndex = (position.dy / timeSlotHeight).floor();
    
    // Calculate which day slot (column)
    final double dayAreaX = position.dx - timeColumnWidth;
    final int dayIndex = (dayAreaX / daySlotWidth).floor();
    
    // Validate the calculated indices
    if (timeIndex >= 0 && timeIndex < timeSlots.length && 
        dayIndex >= 0 && dayIndex < weekDays.length &&
        dayAreaX >= 0) {
      return {
        'day': dayIndex,
        'time': timeIndex,
      };
    }
    
    return null;
  }

  int _getSelectedSlotsForDay(int dayIndex) {
    return selectedSlots[dayIndex]?.length ?? 0;
  }

  int _getTotalSelectedSlots() {
    return selectedSlots.values.fold(0, (sum, slots) => sum + slots.length);
  }

  void _clearAll() {
    setState(() {
      selectedSlots.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All availability cleared'),
        backgroundColor: PadelColors.warning,
      ),
    );
  }

  void _showQuickAddDialog() {
    showDialog(
      context: context,
      builder: (context) => PadelQuickAddDialog(
        onApply: (days, startTime, endTime) {
          _applyQuickAdd(days, startTime, endTime);
        },
      ),
    );
  }

  void _applyQuickAdd(List<int> days, int startTime, int endTime) {
    setState(() {
      for (int day in days) {
        if (selectedSlots[day] == null) {
          selectedSlots[day] = <int>{};
        }
        
        for (int time = startTime; time <= endTime; time++) {
          selectedSlots[day]!.add(time);
        }
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quick availability added!'),
        backgroundColor: PadelColors.success,
      ),
    );
  }

  void _saveAvailability() async {
    // Save to storage/backend
    await AnalyticsService.logEvent(
      name: 'availability_set',
      parameters: {
        'total_slots': _getTotalSelectedSlots(),
        'recurring': isRecurring ? 'true' : 'false',
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Availability saved successfully!'),
        backgroundColor: PadelColors.success,
      ),
    );
    
    Navigator.pop(context);
  }
}

// Quick Add Dialog
class PadelQuickAddDialog extends StatefulWidget {
  final Function(List<int>, int, int) onApply;

  const PadelQuickAddDialog({
    super.key,
    required this.onApply,
  });

  @override
  State<PadelQuickAddDialog> createState() => _PadelQuickAddDialogState();
}

class _PadelQuickAddDialogState extends State<PadelQuickAddDialog> {
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> timeSlots = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'
  ];
  
  Set<int> selectedDays = {};
  int startTime = 18; // 6 PM default
  int endTime = 20; // 8 PM default

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PadelRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Add Availability',
              style: PadelTypography.h6.copyWith(
                color: PadelColors.primary,
              ),
            ),
            SizedBox(height: PadelSpacing.md),
            
            // Days selection
            Text(
              'Select Days',
              style: PadelTypography.labelLarge.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            SizedBox(height: PadelSpacing.sm),
            Wrap(
              spacing: PadelSpacing.sm,
              children: weekDays.asMap().entries.map((entry) {
                final dayIndex = entry.key;
                final dayName = entry.value;
                final isSelected = selectedDays.contains(dayIndex);
                
                return PadelChip(
                  label: dayName,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedDays.remove(dayIndex);
                      } else {
                        selectedDays.add(dayIndex);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            SizedBox(height: PadelSpacing.lg),
            
            // Time range
            Text(
              'Time Range',
              style: PadelTypography.labelLarge.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            SizedBox(height: PadelSpacing.sm),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: startTime,
                    decoration: InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PadelRadius.md),
                      ),
                    ),
                    items: timeSlots.asMap().entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        startTime = value!;
                        if (endTime <= startTime) {
                          endTime = startTime + 1;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: endTime,
                    decoration: InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PadelRadius.md),
                      ),
                    ),
                    items: timeSlots.asMap().entries
                        .where((entry) => entry.key > startTime)
                        .map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        endTime = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: PadelSpacing.xl),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: PadelButton(
                    text: 'Cancel',
                    style: PadelButtonStyle.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: PadelButton(
                    text: 'Apply',
                    style: PadelButtonStyle.accent,
                    onPressed: selectedDays.isNotEmpty 
                        ? () {
                            widget.onApply(selectedDays.toList(), startTime, endTime);
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}