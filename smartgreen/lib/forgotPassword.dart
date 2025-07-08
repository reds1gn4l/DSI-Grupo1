import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserIdByEmail(String email) async {
    final query =
        await _firestore
            .collection('Users')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }

  Future<void> updatePassword(String userId, String newPassword) async {
    final hashedPassword = md5.convert(utf8.encode(newPassword.trim())).toString();
    await _firestore.collection('Users').doc(userId).update({
      'pass': hashedPassword,
    });
  }
}

class ForgotPasswordController {
  final UserRepository _repository;

  ForgotPasswordController(this._repository);

  Future<String?> validateEmail(String email) async {
    return await _repository.getUserIdByEmail(email);
  }

  Future<void> changePassword(String userId, String newPassword) async {
    await _repository.updatePassword(userId, newPassword);
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

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

  Future<void> _validateEmail() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final userId = await _controller.validateEmail(_emailController.text);
      if (userId != null) {
        setState(() {
          _emailValidated = true;
          _userId = userId;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('E-mail não encontrado.')));
        setState(() {
          _errorMessage = 'E-mail não encontrado.';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao validar e-mail.')));
      setState(() {
        _errorMessage = 'Erro ao validar e-mail.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
      );
      setState(() {
        _emailValidated = false;
        _emailController.clear();
        _newPasswordController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar a senha.')),
      );
      setState(() {
        _errorMessage = 'Erro ao atualizar a senha.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esqueci minha senha')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_emailValidated) ...[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Digite um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          _loading
                              ? null
                              : () {
                                if (_formKey.currentState!.validate()) {
                                  _validateEmail();
                                }
                              },
                      child:
                          _loading
                              ? const CircularProgressIndicator()
                              : const Text('Validar E-mail'),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Nova Senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          _loading
                              ? null
                              : () {
                                if (_formKey.currentState!.validate()) {
                                  _updatePassword();
                                }
                              },
                      child:
                          _loading
                              ? const CircularProgressIndicator()
                              : const Text('Alterar Senha'),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
