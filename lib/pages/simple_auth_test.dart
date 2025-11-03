import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SimpleAuthTest extends StatefulWidget {
  const SimpleAuthTest({super.key});

  @override
  State<SimpleAuthTest> createState() => _SimpleAuthTestState();
}

class _SimpleAuthTestState extends State<SimpleAuthTest> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  String _status = 'Ready to test';
  bool _isLoading = false;

  Future<void> _testEmailSignUp() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating account...';
    });

    try {
      final result = await AuthService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: 'Test User',
      );

      setState(() {
        _status = result != null
            ? 'SUCCESS: Account created! UID: ${result.user?.uid}'
            : 'FAILED: No result returned';
      });
    } catch (e) {
      setState(() {
        _status = 'ERROR: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testEmailSignIn() async {
    setState(() {
      _isLoading = true;
      _status = 'Signing in...';
    });

    try {
      final result = await AuthService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _status = result != null
            ? 'SUCCESS: Signed in! UID: ${result.user?.uid}'
            : 'FAILED: No result returned';
      });
    } catch (e) {
      setState(() {
        _status = 'ERROR: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Firebase Auth Test',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testEmailSignUp,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Sign Up'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testEmailSignIn,
              child: const Text('Test Sign In'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: TextStyle(
                      color: _status.startsWith('SUCCESS')
                          ? Colors.green
                          : _status.startsWith('ERROR')
                          ? Colors.red
                          : Colors.black,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (AuthService.currentUser != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current User:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('UID: ${AuthService.currentUser!.uid}'),
                    Text('Email: ${AuthService.currentUser!.email}'),
                    Text('Verified: ${AuthService.currentUser!.emailVerified}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await AuthService.signOut();
                        setState(() {
                          _status = 'Signed out';
                        });
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
