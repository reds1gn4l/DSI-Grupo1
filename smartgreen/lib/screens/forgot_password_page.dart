// lib/screens/forgot_password_page.dart
import 'package:flutter/material.dart';
import '../services/user_repository.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordController {
  final UserRepository _repository;
  ForgotPasswordController(this._repository);

  Future<String?> validateEmail(String email) async {
    return _repository.getUserIdByEmail(email);
  }

  Future<void> changePassword(String userId, String newPassword) async {
    await _repository.updatePassword(userId, newPassword);
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _emailValidated = false;
  String? _userId;
  String? _errorMessage;
  bool _loading = false;

  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController(UserRepository());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateEmail() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final userId = await _controller.validateEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (userId != null) {
        setState(() {
          _emailValidated = true;
          _userId = userId;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('E-mail validado!')));
      } else {
        setState(() => _errorMessage = 'E-mail não encontrado.');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('E-mail não encontrado.')));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao validar e-mail.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao validar e-mail.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_userId == null) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _controller.changePassword(_userId!, _newPasswordController.text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
      );

      setState(() {
        _emailValidated = false;
        _userId = null;
        _emailController.clear();
        _newPasswordController.clear();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao atualizar a senha.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar a senha.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _emailValidator(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Digite um e-mail';
    // validação simples; se quiser, troque por RegExp mais completa
    if (!v.contains('@') || !v.contains('.')) return 'Digite um e-mail válido';
    return null;
  }

  String? _passwordValidator(String? value) {
    final v = value ?? '';
    if (v.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Esqueci minha senha'),
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: theme.cardTheme.elevation ?? 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_emailValidated) ...[
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                            ),
                            validator: _emailValidator,
                            enabled: !_loading,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label:
                                  _loading ? 'Validando...' : 'Validar E-mail',
                              icon: Icons.verified_user,
                              onPressed:
                                  _loading
                                      ? null
                                      : () {
                                        if (_formKey.currentState!.validate()) {
                                          _validateEmail();
                                        }
                                      },
                              backgroundColor: cs.primary,
                              textColor: cs.onPrimary,
                            ),
                          ),
                        ] else ...[
                          TextFormField(
                            controller: _newPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Nova Senha',
                            ),
                            obscureText: true,
                            validator: _passwordValidator,
                            enabled: !_loading,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label: _loading ? 'Salvando...' : 'Alterar Senha',
                              icon: Icons.lock_reset,
                              onPressed:
                                  _loading
                                      ? null
                                      : () {
                                        if (_formKey.currentState!.validate()) {
                                          _updatePassword();
                                        }
                                      },
                              backgroundColor: cs.primary,
                              textColor: cs.onPrimary,
                            ),
                          ),
                        ],
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: cs.error),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
