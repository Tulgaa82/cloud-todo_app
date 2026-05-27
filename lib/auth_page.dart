import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'todo_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await GoogleSignIn.instance.initialize();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw Exception('idToken авах боломжгүй байна');
      }
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: null,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TodoPage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Алдаа: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4285F4), Color(0xFF1A73E8)],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 72, color: Color(0xFF4285F4)),
                  const SizedBox(height: 16),
                  const Text(
                    'Cloud Todo',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gmail хаягаар нэвтэрнэ үү',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 240,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => signInWithGoogle(context),
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF202124),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFFDADCE0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}