import 'package:flutter/material.dart';
import 'agradecimiento_screen.dart';
import 'excel_helper.dart';

class FinalUserForm extends StatefulWidget {
  final Map<String, dynamic> respuestas;

  const FinalUserForm({super.key, required this.respuestas});

  @override
  State<FinalUserForm> createState() => _FinalUserFormState();
}

class _FinalUserFormState extends State<FinalUserForm> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String poblacion = '';
  String fecha = '';
  String whatsapp = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del Participante'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('NOMBRE', (val) => nombre = val),
              _buildTextField('POBLACIÓN', (val) => poblacion = val),
              _buildTextField('FECHA', (val) => fecha = val),
              _buildTextField('WHATSAPP', (val) => whatsapp = val),
              _buildTextField('EMAIL', (val) => email = val),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final Map<String, dynamic> todasLasRespuestas = {
                      ...widget.respuestas,
                      'NOMBRE': nombre,
                      'POBLACIÓN': poblacion,
                      'FECHA': fecha,
                      'WHATSAPP': whatsapp,
                      'EMAIL': email,
                    };

                    await guardarRespuestasEnExcel(todasLasRespuestas , "nombre-personalizado");

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AgradecimientoScreen()),
                    );
                  }
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
        onChanged: onChanged,
      ),
    );
  }
}

