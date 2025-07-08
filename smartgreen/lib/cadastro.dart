import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgreen/homepage.dart';
import 'package:smartgreen/globals.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// MODELS

class UserModel {
  final String name;
  final String email;
  final String password; // será armazenado como hash

  UserModel({required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'pass': password};
  }

  // Função utilitária para criar UserModel com senha em md5
  factory UserModel.withMd5({required String name, required String email, required String password}) {
    final bytes = utf8.encode(password);
    final hash = md5.convert(bytes).toString();
    return UserModel(name: name, email: email, password: hash);
  }
}

// SERVICES

class FirestoreService {
  final FirebaseFirestore users = FirebaseFirestore.instance;

  Future<String> addUser(UserModel user) async {
    DocumentReference doc = await users.collection('Users').add(user.toMap());
    return doc.id;
  }
}

// UI

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});

  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      UserModel user = UserModel.withMd5(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      try {
        String userId = await _firestoreService.addUser(user);
        // Atualiza os dados locais do usuário autenticado
        saveUserData(
          id: userId,
          name: user.name,
          email: user.email,
          address: null, // Adapte se houver campo de endereço
        );
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar usuário: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: Image.asset('assets/smartgreen.png', height: 150)),
              SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome completo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _repeatPasswordController,
                decoration: InputDecoration(
                  labelText: 'Repetir senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, repita sua senha';
                  }
                  if (value != _passwordController.text) {
                    return 'Senhas não coincidem';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Cadastrar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: UserRegistrationPage()));
}
