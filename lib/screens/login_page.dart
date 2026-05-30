import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }
    if (!AuthService.isValidEmail(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }
    if (!AuthService.isValidPassword(password)) {
      _showMessage('Password must have at least 6 characters.');
      return;
    }

    _setLoading(true);
    try {
      await AuthService.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Sign in failed.');
    } catch (_) {
      _showMessage('Sign in failed.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _registerWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }
    if (!AuthService.isValidEmail(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }
    if (!AuthService.isValidPassword(password)) {
      _showMessage('Password must have at least 6 characters.');
      return;
    }

    _setLoading(true);
    try {
      await AuthService.registerWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Register failed.');
    } catch (_) {
      _showMessage('Register failed.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signInWithGoogle() async {
    _setLoading(true);
    try {
      await AuthService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Google sign-in failed.');
    } catch (_) {
      _showMessage('Google sign-in failed.');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Sign in to continue.'),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _signInWithEmail,
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isLoading ? null : _registerWithEmail,
              child: const Text('Create account'),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                SizedBox(width: 8),
                Text('OR'),
                SizedBox(width: 8),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
