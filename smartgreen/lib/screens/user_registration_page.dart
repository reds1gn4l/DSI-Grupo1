// lib/screens/user_registration_page.dart
import 'package:flutter/material.dart';
import '../homepage.dart';
import '../globals.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_button.dart';

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});

  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _obscurePwd = true;
  bool _obscurePwd2 = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Por favor, insira seu nome completo';
    if (v.length < 3) return 'Informe ao menos 3 caracteres';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Por favor, insira seu e-mail';
    final emailRx = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRx.hasMatch(v)) return 'Por favor, insira um e-mail válido';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Por favor, insira sua senha';
    if (v.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
    return null;
  }

  String? _validateRepeatPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Por favor, repita sua senha';
    if (v != _passwordController.text) return 'Senhas não coincidem';
    return null;
  }

  Future<void> _submitForm() async {
    // Fecha o teclado
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = User.withMd5(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      isAdmin: false,
    );

    try {
      final userId = await _firestoreService.addUser(user);

      if (!mounted) return;

      saveUserData(
        id: userId,
        name: user.name,
        email: user.email,
        address: null,
        isAdmin: user.isAdmin,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao cadastrar usuário: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: theme.cardTheme.elevation ?? 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Image.asset(
                              'assets/smartgreen.png',
                              height: 110,
                            ),
                          ),
                        ),

                        // Nome completo
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome completo',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 12),

                        // E-mail
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 12),

                        // Senha
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscurePwd
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                              icon: Icon(
                                _obscurePwd
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () => setState(
                                        () => _obscurePwd = !_obscurePwd,
                                      ),
                            ),
                          ),
                          obscureText: _obscurePwd,
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 12),

                        // Repetir senha
                        TextFormField(
                          controller: _repeatPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Repetir senha',
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscurePwd2
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                              icon: Icon(
                                _obscurePwd2
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () => setState(
                                        () => _obscurePwd2 = !_obscurePwd2,
                                      ),
                            ),
                          ),
                          obscureText: _obscurePwd2,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitForm(),
                          validator: _validateRepeatPassword,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 20),

                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                              label: 'Cadastrar',
                              icon: Icons.person_add,
                              backgroundColor: cs.primary,
                              textColor: cs.onPrimary,
                              onPressed: _submitForm,
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
