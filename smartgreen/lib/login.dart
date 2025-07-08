import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartgreen/globals.dart';
import 'package:smartgreen/homepage.dart';
import 'package:smartgreen/forgotPassword.dart';

// Serviço de autenticação orientado a objeto
class AuthService {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'Users',
  );

  String md5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final hashedPassword = md5Hash(password);
    final result =
        await users
            .where('email', isEqualTo: email.trim())
            .where('pass', isEqualTo: hashedPassword)
            .get();

    if (result.docs.isNotEmpty) {
      final doc = result.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'],
        'email': data['email'],
        'address': data['address'],
      };
    }
    return null;
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _tryLogin() async {
    try {
      final userData = await _authService.login(
        _emailCtrl.text,
        _passCtrl.text,
      );

      if (userData != null) {
        saveUserData(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          address: userData['address'],
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('e-mail ou senha inválidos.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao tentar fazer login.')),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 246, 242, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Image.asset('assets/smartgreen.png', height: 150)),
            SizedBox(height: 40),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
              child: Text(
                'Esqueceu a senha?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _tryLogin, child: Text('Entrar')),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(ctx, 'cadastro.dart'),
              child: Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}
