import 'package:flutter_test/flutter_test.dart';
import 'package:gasolineras_can/core/format.dart';

void main() {
  test('decimal usa coma', () {
    expect(decimal(1.345, 3), '1,345');
    expect(decimal(67.25, 2), '67,25');
    expect(decimal(50, 0), '50');
  });

  test('decimal usa punto en inglés y coma en alemán', () {
    usarIdiomaParaNumeros('en');
    expect(decimal(1.345, 3), '1.345');
    usarIdiomaParaNumeros('de');
    expect(decimal(1.345, 3), '1,345');
    usarIdiomaParaNumeros('es');
  });

  test('nombrePropio pasa a formato normal los textos en mayúsculas', () {
    const casos = {
      'DISA CARRIZAL': 'Disa Carrizal',
      'CARLOS V (INGENIO km 1)': 'Carlos V (Ingenio km 1)',
      'CALLE ÁNGEL GUIMERA, S/N': 'Calle Ángel Guimera, S/N',
      'BP LA CUESTA': 'BP La Cuesta',
      'CARRETERA GC-1 KM 23,5': 'Carretera GC-1 km 23,5',
      'AVENIDA DE LOS ÁLAMOS, 10': 'Avenida de los Álamos, 10',
      'San Cristóbal de La Laguna': 'San Cristóbal de La Laguna',
      '': '',
    };
    casos.forEach((entrada, salida) {
      expect(nombrePropio(entrada), salida, reason: entrada);
    });
  });
}
