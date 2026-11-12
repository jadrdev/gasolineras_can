/// Si los números llevan punto decimal (inglés) en vez de coma (español,
/// alemán). Lo fija la app según el idioma con [usarIdiomaParaNumeros].
var _puntoDecimal = false;

/// Ajusta el separador decimal al idioma de la app ('en' usa punto).
void usarIdiomaParaNumeros(String languageCode) =>
    _puntoDecimal = languageCode == 'en';

/// Formato de números para mostrar en pantalla: coma decimal en español y
/// alemán (1,345 €/L), punto en inglés (1.345 €/L). Para leer lo que escribe
/// el usuario ya se acepta coma o punto.
String decimal(num value, int digits) {
  final texto = value.toStringAsFixed(digits);
  return _puntoDecimal ? texto : texto.replaceAll('.', ',');
}

/// Importe en euros: «66,50 €» en español y alemán, «€66.50» en inglés.
String euros(num value, int digits) => _puntoDecimal
    ? '€${decimal(value, digits)}'
    : '${decimal(value, digits)} €';

const _minusculas = {'de', 'del', 'y', 'e', 'en', 'a', 'al', 'por'};
// Artículos: en minúscula solo detrás de "de" (Avenida de los Álamos); en
// nombres de lugar van en mayúscula (Las Majoreras, La Cuesta).
const _articulos = {'la', 'las', 'el', 'los'};
final _romano = RegExp(r'^(i{1,3}|iv|v|vi{1,3}|ix|x{1,3})$');
final _vocal = RegExp('[aeiouáéíóúü]');

/// Pasa a formato normal los textos que el Ministerio da en mayúsculas
/// ("CALLE CARLOS V, S/N" → "Calle Carlos V, S/N"). Respeta siglas sin
/// vocales (BP), carreteras con números (GC-1, TF-5), números romanos y
/// S/N. Si el texto ya viene con mayúsculas y minúsculas se deja tal cual.
String nombrePropio(String text) {
  final letters = text.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
  final lower = letters.replaceAll(RegExp(r'[^\p{Ll}]', unicode: true), '');
  // Más de un 20 % de minúsculas: ya viene bien escrito.
  if (letters.isEmpty || lower.length * 5 > letters.length) return text;
  var first = true;
  var previous = '';
  return text.toLowerCase().replaceAllMapped(RegExp(r"[^\s,()·./-]+|[/-]"), (
    m,
  ) {
    final word = m[0]!;
    final isFirst = first;
    final before = previous;
    if (RegExp(r'\p{L}', unicode: true).hasMatch(word)) {
      first = false;
      previous = word;
    }
    if (word == 'km') return 'km';
    if (word == 's' && m.end < text.length && text[m.end] == '/') return 'S';
    if (word == 'n' && m.start > 0 && text[m.start - 1] == '/') return 'N';
    if (RegExp(r'\d').hasMatch(word) ||
        _romano.hasMatch(word) ||
        (word.length <= 3 && !_vocal.hasMatch(word))) {
      return word.toUpperCase();
    }
    if (!isFirst && _minusculas.contains(word)) return word;
    if (!isFirst && _articulos.contains(word) && (before == 'de')) return word;
    return word[0].toUpperCase() + word.substring(1);
  });
}
