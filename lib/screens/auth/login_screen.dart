import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/providers/auth_provider.dart';
import 'package:aivivabot/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ============================================================
// LOGIN SCREEN - With Google Sign-In (Android + Web)
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogoSection(isDark),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFormSection(isDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildDivider(isDark),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSocialButtons(isDark),
                  ),
                  const SizedBox(height: 32),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSignUpLink(isDark),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A5CFF),
                Color(0xFF7000FF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2A5CFF).withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.mic,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'AI VivaBot',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF2A5CFF),
                  Color(0xFF7000FF),
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your AI-Powered Viva Assistant',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(bool isDark) {
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
          children: [
            Text(
              'Welcome Back!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue your viva preparation',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Enter a valid email';
                }
                return null;
              },
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: const Color(0xFF2A5CFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
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
                    : const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0A0E27),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF2A5CFF)),
        suffixIcon: suffixIcon,
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
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: Icons.g_mobiledata,
            label: 'Google',
            onTap: _handleGoogleSignIn,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.person_outline,
            label: 'Guest',
            onTap: _handleGuestSignIn,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1F3E).withOpacity(0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFF2A5CFF).withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2A5CFF), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToSignUp(),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: const Color(0xFF2A5CFF),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS LOGIC
  // ============================================================

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        if (authProvider.needsProfileCompletion()) {
          _navigateToProfileSetup();
        } else {
          _navigateToDashboard();
        }
      } else if (mounted) {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Sign in failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    print('🟡 Google Sign-In button clicked');
    print('🟡 Platform: ${kIsWeb ? "Web" : "Mobile"}');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('🟢 Calling authProvider.signInWithGoogle()');

      final success = await authProvider.signInWithGoogle();
      print('🔵 Success result: $success');

      if (success && mounted) {
        print('🟣 Sign-in successful! Navigating to dashboard...');
        _navigateToDashboard();
      } else if (mounted) {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Google sign in failed';
        });
        print('🔴 Sign-in failed: ${authProvider.errorMessage}');
      }
    } catch (e) {
      print('❌ Google sign in error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInAsGuest();
      if (mounted) {
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive reset link'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.resetPassword(emailController.text);

              setState(() => _isLoading = false);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Reset link sent to your email'
                        : 'Failed to send reset link'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    print('🔵 Navigating to dashboard');
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _navigateToProfileSetup() {
    Navigator.pushReplacementNamed(context, '/profile-setup');
  }

  void _navigateToSignUp() {
    Navigator.pushReplacementNamed(context, '/signup');
  }
}