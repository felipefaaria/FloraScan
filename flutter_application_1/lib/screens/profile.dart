import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/welcome_screen.dart';
import './login_screen.dart';
import '../main.dart';
import './signup_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userProfession;
  final String email;
  final String phone;
  final Function(String, String, String, String) onUpdate;
  final String correctPassword;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userProfession,
    required this.email,
    required this.phone,
    required this.onUpdate,
    required this.correctPassword,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _professionController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _professionController = TextEditingController(text: widget.userProfession);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
  }

  void _saveChanges() {
    if (widget.correctPassword.isEmpty ||
        _passwordController.text == widget.correctPassword) {
      widget.onUpdate(
        _nameController.text,
        _professionController.text,
        _emailController.text,
        _phoneController.text,
      );
      setState(() {
        isEditing = false;
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = "Senha incorreta!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, size: 80, color: Color(0xFF4CAF50)),
              SizedBox(height: 20),
              Text(
                "Você está usando como convidado.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text("Fazer Login"),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SignUpScreen()),
                  );
                },
                child: Text("Cadastrar-se"),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Página de perfil",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (isEditing) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nome"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _professionController,
                decoration: InputDecoration(labelText: "Profissão"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Celular"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirme a senha"),
              ),
              if (errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveChanges, child: Text("Salvar")),
            ] else ...[
              Text("Nome: ${widget.userName}", style: TextStyle(fontSize: 18)),
              Text(
                "Profissão: ${widget.userProfession}",
                style: TextStyle(fontSize: 18),
              ),
              Text("Email: ${widget.email}", style: TextStyle(fontSize: 18)),
              Text("Celular: ${widget.phone}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => setState(() => isEditing = true),
                child: Text("Editar Informações"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutScreen()),
                  );
                },
                child: Text("Sobre o app"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => WelcomeScreen()),
                  );
                },
                child: Text("Sair"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sobre o app")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          """O Flora Scan é um aplicativo dedicado a ajudar entusiastas e profissionais a identificar, registrar e conhecer melhor as plantas ao seu redor. Desenvolvido com carinho, o app tem o objetivo de promover a conscientização ambiental, facilitar o estudo da flora local e ajudar em hobbies relacionados à plantação.

O app permite que os usuários tirem fotos de plantas e recebam informações gerais sobre elas. Além disso, o aplicativo oferece dicas de cuidados e informações sobre o habitat das plantas, tornando-se uma verdadeira ajuda para amantes da natureza.

Desenvolvido por:
FELIPE SILVA FARIA
HUGO ALVES DUARTE
MATHEUS HENRIQUE GONÇALVES
PEDRO HENRIQUE GAIOSO DE OLIVEIRA
""",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
