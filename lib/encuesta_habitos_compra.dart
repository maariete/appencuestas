// encuesta_habitos_compra.dart
import 'package:flutter/material.dart';
import 'final_user_form.dart';

class EncuestaHabitosCompra extends StatefulWidget {
  const EncuestaHabitosCompra({super.key});

  @override
  State<EncuestaHabitosCompra> createState() => _EncuestaHabitosCompraState();
}

class _EncuestaHabitosCompraState extends State<EncuestaHabitosCompra> {
  int _currentIndex = 0;
  final Map<String, dynamic> _responses = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'type': 'single',
      'question': '¿Haces regalos o te regalas caprichos?',
      'options': ['SI', 'NO'],
    },
    {
      'type': 'single',
      'question': '¿Con qué frecuencia sueles realizar algún regalo?',
      'options': [
        'Una vez a la semana',
        'Una vez a la quincena',
        'Una vez al mes',
        'Una vez cada 6 meses',
        'Una vez al año',
        'Menos',
      ],
    },
    {
      'type': 'multiple',
      'question': '¿Cuánto te gastas de media por regalo? (respuesta múltiple)',
      'options': [
        'Menos de 15,00€',
        'Entre 15,01€-30€',
        'Entre 30,01€-50,00€',
        'Entre 50,01€-75,00€',
        'Entre 75,01€-120€',
        'Entre 120,01€-150,00€',
        'Entre 150,01€-200,00€',
        'Entre 200,01€-300,00€',
        'Más de 300€',
      ],
    },
    {
      'type': 'multiple',
      'question': '¿A quién sueles regalar? (respuesta múltiple)',
      'options': [
        'La Pareja',
        'Un Familiar',
        'Amigos',
        'Compromisos',
        'Autoregalarme',
        'La Mascota',
        'Otros',
      ],
    },
    {
      'type': 'limit2',
      'question': '¿Dónde sueles comprar tus regalos? (Dos respuestas 1ª y 2ª)',
      'options': [
        'Tienda tradicional',
        'Centro Comercial',
        'Amazon',
        'Otros en Internet',
      ],
    },
    {
      'type': 'multiple',
      'question': '¿Qué sueles comprar? (respuesta múltiple)',
      'options': [
        'Ropa',
        'Libros',
        'Cenas o Comidas',
        'Viajes',
        'Experiencias Varias (Entradas a Conciertos, Espectáculos)',
        'Colonias',
        'Productos de Deporte',
        'Productos oficiales/Marcas',
        'Otros',
      ],
    },
    {
      'type': 'text',
      'question': '¿Qué te gusta que te regalen?',
    },
    {
      'type': 'single',
      'question':
          '¿Pagarías un poco más si una empresa se encargara de suministrarte el regalo, para que este fuera diferente a lo visto hasta ahora, que no tuvieras que invertir tiempo en hacerlo, que estuvieras asesorad@ por un personal shopping, que estuviera bien empaquetado y que sorprendiera a la persona que recibe el regalo?',
      'options': ['SI', 'NO'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _questions.length) {
      return FinalUserForm(respuestas: _responses);
    }

    final current = _questions[_currentIndex];
    final question = current['question'];
    final type = current['type'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuesta de Hábitos de Compra'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregunta ${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            if (type == 'text')
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Escribe tu respuesta',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  _responses[question] = val;
                },
              )
            else
              ..._buildOptions(current),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final value = _responses[question];
                final isValid = (value != null && value.toString().isNotEmpty);

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor responde antes de continuar')),
                  );
                  return;
                }

                // Validar máximo 2 respuestas en pregunta "limit2"
                if (type == 'limit2' && (value as List).length != 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor selecciona exactamente 2 respuestas')),
                  );
                  return;
                }

                setState(() {
                  _currentIndex++;
                });
              },
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(Map<String, dynamic> current) {
    final question = current['question'];
    final options = current['options'] as List<String>;
    final type = current['type'];

    if (type == 'single') {
      return options
          .map((opt) => RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: _responses[question],
                onChanged: (val) {
                  setState(() {
                    _responses[question] = val;
                  });
                },
              ))
          .toList();
    } else if (type == 'multiple' || type == 'limit2') {
      final selected = _responses[question] as List<String>? ?? [];
      return options
          .map((opt) => CheckboxListTile(
                title: Text(opt),
                value: selected.contains(opt),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      if (type == 'limit2' && selected.length >= 2) return;
                      selected.add(opt);
                    } else {
                      selected.remove(opt);
                    }
                    _responses[question] = selected;
                  });
                },
              ))
          .toList();
    }

    return [const Text('Tipo de pregunta no soportado')];
  }
}
