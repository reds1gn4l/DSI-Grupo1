import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../globals.dart';
import '../homepage.dart';
import 'forgot_password_page.dart';
import 'user_registration_page.dart';

class LoginScreen
    extends
        StatefulWidget {
  @override
  _LoginScreenState createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends
        State<
          LoginScreen
        > {
  final _emailCtrl =
      TextEditingController();
  final _passCtrl =
      TextEditingController();
  final AuthService _authService =
      AuthService();

  Future<
    void
  >
  _tryLogin() async {
    try {
      final userData = await _authService.login(
        _emailCtrl.text,
        _passCtrl.text,
      );
      if (userData !=
          null) {
        saveUserData(
          id:
              userData['id'],
          name:
              userData['name'],
          email:
              userData['email'],
          address:
              userData['address'],
          isAdmin:
              userData['isAdmin'] ??
              false,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) =>
                    HomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'e-mail ou senha inválidos.',
            ),
          ),
        );
      }
    } catch (
      e
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro ao tentar fazer login.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext ctx,
  ) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(
        247,
        246,
        242,
        1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/smartgreen.png',
                height:
                    150,
              ),
            ),
            SizedBox(
              height:
                  40,
            ),
            TextField(
              controller:
                  _emailCtrl,
              decoration: InputDecoration(
                labelText:
                    'E-mail',
                border:
                    OutlineInputBorder(),
              ),
              keyboardType:
                  TextInputType.emailAddress,
            ),
            SizedBox(
              height:
                  16,
            ),
            TextField(
              controller:
                  _passCtrl,
              decoration: InputDecoration(
                labelText:
                    'Senha',
                border:
                    OutlineInputBorder(),
              ),
              obscureText:
                  true,
            ),
            SizedBox(
              height:
                  16,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          context,
                        ) =>
                            ForgotPasswordPage(),
                  ),
                );
              },
              child: Text(
                'Esqueceu a senha?',
                style: TextStyle(
                  color:
                      Colors.blue,
                ),
              ),
            ),
            SizedBox(
              height:
                  16,
            ),
            ElevatedButton(
              onPressed:
                  _tryLogin,
              child: Text(
                'Entrar',
              ),
            ),
            SizedBox(
              height:
                  16,
            ),
            OutlinedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) =>
                              UserRegistrationPage(),
                    ),
                  ),
              child: Text(
                'Criar conta',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
