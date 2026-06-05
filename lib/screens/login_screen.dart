// screens/login_screen.dart
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../validators/app_validator.dart';
import '../utils/app_theme.dart';
import 'registration_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;
  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await widget.authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.authController.setRememberMe(_rememberMe);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(authController: widget.authController),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.authController.errorMessage ?? 'Login failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Logo / Icon area
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      size: 36, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 28),

              Text('Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text('Sign in to your account to continue',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 36),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Email Address'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: AppValidator.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    _label('Password'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (val) => AppValidator.validateRequired(
                          val, 'Password'),
                    ),
                    const SizedBox(height: 12),

                    // Remember Me
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (val) =>
                              setState(() => _rememberMe = val ?? false),
                        ),
                        const Text('Remember me',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(
                    onPressed: () {
                      widget.authController.resetState();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RegistrationScreen(
                            authController: widget.authController),
                      ));
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
