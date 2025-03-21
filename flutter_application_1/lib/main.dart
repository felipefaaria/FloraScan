import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(FloraScanApp());
}

class FloraScanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            Text("Flora Scan", style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Nome", border: OutlineInputBorder())),
            SizedBox(height: 10),

            TextField(controller: _professionController, decoration: InputDecoration(labelText: "Profissão", border: OutlineInputBorder())),
            SizedBox(height: 10),

            TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Celular", border: OutlineInputBorder())),
            SizedBox(height: 10),

            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder())),
            SizedBox(height: 10),

            TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: "Senha", border: OutlineInputBorder())),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      name: _nameController.text,
                      profession: _professionController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      password: _passwordController.text,
                    ),
                  ),
                );
              },
              child: Text("Continuar"),
            ),
          ],
        ),
      ),
    );
  }
}
class CameraScreen extends StatelessWidget {
  final VoidCallback onTakePhoto;

  CameraScreen({required this.onTakePhoto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 100),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onTakePhoto,
            child: Text("Tirar Foto"),
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final String? lastPhotoPath;

  DetailsScreen({this.lastPhotoPath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: lastPhotoPath == null
          ? Text("Nenhuma foto tirada ainda")
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(lastPhotoPath!, height: 200),
                SizedBox(height: 20),
                Text(
                  "Planta X",
                  style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
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

class HomeScreen extends StatefulWidget {
  String name;
  String profession;
  String email;
  String phone;
  final String password;

  HomeScreen({required this.name, required this.profession, required this.email, required this.phone, required this.password});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? lastPhotoPath;

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

  void updateUserInfo(String newName, String newProfession, String newEmail, String newPhone) {
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
      CameraScreen(onTakePhoto: _takePhoto),
      DetailsScreen(lastPhotoPath: lastPhotoPath),
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
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Foto"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Detalhes"),
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

  ProfileScreen({
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
    if (_passwordController.text == widget.correctPassword) {
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
            CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/profile.jpg')),
            SizedBox(height: 20),

            if (isEditing) ...[
              TextField(controller: _nameController, decoration: InputDecoration(labelText: "Nome")),
              SizedBox(height: 10),
              TextField(controller: _professionController, decoration: InputDecoration(labelText: "Profissão")),
              SizedBox(height: 10),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
              SizedBox(height: 10),
              TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Celular")),
              SizedBox(height: 10),
              TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: "Confirme a senha")),
              if (errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveChanges, child: Text("Salvar")),
            ] else ...[
              Text("Nome: ${widget.userName}", style: TextStyle(fontSize: 18)),
              Text("Profissão: ${widget.userProfession}", style: TextStyle(fontSize: 18)),
              Text("Email: ${widget.email}", style: TextStyle(fontSize: 18)),
              Text("Celular: ${widget.phone}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              OutlinedButton(onPressed: () => setState(() => isEditing = true), child: Text("Editar Informações")),
            ],
          ],
        ),
      ),
    );
  }
}
