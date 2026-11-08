import '../models/gas_station.dart';

/// Normalize accents, punctuation and whitespace without changing displayed names.
String normalizeStationText(String text) {
  const accented = 'áàäâãåéèëêíìïîóòöôõúùüûñç';
  const plain = 'aaaaaaeeeeiiiiooooouuuunc';
  var result = text.toLowerCase();
  for (var i = 0; i < accented.length; i++) {
    result = result.replaceAll(accented[i], plain[i]);
  }
  return result
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

bool matchesStation(GasStation station, String query) {
  final words = normalizeStationText(
    query,
  ).split(' ').where((s) => s.isNotEmpty);
  final haystack = normalizeStationText(
    [
      station.nombre,
      station.marca,
      station.direccion,
      station.municipio,
      station.localidad,
      station.provincia,
    ].join(' '),
  );
  return words.every(haystack.contains);
}
