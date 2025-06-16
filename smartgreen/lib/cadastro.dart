// Páginas de cadastro de usuário e endereço. Adicionei tudo em um único arquivo pois ambos estão relacionados ao cadastro de informações.

import 'package:flutter/material.dart';
import 'package:smartgreen/homepage.dart';

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Registrar Endereço'),
              content: Text('Você quer registrar o seu endereço?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle "No" action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Usuário não registrou o endereço.'),
                      ),
                    );
                  },
                  child: Text('Agora não'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle "Yes" action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressRegistrationPage(),
                      ),
                    );
                  },
                  child: Text('Sim'),
                ),
              ],
            ),
      );
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
              // Logo
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

                  // Regex para e-mail. "^" = começo da string regex, "[^@]+" = qualquer caractere que não seja @, "@" = caractere @, "[^@]+" = qualquer caractere que não seja @, "\." = caractere ponto ".", "[^@]+" = qualquer caractere que não seja @, "$" = final da string regex.
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
                  labelText: 'Repitar senha',
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
              ElevatedButton(onPressed: _submitForm, child: Text('Cadastrar')),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressRegistrationPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  AddressRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 246, 242, 1),
      appBar: AppBar(title: Text('Cadastro de Endereço')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu CEP';
                  }
                  // Regex para CEP. "\d{5}" = 5 dígitos, "-?" = opcional hífen, "\d{3}" = 3 dígitos, "^$" = começo e final da string regex, respectivamente.
                  if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(value)) {
                    return 'Por favor, insira um CEP válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu endereço';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _address2Controller,
                decoration: InputDecoration(
                  labelText: 'Complemento',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua cidade';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu estado';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('Finalizar Cadastro'),
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
