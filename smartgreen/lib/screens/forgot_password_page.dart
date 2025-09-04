// lib/screens/forgot_password_page.dart
import 'package:flutter/material.dart';
import '../services/user_repository.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordController {
  final UserRepository _repository;
  ForgotPasswordController(
    this._repository,
  );

  Future<
    String?
  >
  validateEmail(
    String email,
  ) async {
    return _repository.getUserIdByEmail(
      email,
    );
  }

  Future<
    void
  >
  changePassword(
    String userId,
    String newPassword,
  ) async {
    await _repository.updatePassword(
      userId,
      newPassword,
    );
  }
}

class ForgotPasswordPage
    extends
        StatefulWidget {
  const ForgotPasswordPage({
    super.key,
  });

  @override
  State<
    ForgotPasswordPage
  >
  createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends
        State<
          ForgotPasswordPage
        > {
  final _emailController =
      TextEditingController();
  final _newPasswordController =
      TextEditingController();
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _confirmPasswordController =
      TextEditingController();

  late final ForgotPasswordController _controller;

  bool _emailValidated =
      false;
  String? _userId;
  String? _errorMessage;
  bool _loading =
      false;
  bool _obscure =
      true;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController(
      UserRepository(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _emailValidator(
    String? value,
  ) {
    final v =
        (value ??
                '')
            .trim();
    if (v.isEmpty) return 'Digite um e-mail';
    final rx = RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    );
    if (!rx.hasMatch(
      v,
    )) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  String? _passwordValidator(
    String? value,
  ) {
    final v =
        value ??
        '';
    if (v.isEmpty) return 'Digite a nova senha';
    if (v.length <
        6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? _confirmPasswordValidator(
    String? value,
  ) {
    final v =
        value ??
        '';
    if (v.isEmpty) return 'Confirme a nova senha';
    if (v !=
        _newPasswordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  Future<
    void
  >
  _validateEmail() async {
    FocusScope.of(
      context,
    ).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(
      () {
        _loading =
            true;
        _errorMessage =
            null;
      },
    );

    try {
      final userId = await _controller.validateEmail(
        _emailController.text.trim(),
      );
      if (!mounted) return;

      if (userId !=
          null) {
        setState(
          () {
            _emailValidated =
                true;
            _userId =
                userId;
          },
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'E-mail validado!',
            ),
          ),
        );
      } else {
        setState(
          () =>
              _errorMessage =
                  'E-mail não encontrado.',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'E-mail não encontrado.',
            ),
          ),
        );
      }
    } catch (
      _
    ) {
      if (!mounted) return;
      setState(
        () =>
            _errorMessage =
                'Erro ao validar e-mail.',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro ao validar e-mail.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () =>
              _loading =
                  false,
        );
      }
    }
  }

  Future<
    void
  >
  _updatePassword() async {
    FocusScope.of(
      context,
    ).unfocus();

    if (_userId ==
        null) {
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    // Verifica se as senhas coincidem
    if (_newPasswordController.text !=
        _confirmPasswordController.text) {
      setState(
        () {
          _errorMessage =
              'As senhas não coincidem';
        },
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'As senhas não coincidem',
          ),
        ),
      );
      return;
    }

    setState(
      () {
        _loading =
            true;
        _errorMessage =
            null;
      },
    );

    try {
      await _controller.changePassword(
        _userId!,
        _newPasswordController.text,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Senha atualizada com sucesso!',
          ),
        ),
      );

      // Retorna para a tela de login após sucesso
      if (mounted) {
        Navigator.of(
          context,
        ).popUntil(
          (
            route,
          ) =>
              route.isFirst,
        );
      }
    } catch (
      _
    ) {
      if (!mounted) return;
      setState(
        () =>
            _errorMessage =
                'Erro ao atualizar a senha.',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro ao atualizar a senha.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () =>
              _loading =
                  false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    final cs =
        theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Esqueci minha senha',
        ),
        centerTitle:
            true,
        backgroundColor:
            cs.primary,
        foregroundColor:
            cs.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth:
                  420,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom:
                          16.0,
                    ),
                    child: Text(
                      'Informe seu e-mail cadastrado para validar sua identidade. Após a validação, você poderá definir uma nova senha.',
                      style:
                          theme.textTheme.bodyMedium,
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                  Form(
                    key:
                        _formKey,
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                    child: Card(
                      elevation:
                          theme.cardTheme.elevation ??
                          1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          16,
                        ),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            if (!_emailValidated) ...[
                              TextFormField(
                                controller:
                                    _emailController,
                                keyboardType:
                                    TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText:
                                      'E-mail',
                                ),
                                validator:
                                    _emailValidator,
                                enabled:
                                    !_loading,
                                textInputAction:
                                    TextInputAction.done,
                                onFieldSubmitted:
                                    (
                                      _,
                                    ) =>
                                        _validateEmail(),
                              ),
                              const SizedBox(
                                height:
                                    16,
                              ),
                              SizedBox(
                                width:
                                    double.infinity,
                                child: CustomButton(
                                  label:
                                      _loading
                                          ? 'Validando...'
                                          : 'Validar E-mail',
                                  icon:
                                      Icons.verified_user,
                                  onPressed:
                                      _loading
                                          ? null
                                          : _validateEmail,
                                  backgroundColor:
                                      cs.primary,
                                  textColor:
                                      cs.onPrimary,
                                ),
                              ),
                            ] else ...[
                              TextFormField(
                                controller:
                                    _newPasswordController,
                                decoration: InputDecoration(
                                  labelText:
                                      'Nova Senha',
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
                                              () {
                                                _obscure =
                                                    !_obscure;
                                              },
                                            ),
                                  ),
                                ),
                                obscureText:
                                    _obscure,
                                validator:
                                    _passwordValidator,
                                enabled:
                                    !_loading,
                                textInputAction:
                                    TextInputAction.next,
                              ),
                              const SizedBox(
                                height:
                                    16,
                              ),
                              TextFormField(
                                controller:
                                    _confirmPasswordController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Confirme a Nova Senha',
                                ),
                                obscureText:
                                    true,
                                validator:
                                    _confirmPasswordValidator,
                                enabled:
                                    !_loading,
                                textInputAction:
                                    TextInputAction.done,
                                onFieldSubmitted:
                                    (
                                      _,
                                    ) =>
                                        _updatePassword(),
                              ),
                              const SizedBox(
                                height:
                                    16,
                              ),
                              SizedBox(
                                width:
                                    double.infinity,
                                child: CustomButton(
                                  label:
                                      _loading
                                          ? 'Salvando...'
                                          : 'Alterar Senha',
                                  icon:
                                      Icons.lock_reset,
                                  onPressed:
                                      _loading
                                          ? null
                                          : _updatePassword,
                                  backgroundColor:
                                      cs.primary,
                                  textColor:
                                      cs.onPrimary,
                                ),
                              ),
                            ],
                            if (_errorMessage !=
                                null) ...[
                              const SizedBox(
                                height:
                                    16,
                              ),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color:
                                      cs.error,
                                ),
                                textAlign:
                                    TextAlign.center,
                              ),
                            ],
                          ],
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
    // ...duplicated widgets removidos, estrutura corrigida...
  }
}
