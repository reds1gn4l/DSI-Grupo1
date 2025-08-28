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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
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
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(child: Image.asset('assets/smartgreen.png', height: 150)),
            const SizedBox(height: 32),

            // Nome
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome completo'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira seu nome completo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // E-mail
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Por favor, insira seu e-mail';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                  return 'Por favor, insira um e-mail válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Senha
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
              validator: (value) {
                final v = value ?? '';
                if (v.isEmpty) return 'Por favor, insira sua senha';
                if (v.length < 6) {
                  return 'Senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Repetir senha
            TextFormField(
              controller: _repeatPasswordController,
              decoration: const InputDecoration(labelText: 'Repetir senha'),
              obscureText: true,
              validator: (value) {
                final v = value ?? '';
                if (v.isEmpty) return 'Por favor, repita sua senha';
                if (v != _passwordController.text) {
                  return 'Senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Botão de ação (padrão do app)
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
    );
  }
}
