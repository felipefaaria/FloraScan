import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(FloraScanApp());
}

class FloraScanApp extends StatelessWidget {
  const FloraScanApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: WelcomeScreen(),
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
              Icon(Icons.eco, size: 100, color: Color(0xFFB0B0B0)),
              SizedBox(height: 20),
              Text(
                "Bem-vindo ao Flora Scan",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB0B0B0),
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
              Icon(Icons.local_florist, size: 100, color: Color(0xFFB0B0B0)),
              SizedBox(height: 20),
              Text(
                "FloraScan",
                style: GoogleFonts.lato(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB0B0B0),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Identifique plantas e aprenda a cuidar delas com facilidade.",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, color: Color(0xFFB0B0B0)),
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
    List<Widget> pages = [
      // Tela inicial com os componentes de InitialHomeScreen
      Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_florist, size: 100, color: Color(0xFFB0B0B0)),
                SizedBox(height: 20),
                Text(
                  "FloraScan",
                  style: GoogleFonts.lato(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Identifique plantas e aprenda a cuidar delas com facilidade.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Color(0xFFB0B0B0),
                  ),
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
      ),
      Grade(), //Grade adicionada!
      //CameraScreen(onTakePhoto: _takePhoto),
      //DetailsScreen(lastPhotoPath: lastPhotoPath),
      ProfileScreen(
        userName: widget.name,
        userProfession: widget.profession,
        email: widget.email,
        phone: widget.phone,
        onUpdate: updateUserInfo,
        correctPassword: widget.password,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Inicial",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Foto"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
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
    // Cadastro novo ou edição
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
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
  final List<FotoComNome> fotos = [];

  Future<void> tirarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? novaFoto = await picker.pickImage(source: ImageSource.camera);

    if (novaFoto != null) {
      String? nome = await _pedirNomeDaFoto();
      if (nome != null && nome.trim().isNotEmpty) {
        setState(() {
          fotos.add(FotoComNome(foto: novaFoto, nome: nome.trim()));
        });
      }
    }
  }

  Future<String?> _pedirNomeDaFoto() async {
    String nomeDigitado = '';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nome da Flor'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => nomeDigitado = value,
            decoration: const InputDecoration(hintText: 'Digite um nome'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(nomeDigitado);
              },
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
      floatingActionButton: FloatingActionButton(
        onPressed: tirarFoto,
        backgroundColor: Colors.white,
        child: const Icon(Icons.camera_alt, color: Colors.black, size: 32),
      ),
      body:
          fotos.isEmpty
              ? const Center(
                child: Text(
                  'Nenhuma foto tirada ainda :(',
                  //style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              )
              : GridView.count(
                crossAxisCount: 3,
                children: List.generate(fotos.length, (index) {
                  final foto = fotos[index];
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      /*
                      ! bordas visíveis
                      border: Border.all(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                      */
                      color: Color(0xFF0B3B17),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => FotoDetalhe(foto: foto),
                                  ),
                                );
                              },
                              child:
                                  kIsWeb
                                      ? Image.network(
                                        foto.foto.path,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.file(
                                        File(foto.foto.path),
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            foto.nome,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
    );
  }
}

class FotoComNome {
  final XFile foto;
  final String nome;

  FotoComNome({required this.foto, required this.nome});
}

class FotoDetalhe extends StatelessWidget {
  final FotoComNome foto;

  const FotoDetalhe({super.key, required this.foto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foto.nome),
        backgroundColor: const Color(0xFF0B3B17),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*
            ! Problemas com tamanho da foto
            kIsWeb
                ? Image.network(foto.foto.path)
                : Image.file(File(foto.foto.path)),
            */
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
      ),
    );
  }
}
