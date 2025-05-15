import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
