import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../services/location_service.dart';

class LocationStep extends StatefulWidget {
  final VoidCallback onNext;
  
  const LocationStep({
    super.key,
    required this.onNext,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  final TextEditingController _locationController = TextEditingController();
  
  bool _isLoadingLocation = false;
  bool _isLocationSelected = false;
  String? _selectedLocation;
  
  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Where do you play?',
            style: AppTypography.h2,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'We\'ll help you find padel courts and players nearby.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          
          // Location input
          TextField(
            controller: _locationController,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your city or area',
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
              ),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryBlue,
              ),
              suffixIcon: _isLoadingLocation
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    ),
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _isLocationSelected = value.trim().isNotEmpty;
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Use current location button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey200),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: AppColors.white,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: _isLoadingLocation ? null : _getCurrentLocation,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Use Current Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedLocation ?? 'Get my current location automatically',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedLocation != null)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Continue button
          PrimaryButton(
            text: 'Continue',
            onPressed: (_isLocationSelected || _selectedLocation != null) ? _handleContinue : null,
            isLoading: false,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      HapticFeedback.lightImpact();
      final userLocation = await LocationService.getUserLocation();
      
      setState(() {
        _selectedLocation = '${userLocation.city}, ${userLocation.country}';
        _locationController.text = _selectedLocation!;
        _isLocationSelected = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to get location: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();
    
    // Save location data (will be integrated with state management later)
    final locationData = {
      'location': _selectedLocation ?? _locationController.text.trim(),
      'isCurrentLocation': _selectedLocation != null,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // TODO: Save to onboarding state
    print('Location data: $locationData');
    
    widget.onNext();
  }
}