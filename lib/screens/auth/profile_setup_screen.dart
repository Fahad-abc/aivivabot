import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/providers/auth_provider.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// PROFILE SETUP SCREEN - Beautiful Enhanced Interface
// ============================================================

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fypTitleController = TextEditingController();
  final _fypSupervisorController = TextEditingController();
  final _fypDescriptionController = TextEditingController();

  String _selectedDepartment = 'Computer Science';
  int _selectedYear = 4;
  List<String> _selectedTechnologies = [];
  bool _isLoading = false;
  int _currentStep = 0;

  final List<String> _departments = [
    'Computer Science',
    'Software Engineering',
    'Information Technology',
    'Artificial Intelligence',
    'Data Science',
    'Cyber Security',
  ];

  final List<int> _years = [1, 2, 3, 4, 5];

  final List<String> _availableTechnologies = [
    'Flutter',
    'React Native',
    'Firebase',
    'MongoDB',
    'MySQL',
    'PostgreSQL',
    'Node.js',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'TensorFlow',
    'PyTorch',
    'AWS',
    'Google Cloud',
    'Azure',
    'Docker',
    'Kubernetes',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadExistingData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  void _loadExistingData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phoneNumber ?? '';
      _fypTitleController.text = user.fypTitle ?? '';
      _fypSupervisorController.text = user.fypSupervisor ?? '';
      _fypDescriptionController.text = user.fypDescription ?? '';
      
      if (user.department.isNotEmpty && _departments.contains(user.department)) {
        _selectedDepartment = user.department;
      } else {
        _selectedDepartment = _departments.first;
      }

      if (_years.contains(user.yearOfStudy)) {
        _selectedYear = user.yearOfStudy;
      } else {
        _selectedYear = 4; // Default to a valid year in our list
      }

      _selectedTechnologies = List.from(user.fypTechnologies);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _fypTitleController.dispose();
    _fypSupervisorController.dispose();
    _fypDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safety check: Ensure the selected department and year are valid dropdown values to prevent assertion crashes
    if (!_departments.contains(_selectedDepartment)) {
      _selectedDepartment = _departments.isNotEmpty ? _departments.first : 'Computer Science';
    }
    if (!_years.contains(_selectedYear)) {
      _selectedYear = _years.isNotEmpty ? _years.first : 4;
    }

    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                const Color(0xFF0A0E27),
                const Color(0xFF1A1F3E),
                const Color(0xFF16213E),
              ]
                  : [
                const Color(0xFFF5F7FF),
                const Color(0xFFE8ECFF),
                const Color(0xFFE0E7FF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildStepper(isDark),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildCurrentStepContent(isDark),
                        ),
                        const SizedBox(height: 32),
                        _buildNavigationButtons(isDark),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => AppRoutes.goBack(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                Text(
                  'Tell us about yourself and your FYP',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.6)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildStepIndicator(
            step: 0,
            title: 'Personal',
            isActive: _currentStep == 0,
            isCompleted: _currentStep > 0,
            isDark: isDark,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 0
                  ? const Color(0xFF2A5CFF)
                  : (isDark ? Colors.grey[800] : Colors.grey[300]),
            ),
          ),
          _buildStepIndicator(
            step: 1,
            title: 'Academic',
            isActive: _currentStep == 1,
            isCompleted: _currentStep > 1,
            isDark: isDark,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 1
                  ? const Color(0xFF2A5CFF)
                  : (isDark ? Colors.grey[800] : Colors.grey[300]),
            ),
          ),
          _buildStepIndicator(
            step: 2,
            title: 'FYP Info',
            isActive: _currentStep == 2,
            isCompleted: _currentStep > 2,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String title,
    required bool isActive,
    required bool isCompleted,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFF2A5CFF)
                : (isActive
                ? const Color(0xFF2A5CFF).withOpacity(0.2)
                : (isDark ? Colors.grey[800] : Colors.grey[200])),
            border: isActive && !isCompleted
                ? Border.all(color: const Color(0xFF2A5CFF), width: 2)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF2A5CFF)
                    : (isDark ? Colors.grey[500] : Colors.grey[400]),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? const Color(0xFF2A5CFF)
                : (isDark ? Colors.grey[500] : Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep(isDark);
      case 1:
        return _buildAcademicInfoStep(isDark);
      case 2:
        return _buildFypInfoStep(isDark);
      default:
        return _buildPersonalInfoStep(isDark);
    }
  }

  Widget _buildPersonalInfoStep(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF2A5CFF).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Full Name
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.badge_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Phone Number
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number (Optional)',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoStep(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF2A5CFF).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Academic Information',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Department
          Text(
            'Department',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0A0E27).withOpacity(0.6)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[200]!,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDepartment,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1A1F3E) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  fontSize: 16,
                ),
                items: _departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(dept),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Year of Study
          Text(
            'Year of Study',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: _years.map((year) {
              final isSelected = _selectedYear == year;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedYear = year;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2A5CFF)
                        : (isDark
                        ? const Color(0xFF1A1F3E)
                        : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[300]!),
                    ),
                  ),
                  child: Text(
                    '$year${_getYearSuffix(year)} Year',
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getYearSuffix(int year) {
    if (year == 1) return 'st';
    if (year == 2) return 'nd';
    if (year == 3) return 'rd';
    return 'th';
  }

  Widget _buildFypInfoStep(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF2A5CFF).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.code, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Final Year Project',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // FYP Title
          _buildTextField(
            controller: _fypTitleController,
            label: 'Project Title',
            hint: 'Enter your FYP title',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your project title';
              }
              return null;
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // FYP Supervisor
          _buildTextField(
            controller: _fypSupervisorController,
            label: 'Supervisor Name (Optional)',
            hint: 'Enter your supervisor\'s name',
            icon: Icons.person_outline,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // Technologies
          Text(
            'Technologies Used',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTechnologies.map((tech) {
              final isSelected = _selectedTechnologies.contains(tech);
              return FilterChip(
                label: Text(tech),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTechnologies.add(tech);
                    } else {
                      _selectedTechnologies.remove(tech);
                    }
                  });
                },
                backgroundColor: isDark
                    ? const Color(0xFF0A0E27)
                    : Colors.grey[100],
                selectedColor: const Color(0xFF2A5CFF).withOpacity(0.2),
                checkmarkColor: const Color(0xFF2A5CFF),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF2A5CFF)
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // FYP Description
          _buildTextField(
            controller: _fypDescriptionController,
            label: 'Project Description (Optional)',
            hint: 'Briefly describe your project',
            icon: Icons.description_outlined,
            maxLines: 4,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF2A5CFF)),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0A0E27).withOpacity(0.6)
                : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2A5CFF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(bool isDark) {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () {
                setState(() {
                  _currentStep--;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2A5CFF),
                side: const BorderSide(color: Color(0xFF2A5CFF)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(_currentStep == 2 ? 'Complete Setup' : 'Next'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == 1) {
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == 2) {
      await _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        department: _selectedDepartment,
        yearOfStudy: _selectedYear,
        fypTitle: _fypTitleController.text.trim(),
        fypSupervisor: _fypSupervisorController.text.trim(),
        fypTechnologies: _selectedTechnologies,
        fypDescription: _fypDescriptionController.text.trim(),
      );

      if (success) {
        AppRoutes.navigateToDashboard(context);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to save profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}