import 'dart:io';
import 'package:flutter_application_1/database/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o databaseFactory se for desktop
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FloraScanApp());
}

class FloraScanApp extends StatelessWidget {
  const FloraScanApp({super.key});

  Future<void> _initializeGuest() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeGuest(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tela de loading enquanto aguarda o login anônimo
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FloraScan',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Color(0xFF4CAF50),
            colorScheme: ColorScheme.light(
              primary: Color(0xFF4CAF50),
              secondary: Color(0xFFA5D6A7),
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF2E7D32)),
              bodyMedium: TextStyle(color: Color(0xFF2E7D32)),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF2E7D32),
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF4CAF50),
                side: BorderSide(color: Color(0xFF4CAF50)),
              ),
            ),
          ),
          home:
              HomeScreen(), // Você pode redirecionar para outra tela se quiser
        );
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco,
                size: 100,
                color: Color.fromARGB(255, 0, 141, 31),
              ),
              SizedBox(height: 20),
              Text(
                "Bem-vindo ao Flora Scan",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 141, 31),
                ),
              ),
              SizedBox(height: 30),
              OutlinedButton(
                child: Text("Login"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
              ),

              SizedBox(height: 10),
              OutlinedButton(
                child: Text("Cadastrar-se"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SignUpScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Flora Scan",
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            TextField(
              controller: _professionController,
              decoration: InputDecoration(
                labelText: "Profissão",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Celular",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                try {
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );

                  // Se cadastrou com sucesso, vai para HomeScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => HomeScreen(
                            name: _nameController.text,
                            profession: _professionController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            password: _passwordController.text,
                          ),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  String errorMsg = 'Erro ao cadastrar';
                  if (e.code == 'weak-password') {
                    errorMsg = 'A senha é muito fraca.';
                  } else if (e.code == 'email-already-in-use') {
                    errorMsg = 'Este e-mail já está em uso.';
                  } else if (e.code == 'invalid-email') {
                    errorMsg = 'E-mail inválido.';
                  }

                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text("Erro"),
                          content: Text(errorMsg),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                  );
                }
              },
              child: Text("Continuar"),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage;

  Future<void> _login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => HomeScreen(
                email: _emailController.text,
                password: _passwordController.text,
              ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'Usuário não encontrado.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Senha incorreta.';
        } else {
          errorMessage = 'Erro ao fazer login.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Entrar",
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Senha"),
            ),
            if (errorMessage != null) ...[
              SizedBox(height: 10),
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            ],
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text("Entrar")),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignUpScreen(),
                  ), // tela de cadastro
                );
              },
              child: Text("Criar conta"),
            ),
          ],
        ),
      ),
    );
  }
}

class InitialHomeScreen extends StatelessWidget {
  const InitialHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Ícone com cor verde
              Icon(
                Icons.local_florist,
                size: 100,
                color: Color.fromARGB(255, 0, 141, 31),
              ),
              SizedBox(height: 20),
              // ✅ Título em verde
              Text(
                "FloraScan",
                style: GoogleFonts.lato(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 141, 31),
                ),
              ),
              SizedBox(height: 10),
              // ✅ Subtítulo em verde escuro
              Text(
                "Identifique plantas e aprenda a cuidar delas com facilidade.",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, color: Color(0xFF2E7D32)),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyGardenScreen()),
                  );
                },
                icon: Icon(Icons.photo),
                label: Text("Meu Jardim"),
              ),
              SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  // Futuro: levar para dicas
                },
                icon: Icon(Icons.local_florist),
                label: Text("Dicas de Cuidados"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyGardenScreen extends StatelessWidget {
  const MyGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meu Jardim")),
      body: Center(
        child: Text(
          "Suas fotos de plantas aparecerão aqui.",
          style: GoogleFonts.lato(fontSize: 18),
        ),
      ),
    );
  }
}

/*
class CameraScreen extends StatelessWidget {
  final VoidCallback onTakePhoto;

  const CameraScreen({super.key, required this.onTakePhoto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 100),
          SizedBox(height: 20),
          ElevatedButton(onPressed: onTakePhoto, child: Text("Tirar Foto")),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final String? lastPhotoPath;

  const DetailsScreen({super.key, this.lastPhotoPath});

  @override
  Widget build(BuildContext context) {
    if (lastPhotoPath != null) {
      log("📸 Caminho da última foto: $lastPhotoPath");
    }
    return Center(
      child:
          lastPhotoPath == null
              ? Text("Nenhuma foto tirada ainda")
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(File(lastPhotoPath!), height: 200),
                  SizedBox(height: 20),
                  Text(
                    "Planta X",
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "🌿 Descrição: Lorem Ipsum\n📍 Habitat: Lorem Ipsum\n💧 Cuidados: Lorem Ipsum",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
    );
  }
}
*/

class HomeScreen extends StatefulWidget {
  String name;
  String profession;
  String email;
  String phone;
  final String password;

  HomeScreen({
    super.key,
    this.name = '', // Definindo valores padrão
    this.profession = '',
    this.email = '',
    this.phone = '',
    this.password = '', // Definindo valores padrão
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? lastPhotoPath;

  /*
  void _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        lastPhotoPath = photo.path;
        _currentIndex = 1;
      });
    }
  }
  */

  void updateUserInfo(
    String newName,
    String newProfession,
    String newEmail,
    String newPhone,
  ) {
    setState(() {
      widget.name = newName;
      widget.profession = newProfession;
      widget.email = newEmail;
      widget.phone = newPhone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Inicial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: "Fotos",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return InitialHomeScreen();
      case 1:
        return Grade(); // Certifique-se que `Grade` está funcionando
      case 2:
        return ProfileScreen(
          userName: widget.name,
          userProfession: widget.profession,
          email: widget.email,
          phone: widget.phone,
          onUpdate: updateUserInfo,
          correctPassword: widget.password,
        );
      default:
        return InitialHomeScreen();
    }
  }
}

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

class Grade extends StatefulWidget {
  const Grade({super.key});

  @override
  State<Grade> createState() => _GradeState();
}

class _GradeState extends State<Grade> {
  List<Map<String, dynamic>> plantas = [];

  @override
  void initState() {
    super.initState();
    carregarPlantas();
  }

  Future<void> carregarPlantas() async {
    try {
      final dados = await DB.instance.getPlantasComCategoria();
      setState(() {
        plantas = dados;
      });
    } catch (e) {
      print('❌ Erro ao carregar plantas: $e');
      setState(() {
        plantas = [];
      });
    }
  }

  Future<void> tirarFoto() async {
    final picker = ImagePicker();
    final XFile? novaFoto = await picker.pickImage(source: ImageSource.camera);
    if (novaFoto != null) {
      // Pede nome, descrição e cuidados da foto
      final resultado = await _pedirNomeDescricaoCuidadosDaFoto();
      if (resultado != null && resultado['nome'] != null) {
        try {
          await DB.instance.insertPlanta({
            'nome': resultado['nome']?.trim() ?? '',
            'descricao': resultado['descricao']?.trim() ?? '',
            'cuidados': resultado['cuidados']?.trim() ?? '',
            'imagemPath': novaFoto.path,
            'categoria_id': null,
          });
          await carregarPlantas(); // Recarrega a lista após a inserção
        } catch (e) {
          print('❌ Erro ao salvar planta: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Erro ao salvar planta.')));
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nome da planta é obrigatório.')),
          );
        }
      }
    }
  }

  Future<void> escolherImagemDaGaleria() async {
    final picker = ImagePicker();
    final XFile? imagemSelecionada = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imagemSelecionada != null) {
      final resultado = await _pedirNomeDescricaoCuidadosDaFoto();
      if (resultado != null && resultado['nome'] != null) {
        try {
          await DB.instance.insertPlanta({
            'nome': resultado['nome']?.trim() ?? '',
            'descricao': resultado['descricao']?.trim() ?? '',
            'cuidados': resultado['cuidados']?.trim() ?? '',
            'imagemPath': imagemSelecionada.path,
            'categoria_id': null,
          });
          await carregarPlantas(); // Atualiza a grade
        } catch (e) {
          print('❌ Erro ao salvar planta da galeria: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao salvar planta.')),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nome da planta é obrigatório.')),
          );
        }
      }
    }
  }

  // Função para pedir nome, descrição e cuidados da foto
  Future<Map<String, String?>?> _pedirNomeDescricaoCuidadosDaFoto() async {
    String nomeDigitado = '';
    String descricaoDigitada = '';
    String cuidadosDigitados = '';

    return showDialog<Map<String, String?>?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dados da Flor'),
          content: SingleChildScrollView(
            // Adicionado SingleChildScrollView
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  onChanged: (value) => nomeDigitado = value,
                  decoration: const InputDecoration(hintText: 'Nome da planta'),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => descricaoDigitada = value,
                  decoration: const InputDecoration(hintText: 'Descrição'),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => cuidadosDigitados = value,
                  decoration: const InputDecoration(hintText: 'Cuidados'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.of(context).pop({
                    'nome': nomeDigitado,
                    'descricao': descricaoDigitada,
                    'cuidados': cuidadosDigitados,
                  }),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: escolherImagemDaGaleria,
            backgroundColor: Colors.white,
            heroTag: 'galeria',
            child: const Icon(
              Icons.photo_library,
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: tirarFoto,
            backgroundColor: Colors.white,
            heroTag: 'camera',
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 32),
          ),
        ],
      ),
      body:
          plantas.isEmpty
              ? const Center(child: Text('Nenhuma foto tirada ainda :('))
              : GridView.count(
                crossAxisCount: 3,
                children: List.generate(plantas.length, (index) {
                  final planta = plantas[index];
                  final imagemPath = planta['imagemPath'];
                  return GestureDetector(
                    // Adicionado GestureDetector
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => FotoDetalhe(
                              planta: planta,
                              onPlantaExcluida: () {
                                // Chamado quando a planta é excluída no diálogo
                                carregarPlantas(); // Atualiza a lista
                              },
                            ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(color: Color(0xFF0B3B17)),
                      child: Column(
                        children: [
                          if (imagemPath != null &&
                              File(imagemPath).existsSync())
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: Image.file(
                                  File(imagemPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            const Expanded(
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              planta['nome'] ?? 'Sem nome',
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              planta['categoria_nome'] ?? 'Sem categoria',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
    );
  }
}

// Widget para exibir os detalhes da foto em um modal
class FotoDetalhe extends StatelessWidget {
  final Map<String, dynamic> planta;
  final VoidCallback onPlantaExcluida; // Callback para通知 atualização

  const FotoDetalhe({
    super.key,
    required this.planta,
    required this.onPlantaExcluida,
  });

  @override
  Widget build(BuildContext context) {
    final imagemPath = planta['imagemPath'];

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Adicionado para evitar overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  planta['nome'] ?? 'Sem nome',
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (imagemPath != null && File(imagemPath).existsSync())
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(imagemPath),
                      height: 200, // Altura fixa para a imagem no modal
                      width: 200, // Largura fixa
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                const Center(child: Icon(Icons.image_not_supported, size: 100)),
              const SizedBox(height: 10),
              Text(
                "🌿 Descrição:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(planta['descricao'] ?? 'Sem descrição'),
              const SizedBox(height: 10),
              Text(
                "💧 Cuidados:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(planta['cuidados'] ?? 'Sem cuidados'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fechar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // Excluir a planta do banco de dados
                      if (planta['id'] != null) {
                        // Verifique se o ID está presente
                        try {
                          await DB.instance.deletePlanta(planta['id']);
                          // Remover o item da lista e atualizar a grade.
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            onPlantaExcluida(); // Chama o callback
                          }
                        } catch (e) {
                          print('Erro ao excluir planta: $e');
                          // Mostrar mensagem de erro ao usuário (opcional)
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao excluir planta.'),
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
