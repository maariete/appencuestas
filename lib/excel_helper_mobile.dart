import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> guardarRespuestasEnExcel(Map<String, dynamic> respuestas) async {
  if (await Permission.storage.request().isDenied) return;

  final dir = await getExternalStorageDirectory();
  final path = '${dir!.path}/resultados_encuesta.xlsx';
  final file = File(path);

  Excel excel;
  Sheet sheet;

  if (await file.exists()) {
    // Leer archivo existente
    final bytes = await file.readAsBytes();
    excel = Excel.decodeBytes(bytes);
    sheet = excel['Respuestas'];
  } else {
    // Crear nuevo Excel
    excel = Excel.createExcel();
    sheet = excel['Respuestas'];
    sheet.appendRow(['NOMBRE', 'POBLACIÓN', 'FECHA', 'WHATSAPP', 'EMAIL', ...respuestas.keys]);
  }

  // Crear fila de datos
  final fila = [
    respuestas['NOMBRE'] ?? '',
    respuestas['POBLACIÓN'] ?? '',
    respuestas['FECHA'] ?? '',
    respuestas['WHATSAPP'] ?? '',
    respuestas['EMAIL'] ?? '',
    ...respuestas.entries.where((e) =>
        !['NOMBRE', 'POBLACIÓN', 'FECHA', 'WHATSAPP', 'EMAIL'].contains(e.key)).map((e) {
      if (e.value is List) {
        return (e.value as List).join(', ');
      }
      return e.value.toString();
    })
  ];

  sheet.appendRow(fila);

  final fileBytes = excel.encode();
  await file.writeAsBytes(fileBytes!);

  print('✅ Datos agregados al archivo Excel en: $path');
}

