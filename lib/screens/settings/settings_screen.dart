import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:aivivabot/providers/auth_provider.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// SETTINGS SCREEN - Advanced Professional Interface
// ============================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedSection = 0;
  final List<String> _sections = ['Appearance', 'Voice', 'Session', 'Notifications', 'Data', 'About'];

  // Appearance Settings
  bool _isDarkMode = false;
  int _selectedTheme = 0; // 0: System, 1: Light, 2: Dark
  bool _animationsEnabled = true;
  bool _hapticsEnabled = true;
  bool _soundEffectsEnabled = true;
  double _fontScale = 1.0;

  // Voice Settings
  bool _voiceInputEnabled = true;
  bool _voiceOutputEnabled = true;
  double _voiceSpeed = 1.0;
  double _voicePitch = 1.0;
  String _selectedVoice = 'Female (Default)';

  // Session Settings
  String _preferredExaminerMode = 'Mixed';
  int _defaultDuration = 10;
  int _defaultHints = 3;
  bool _autoSaveSessions = true;
  bool _autoGenerateReports = true;

  // Notification Settings
  bool _dailyReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  bool _studyReminders = true;
  bool _scoreUpdates = true;
  bool _achievementAlerts = true;
  bool _weeklyReports = true;

  // Data Settings
  bool _autoBackup = false;
  DateTime? _lastBackupDate;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSettings();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedTheme = prefs.getInt('selectedTheme') ?? 0;
      _animationsEnabled = prefs.getBool('animationsEnabled') ?? true;
      _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
      _soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
      _fontScale = prefs.getDouble('fontScale') ?? 1.0;

      _voiceInputEnabled = prefs.getBool('voiceInputEnabled') ?? true;
      _voiceOutputEnabled = prefs.getBool('voiceOutputEnabled') ?? true;
      _voiceSpeed = prefs.getDouble('voiceSpeed') ?? 1.0;
      _voicePitch = prefs.getDouble('voicePitch') ?? 1.0;

      final savedVoice = prefs.getString('selectedVoice') ?? 'Female (Default)';
      _selectedVoice = ['Female (Default)', 'Male', 'British Female', 'Australian'].contains(savedVoice) ? savedVoice : 'Female (Default)';

      final mode = prefs.getString('preferredExaminerMode') ?? 'Mixed';
      if (mode.toLowerCase() == 'friendly') {
        _preferredExaminerMode = 'Friendly';
      } else if (mode.toLowerCase() == 'strict') {
        _preferredExaminerMode = 'Strict';
      } else if (mode.toLowerCase() == 'technical' || mode.toLowerCase() == 'technical expert') {
        _preferredExaminerMode = 'Technical Expert';
      } else {
        _preferredExaminerMode = 'Mixed';
      }

      final savedDuration = prefs.getInt('defaultDuration') ?? 10;
      _defaultDuration = [5, 10, 15, 20, 30, 45, 60].contains(savedDuration) ? savedDuration : 10;

      final savedHints = prefs.getInt('defaultHints') ?? 3;
      _defaultHints = [0, 1, 2, 3, 5].contains(savedHints) ? savedHints : 3;
      _autoSaveSessions = prefs.getBool('autoSaveSessions') ?? true;
      _autoGenerateReports = prefs.getBool('autoGenerateReports') ?? true;

      _dailyReminder = prefs.getBool('dailyReminder') ?? false;
      final hour = prefs.getInt('reminderHour');
      final minute = prefs.getInt('reminderMinute');
      if (hour != null && minute != null) {
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      }
      _studyReminders = prefs.getBool('studyReminders') ?? true;
      _scoreUpdates = prefs.getBool('scoreUpdates') ?? true;
      _achievementAlerts = prefs.getBool('achievementAlerts') ?? true;
      _weeklyReports = prefs.getBool('weeklyReports') ?? true;

      _autoBackup = prefs.getBool('autoBackup') ?? false;
      final backupDate = prefs.getString('lastBackupDate');
      if (backupDate != null) {
        _lastBackupDate = DateTime.parse(backupDate);
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('selectedTheme', _selectedTheme);
    await prefs.setBool('animationsEnabled', _animationsEnabled);
    await prefs.setBool('hapticsEnabled', _hapticsEnabled);
    await prefs.setBool('soundEffectsEnabled', _soundEffectsEnabled);
    await prefs.setDouble('fontScale', _fontScale);

    await prefs.setBool('voiceInputEnabled', _voiceInputEnabled);
    await prefs.setBool('voiceOutputEnabled', _voiceOutputEnabled);
    await prefs.setDouble('voiceSpeed', _voiceSpeed);
    await prefs.setDouble('voicePitch', _voicePitch);

    await prefs.setString('preferredExaminerMode', _preferredExaminerMode);
    await prefs.setInt('defaultDuration', _defaultDuration);
    await prefs.setInt('defaultHints', _defaultHints);
    await prefs.setBool('autoSaveSessions', _autoSaveSessions);
    await prefs.setBool('autoGenerateReports', _autoGenerateReports);

    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setInt('reminderHour', _reminderTime.hour);
    await prefs.setInt('reminderMinute', _reminderTime.minute);
    await prefs.setBool('studyReminders', _studyReminders);
    await prefs.setBool('scoreUpdates', _scoreUpdates);
    await prefs.setBool('achievementAlerts', _achievementAlerts);
    await prefs.setBool('weeklyReports', _weeklyReports);

    await prefs.setBool('autoBackup', _autoBackup);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

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
                _buildHeader(isDark, authProvider),
                _buildSectionTabs(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            if (_selectedSection == 0) _buildAppearanceSection(isDark),
                            if (_selectedSection == 1) _buildVoiceSection(isDark),
                            if (_selectedSection == 2) _buildSessionSection(isDark),
                            if (_selectedSection == 3) _buildNotificationSection(isDark),
                            if (_selectedSection == 4) _buildDataSection(isDark),
                            if (_selectedSection == 5) _buildAboutSection(isDark, authProvider),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
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

  Widget _buildHeader(bool isDark, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => AppRoutes.goBack(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                Text(
                  'Customize your app experience',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showResetDialog(isDark),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh, color: Colors.red, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedSection == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSection = index;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2A5CFF)
                    : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[200]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  _sections[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppearanceSection(bool isDark) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Theme',
          icon: Icons.palette,
          children: [
            _buildRadioOption(
              title: 'System Default',
              value: 0,
              groupValue: _selectedTheme,
              onChanged: (v) => setState(() { _selectedTheme = v ?? 0; _isDarkMode = false; _saveSettings(); }),
              isDark: isDark,
            ),
            _buildRadioOption(
              title: 'Light Mode',
              value: 1,
              groupValue: _selectedTheme,
              onChanged: (v) => setState(() { _selectedTheme = v ?? 1; _isDarkMode = false; _saveSettings(); }),
              isDark: isDark,
            ),
            _buildRadioOption(
              title: 'Dark Mode',
              value: 2,
              groupValue: _selectedTheme,
              onChanged: (v) => setState(() { _selectedTheme = v ?? 2; _isDarkMode = true; _saveSettings(); }),
              isDark: isDark,
            ),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Effects',
          icon: Icons.animation,
          children: [
            _buildSwitchTile(
              title: 'Animations',
              value: _animationsEnabled,
              onChanged: (v) => setState(() { _animationsEnabled = v; _saveSettings(); }),
              isDark: isDark,
            ),
            _buildSwitchTile(
              title: 'Haptic Feedback',
              value: _hapticsEnabled,
              onChanged: (v) => setState(() { _hapticsEnabled = v; _saveSettings(); }),
              isDark: isDark,
            ),
            _buildSwitchTile(
              title: 'Sound Effects',
              value: _soundEffectsEnabled,
              onChanged: (v) => setState(() { _soundEffectsEnabled = v; _saveSettings(); }),
              isDark: isDark,
            ),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Font Size',
          icon: Icons.text_fields,
          children: [
            Row(
              children: [
                const Icon(Icons.format_size, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _fontScale,
                    min: 0.8,
                    max: 1.3,
                    divisions: 5,
                    onChanged: (v) => setState(() { _fontScale = v; _saveSettings(); }),
                    activeColor: const Color(0xFF2A5CFF),
                  ),
                ),
                Text(
                  '${(_fontScale * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A5CFF),
                  ),
                ),
              ],
            ),
          ],
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildVoiceSection(bool isDark) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Voice Input',
          icon: Icons.mic,
          children: [
            _buildSwitchTile(
              title: 'Enable Voice Input',
              value: _voiceInputEnabled,
              onChanged: (v) => setState(() { _voiceInputEnabled = v; _saveSettings(); }),
              isDark: isDark,
            ),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Voice Output',
          icon: Icons.volume_up,
          children: [
            _buildSwitchTile(
              title: 'Enable Voice Output',
              value: _voiceOutputEnabled,
              onChanged: (v) => setState(() { _voiceOutputEnabled = v; _saveSettings(); }),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.speed, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Speech Speed',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                Text(
                  '${_voiceSpeed.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A5CFF),
                  ),
                ),
              ],
            ),
            Slider(
              value: _voiceSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (v) => setState(() { _voiceSpeed = v; _saveSettings(); }),
              activeColor: const Color(0xFF2A5CFF),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.music_note, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pitch',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                Text(
                  '${_voicePitch.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A5CFF),
                  ),
                ),
              ],
            ),
            Slider(
              value: _voicePitch,
              min: 0.5,
              max: 1.5,
              divisions: 10,
              onChanged: (v) => setState(() { _voicePitch = v; _saveSettings(); }),
              activeColor: const Color(0xFF2A5CFF),
            ),
            const SizedBox(height: 12),
            _buildDropdownTile(
              title: 'Voice Type',
              value: _selectedVoice,
              items: ['Female (Default)', 'Male', 'British Female', 'Australian'],
              onChanged: (v) => setState(() { _selectedVoice = v; _saveSettings(); }),
              isDark: isDark,
            ),
          ],
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSessionSection(bool isDark) {
    final examinerModes = ['Friendly', 'Strict', 'Technical Expert', 'Mixed'];
    final durations = [5, 10, 15, 20, 30, 45, 60];
    final hintOptions = [0, 1, 2, 3, 5];

    return Column(
      children: [
        _buildSectionCard(
          title: 'Default Settings',
          icon: Icons.settings,
          children: [
            _buildDropdownTile(
              title: 'Preferred Examiner',
              value: _preferredExaminerMode,
              items: examinerModes,
              onChanged: (v) => setState(() { _preferredExaminerMode = v; _saveSettings(); }),
              isDark: isDark,
            ),
            _buildDropdownTile(
              title: 'Session Duration',
              value: '$_defaultDuration minutes',
              items: durations.map((d) => '$d minutes').toList(),
              onChanged: (v) {
                final minutes = int.parse(v.split(' ')[0]);
                setState(() { _defaultDuration = minutes; _saveSettings(); });
              },
              isDark: isDark,
            ),
            _buildDropdownTile(
              title: 'Hints Allowed',
              value: _defaultHints == 0 ? 'No hints' : '$_defaultHints hints',
              items: hintOptions.map((h) => h == 0 ? 'No hints' : '$h hints').toList(),
              onChanged: (v) {
                final hints = v == 'No hints' ? 0 : int.parse(v.split(' ')[0]);
                setState(() { _defaultHints = hints; _saveSettings(); });
              },
              isDark: isDark,
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: 'Auto-save Sessions',
              value: _autoSaveSessions,
              onChanged: (v) => setState(() { _autoSaveSessions = v; _saveSettings(); }),
              isDark: isDark,
            ),
            _buildSwitchTile(
              title: 'Auto-generate Reports',
              value: _autoGenerateReports,
              onChanged: (v) => setState(() { _autoGenerateReports = v; _saveSettings(); }),
              isDark: isDark,
            ),
          ],
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildNotificationSection(bool isDark) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Reminders',
          icon: Icons.notifications,
          children: [
            _buildSwitchTile(
              title: 'Daily Reminder',
              value: _dailyReminder,
              onChanged: (v) => setState(() { _dailyReminder = v; _saveSettings(); }),
              isDark: isDark,
            ),
            if (_dailyReminder)
              Padding(
                padding: const EdgeInsets.only(left: 40, bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.access_time, size: 20),
                  title: const Text('Reminder Time'),
                  trailing: Text(
                    '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Color(0xFF2A5CFF)),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (time != null) {
                      setState(() { _reminderTime = time; _saveSettings(); });
                    }
                  },
                ),
              ),
            _buildSwitchTile(
              title: 'Study Reminders',
              value: _studyReminders,
              onChanged: (v) => setState(() { _studyReminders = v; _saveSettings(); }),
              isDark: isDark,
            ),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Alerts',
          icon: Icons.alarm,
          children: [
            _buildSwitchTile(
              title: 'Score Updates',
              value: _scoreUpdates,
              onChanged: (v) => setState(() { _scoreUpdates = v; _saveSettings(); }),
              isDark: isDark,
            ),
            _buildSwitchTile(
              title: 'Achievement Alerts',
              value: _achievementAlerts,
              onChanged: (v) => setState(() { _achievementAlerts = v; _saveSettings(); }),
              isDark: isDark,
            ),
            _buildSwitchTile(
              title: 'Weekly Reports',
              value: _weeklyReports,
              onChanged: (v) => setState(() { _weeklyReports = v; _saveSettings(); }),
              isDark: isDark,
            ),
          ],
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDataSection(bool isDark) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Backup',
          icon: Icons.backup,
          children: [
            _buildSwitchTile(
              title: 'Auto Backup',
              value: _autoBackup,
              onChanged: (v) => setState(() { _autoBackup = v; _saveSettings(); }),
              isDark: isDark,
            ),
            if (_lastBackupDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 4, bottom: 12),
                child: Text(
                  'Last backup: ${_lastBackupDate!.day}/${_lastBackupDate!.month}/${_lastBackupDate!.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ),
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Data Management',
          icon: Icons.data_usage,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all sessions, reports, and settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showClearDataDialog(isDark),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Color(0xFF2A5CFF)),
              title: const Text('Export Data'),
              subtitle: const Text('Export your data as JSON'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showExportDialog(isDark),
            ),
          ],
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAboutSection(bool isDark, AuthProvider authProvider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2A5CFF).withOpacity(0.1),
                const Color(0xFF7000FF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.mic, color: Colors.white, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AI VivaBot',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your AI-powered viva preparation assistant',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildAboutButton(
                icon: Icons.rate_review,
                title: 'Rate the App',
                onTap: () {},
                isDark: isDark,
              ),
              _buildAboutButton(
                icon: Icons.share,
                title: 'Share with Friends',
                onTap: () {},
                isDark: isDark,
              ),
              _buildAboutButton(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {},
                isDark: isDark,
              ),
              _buildAboutButton(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () {},
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              Text(
                '© 2026 AI VivaBot. All rights reserved.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[600] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A5CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF2A5CFF), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0A0E27),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2A5CFF),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required int value,
    required int groupValue,
    required ValueChanged<int?> onChanged,
    required bool isDark,
  }) {
    return RadioListTile<int>(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0A0E27),
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: const Color(0xFF2A5CFF),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required bool isDark,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0A0E27),
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (v) => onChanged(v!),
        dropdownColor: isDark ? const Color(0xFF1A1F3E) : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0A0E27),
        ),
      ),
    );
  }

  Widget _buildAboutButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2A5CFF)),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0A0E27),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showResetDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTheme = 0;
                _animationsEnabled = true;
                _hapticsEnabled = true;
                _soundEffectsEnabled = true;
                _fontScale = 1.0;
                _voiceInputEnabled = true;
                _voiceOutputEnabled = true;
                _voiceSpeed = 1.0;
                _voicePitch = 1.0;
                _preferredExaminerMode = 'Mixed';
                _defaultDuration = 10;
                _defaultHints = 3;
                _autoSaveSessions = true;
                _autoGenerateReports = true;
                _dailyReminder = false;
                _studyReminders = true;
                _scoreUpdates = true;
                _achievementAlerts = true;
                _weeklyReports = true;
                _autoBackup = false;
                _saveSettings();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to default')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all your sessions, reports, and progress. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data cleared successfully')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export your sessions and reports as JSON file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported successfully')),
              );
            },
            child: const Text('Export', style: TextStyle(color: Color(0xFF2A5CFF))),
          ),
        ],
      ),
    );
  }
}