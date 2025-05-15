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
import './screens/signup_screen.dart';
import './screens/welcome_screen.dart';
import './screens/profile.dart';
import './screens/login_screen.dart';
import './screens/initial_home.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FloraScan',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFFA5D6A7),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF2E7D32)),
          bodyMedium: TextStyle(color: Color(0xFF2E7D32)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2E7D32),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4CAF50),
            side: const BorderSide(color: Color(0xFF4CAF50)),
          ),
        ),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Ainda carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Usuário logado
        if (snapshot.hasData) {
          return HomeScreen(); // Exibe a tela principal com menu
        }

        // Não logado
        return WelcomeScreen(); // Tela inicial para login/cadastro
      },
    );
  }
}

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
              : Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                ), // margem maior no topo
                child: GridView.count(
                  crossAxisCount: 3,
                  children: List.generate(plantas.length, (index) {
                    final planta = plantas[index];
                    final imagemPath = planta['imagemPath'];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => FotoDetalhe(
                                planta: planta,
                                onPlantaExcluida: carregarPlantas,
                              ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // cinza claro
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ), // borda arredondada
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 7,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child:
                                    (imagemPath != null &&
                                            File(imagemPath).existsSync())
                                        ? Image.file(
                                          File(imagemPath),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                        : const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.black26,
                                            size: 40,
                                          ),
                                        ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  planta['nome'] ?? 'Sem nome',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
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
