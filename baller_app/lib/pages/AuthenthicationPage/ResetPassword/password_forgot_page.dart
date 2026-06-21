import 'package:baller_app/auth/auth_service.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:baller_app/pages/AuthenthicationPage/ResetPassword/reset_password_page.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final _authService = AuthService();

  void _showApiModeResetUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset is not available in API mode yet.'),
      ),
    );
  }

  void _openResetPasswordPage() {
    if (!AppConfig.useLegacySupabase) {
      _showApiModeResetUnavailable();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
    );
  }

  Future<void> _sendResetEmail() async {
    try {
      await _authService.resetPasswordForEmail(_emailController.text.trim());
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please check your email & spam directory for the token, if it's not in the Mailbox",
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: _openResetPasswordPage,
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    } on UnsupportedError {
      if (mounted) {
        _showApiModeResetUnavailable();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
        foregroundColor: Color.fromRGBO(231, 85, 39, 100),
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                controller: _emailController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Email',
                  labelStyle: const TextStyle(fontSize: 20),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(231, 85, 39, 100),
                    ),
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Color.fromRGBO(231, 85, 39, 100),
                    fontSize: 20,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.09,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(231, 85, 39, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      await _sendResetEmail();
                    } else {
                      null;
                    }
                  },
                  child: Center(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.03,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextButton(
                onPressed: () async {
                  _openResetPasswordPage();
                },
                child: Text(
                  'Do you already have a Token? Reset your Password',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenHeight * 0.02,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
