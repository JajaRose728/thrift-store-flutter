// lib/pages/sign_in_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<SupabaseService>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // soft beige background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pink Banner Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF8FAB), // soft pink
                        Color(0xFFFAD9C1), // light beige-pink gradient
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    '𓇼 ⋆.˚ 𓆉 𓆝 𓆡⋆.˚ 𓇼reRun Store𓇼 ⋆.˚ 𓆉 𓆝 𓆡⋆.˚ 𓇼',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email, color: Color(0xFFD47C8D)), // muted pink icon
                            labelText: 'Email',
                            labelStyle: GoogleFonts.montserrat(color: Colors.grey[600]),
                            filled: true,
                            fillColor: const Color(0xFFFFF2E5), // soft beige fill
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passCtrl,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFFD47C8D)),
                            labelText: 'Password',
                            labelStyle: GoogleFonts.montserrat(color: Colors.grey[600]),
                            filled: true,
                            fillColor: const Color(0xFFFFF2E5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8FAB), // pink button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            onPressed: _loading
                                ? null
                                : () async {
                              setState(() => _loading = true);
                              await svc.signIn(
                                _emailCtrl.text.trim(),
                                _passCtrl.text.trim(),
                              );
                              setState(() => _loading = false);
                              if (svc.error == null) {
                                Navigator.pushReplacementNamed(context, '/items');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(svc.error!),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            child: _loading
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                                : Text(
                              'Sign In',
                              style: GoogleFonts.pacifico(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            'Don’t have an account? Sign Up',
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFFD47C8D), // pink text link
                            ),
                          ),
                        ),
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
}
