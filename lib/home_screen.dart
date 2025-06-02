import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ AÑADIDO
import 'encuesta_habitos_compra.dart';
import 'package:app_encuestas/excel_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _idioma = 'es';

  void _descargarExcel(BuildContext context) async {
    TextEditingController _fileNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_idioma == 'es' ? 'Nombre del archivo Excel' : 'Excel file name'),
        content: TextField(
          controller: _fileNameController,
          decoration: InputDecoration(
            hintText: _idioma == 'es' ? 'Introduce el nombre del archivo' : 'Enter file name',
          ),
        ),
        actions: [
          TextButton(
            child: Text(_idioma == 'es' ? 'Cancelar' : 'Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(_idioma == 'es' ? 'Guardar' : 'Save'),
            onPressed: () async {
              Navigator.of(context).pop();
              String fileName = _fileNameController.text.isNotEmpty
                  ? _fileNameController.text
                  : 'resultados_encuesta';

              try {
                await guardarRespuestasEnExcel({}, fileName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_idioma == 'es'
                        ? '📄 Archivo Excel guardado como "$fileName.xlsx"'
                        : '📄 Excel file saved as "$fileName.xlsx"'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_idioma == 'es'
                        ? '❌ Error al guardar el archivo Excel: $e'
                        : '❌ Error saving Excel file: $e'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _cambiarIdioma() {
    setState(() {
      _idioma = _idioma == 'es' ? 'en' : 'es';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_idioma == 'es'
            ? '🌐 Idioma cambiado a Español'
            : '🌐 Language changed to English'),
      ),
    );
  }

  void _mostrarQR() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _idioma == 'es' ? 'Código QR de la aplicación' : 'App QR Code',
          style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
        ),
        content: Image.asset(
          'assets/qr_app.png',
          height: 200,
        ),
        actions: [
          TextButton(
            child: Text(_idioma == 'es' ? 'Cerrar' : 'Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    try {
      await FirebaseAuth.instance.signOut(); // ✅ Cierra sesión correctamente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_idioma == 'es'
              ? '🔒 Sesión cerrada'
              : '🔒 Logged out'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_idioma == 'es'
              ? '❌ Error al cerrar sesión: $e'
              : '❌ Error logging out: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'WOW Encuestas',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onSelected: (String value) {
              if (value == 'idioma') {
                _cambiarIdioma();
              } else if (value == 'descargar') {
                _descargarExcel(context);
              } else if (value == 'mostrar_qr') {
                _mostrarQR();
              } else if (value == 'cerrar_sesion') {
                _cerrarSesion(); // ✅ Esto ahora funciona correctamente
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'idioma',
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(_idioma == 'es' ? 'Cambiar idioma' : 'Change language'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'descargar',
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(_idioma == 'es'
                      ? 'Descargar archivo Excel'
                      : 'Download Excel file'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'mostrar_qr',
                child: ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text(_idioma == 'es'
                      ? 'Mostrar código QR'
                      : 'QR Code'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'cerrar_sesion',
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(_idioma == 'es' ? 'Cerrar sesión' : 'Log out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _idioma == 'es' ? 'Selecciona un tema' : 'Select a topic',
              style: GoogleFonts.raleway(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildQuizCard(
                    context,
                    _idioma == 'es' ? 'Hábitos de Compra' : 'Shopping Habits',
                    Icons.shopping_bag,
                    const Color(0xFF558B2F),
                    const EncuestaHabitosCompra(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}






