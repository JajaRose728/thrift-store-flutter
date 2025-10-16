// lib/pages/sign_up_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<SupabaseService>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // soft beige background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🌸 Gradient Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF8FAB), // soft pink
                        Color(0xFFFAD9C1), // light beige-pink
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
                    '𓇼 ⋆.˚ 𓆉 Create Account 𓆉 ⋆.˚ 𓇼',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pacifico( // 🌷 changed header font for style
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Card Section
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
                        // Display Name
                        TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person, color: Color(0xFFD47C8D)),
                            labelText: 'Name',
                            labelStyle: GoogleFonts.montserrat(color: Colors.grey[600]),
                            filled: true,
                            fillColor: const Color(0xFFFFF2E5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email, color: Color(0xFFD47C8D)),
                            labelText: 'Email',
                            labelStyle: GoogleFonts.montserrat(color: Colors.grey[600]),
                            filled: true,
                            fillColor: const Color(0xFFFFF2E5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Password
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

                        // 🌸 Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8FAB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            onPressed: _loading
                                ? null
                                : () async {
                              final name = _nameCtrl.text.trim();
                              final email = _emailCtrl.text.trim();
                              final pass = _passCtrl.text;
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enter name')),
                                );
                                return;
                              }
                              if (email.isEmpty || pass.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email & password required')),
                                );
                                return;
                              }
                              setState(() => _loading = true);
                              final ok = await svc.signUp(email, pass, name);
                              setState(() => _loading = false);
                              if (ok) Navigator.pushReplacementNamed(context, '/signin');
                            },
                            child: _loading
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                                : Text(
                              'Sign Up',
                              style: GoogleFonts.pacifico( // 💗 use a different clean font here
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Error Message
                        Consumer<SupabaseService>(
                          builder: (_, svc, __) => svc.error != null
                              ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              svc.error!,
                              style: GoogleFonts.robotoMono( // ⚠️ monospace red text for clarity
                                color: Colors.redAccent,
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🌷 Footer link
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signin'),
                  child: Text(
                    'Already have an account? Sign In',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD47C8D),
                      fontWeight: FontWeight.w500,
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
