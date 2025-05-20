import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> guardarRespuestasEnExcel(Map<String, dynamic> respuestas , String fileName) async {
  final status = await Permission.storage.request();
  if (!status.isGranted) return;

  final dir = await getExternalStorageDirectory();
  final path = '${dir!.path}/$fileName.xlsx'; // USO CORRECTO DEL NOMBRE
  final file = File(path);


  Excel excel;
  Sheet sheet;

  if (await file.exists()) {
    final bytes = await file.readAsBytes();
    excel = Excel.decodeBytes(bytes);
    sheet = excel['Respuestas'] ?? excel.sheets.values.first;
  } else {
    excel = Excel.createExcel();
    sheet = excel['Respuestas'];
    sheet.appendRow([
      'NOMBRE',
      'POBLACIÓN',
      'FECHA',
      'WHATSAPP',
      'EMAIL',
      ...respuestas.keys.where(_esPregunta)
    ]);
  }

  final fila = [
    respuestas['NOMBRE'] ?? '',
    respuestas['POBLACIÓN'] ?? '',
    respuestas['FECHA'] ?? '',
    respuestas['WHATSAPP'] ?? '',
    respuestas['EMAIL'] ?? '',
    ...respuestas.entries.where((e) => _esPregunta(e.key)).map((e) {
      if (e.value is List) return (e.value as List).join(', ');
      return e.value.toString();
    }),
  ];

  sheet.appendRow(fila);

  final fileBytes = excel.encode();
  await file.writeAsBytes(fileBytes!);

  print('✅ Datos guardados en Excel: $path');
}

bool _esPregunta(String key) =>
    !['NOMBRE', 'POBLACIÓN', 'FECHA', 'WHATSAPP', 'EMAIL'].contains(key);