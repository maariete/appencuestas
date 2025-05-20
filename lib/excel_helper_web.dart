import 'dart:convert';
import 'dart:html' as html;

Future<void> guardarRespuestasEnExcel(Map<String, dynamic> respuestas, String fileName) async {
  const storageKey = 'respuestas_csv';
  final buffer = StringBuffer();

  // Verifica si ya hay datos previos guardados localmente
  final previousData = html.window.localStorage[storageKey];
  if (previousData == null) {
    // Agrega encabezados solo la primera vez
    buffer.writeln('NOMBRE,POBLACIÓN,FECHA,WHATSAPP,EMAIL,${respuestas.keys.where((k) => !_isDatoPersonal(k)).join(",")}');
  } else {
    buffer.write(previousData);
  }

  // Agrega la nueva fila
  final fila = [
    respuestas['NOMBRE'] ?? '',
    respuestas['POBLACIÓN'] ?? '',
    respuestas['FECHA'] ?? '',
    respuestas['WHATSAPP'] ?? '',
    respuestas['EMAIL'] ?? '',
    ...respuestas.entries.where((e) => !_isDatoPersonal(e.key)).map((e) {
      if (e.value is List) {
        return '"${(e.value as List).join(", ")}"';
      }
      return '"${e.value.toString().replaceAll('"', '""')}"';
    })
  ].join(',');

  buffer.writeln(fila);

  // Guardar nuevamente en localStorage
  html.window.localStorage[storageKey] = buffer.toString();

  // Descargar CSV
  final bytes = utf8.encode(buffer.toString());
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
  ..setAttribute('download', '$fileName.csv') // USO CORRECTO DEL NOMBRE
  ..click();

  html.Url.revokeObjectUrl(url);

  print('✅ Datos agregados al CSV y descargado.');
}

bool _isDatoPersonal(String key) =>
    ['NOMBRE', 'POBLACIÓN', 'FECHA', 'WHATSAPP', 'EMAIL'].contains(key);