import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart'; // Asegúrate de importar correctamente

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  String _error = '';

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        if (userCredential.user != null) {
          try {
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(userCredential.user!.uid)
                .set({
              'email': email,
              'name': name,
              'fechaIngreso': DateTime.now().toIso8601String(),
            });
          } catch (firestoreError) {
            setState(() {
              _error =
                  "Error al guardar los datos en Firestore: $firestoreError";
            });
            return;
          }
        } else {
          setState(() {
            _error = "Error al crear el usuario.";
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Error desconocido';
      });
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.green[50],
      labelStyle: TextStyle(color: Colors.green[800]),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si el usuario ya está autenticado, redirigir al HomeScreen
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            // Usamos Future.microtask para evitar errores de navegación
            Future.microtask(() {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            });
            return const SizedBox(); // mientras navega
          }
        }

        // Mostrar la pantalla de login/registro
        return Scaffold(
          backgroundColor: Colors.green[50],
          appBar: AppBar(
            title: Text(
              _isLogin ? 'Iniciar Sesión' : 'Registrarse',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green[700],
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error.isNotEmpty)
                    Text(_error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  Text(
                    _isLogin ? 'Bienvenido de nuevo' : 'Crea tu cuenta',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/favicon.png',
                        height: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (!_isLogin)
                    TextField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Nombre'),
                    ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    decoration: _buildInputDecoration('Correo electrónico'),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    decoration: _buildInputDecoration('Contraseña'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.green[600],
                    ),
                    child: Text(
                      _isLogin ? 'Entrar' : 'Registrarse',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? '¿No tienes cuenta? Regístrate'
                          : '¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}





