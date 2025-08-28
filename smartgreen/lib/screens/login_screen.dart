// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../globals.dart';
import '../homepage.dart';
import 'forgot_password_page.dart';
import 'user_registration_page.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final userData = await _authService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );

      if (!mounted) return;

      if (userData != null) {
        saveUserData(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          address: userData['address'],
          isAdmin: userData['isAdmin'] ?? false,
        );
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail ou senha inválidos.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao tentar fazer login.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _emailValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Digite seu e-mail';
    if (!s.contains('@') || !s.contains('.')) return 'Digite um e-mail válido';
    return null;
  }

  String? _passwordValidator(String? v) {
    if ((v ?? '').isEmpty) return 'Digite sua senha';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // usa scaffoldBackgroundColor do tema (definido no main)
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Image.asset('assets/smartgreen.png', height: 120),
                  ),

                  // Card do formulário
                  Card(
                    elevation: theme.cardTheme.elevation ?? 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                              ),
                              validator: _emailValidator,
                              enabled: !_loading,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _tryLogin(),
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                suffixIcon: IconButton(
                                  tooltip:
                                      _obscure
                                          ? 'Mostrar senha'
                                          : 'Ocultar senha',
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed:
                                      _loading
                                          ? null
                                          : () => setState(
                                            () => _obscure = !_obscure,
                                          ),
                                ),
                              ),
                              validator: _passwordValidator,
                              enabled: !_loading,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                    _loading
                                        ? null
                                        : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const ForgotPasswordPage(),
                                            ),
                                          );
                                        },
                                child: const Text('Esqueceu a senha?'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                label: _loading ? 'Entrando...' : 'Entrar',
                                icon: Icons.login,
                                onPressed: _loading ? null : _tryLogin,
                                backgroundColor: cs.primary,
                                textColor: cs.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Criar conta
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed:
                          _loading
                              ? null
                              : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const UserRegistrationPage(),
                                  ),
                                );
                              },
                      child: const Text('Criar conta'),
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
