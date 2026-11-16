import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';

import '../l10n/l10n.dart';

/// Ancho del marcador en puntos de pantalla. El dibujo se hace a 3x para que
/// se vea nítido; a 90 puntos se tapaban unos a otros.
const _markerWidth = 56.0;
const _drawScale = 3 * _markerWidth / 90;

/// Marcador en forma de bocadillo con un texto (el precio) dentro.
/// Lo usan el mapa de gasolineras y el de puntos de recarga.
Future<BitmapDescriptor> priceMarker(String text, Color color) async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder)..scale(_drawScale);
  const size = 90.0;
  final paint = Paint()..color = color;
  final borderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  final body = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, size, size * 0.65),
    const Radius.circular(12),
  );
  canvas.drawRRect(body, paint);
  canvas.drawRRect(body, borderPaint);

  final path = Path()
    ..moveTo(size * 0.35, size * 0.63)
    ..lineTo(size * 0.5, size)
    ..lineTo(size * 0.65, size * 0.63)
    ..close();
  canvas.drawPath(path, paint);
  canvas.drawPath(path, borderPaint);

  final textPainter =
      TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center)
        ..text = TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
  textPainter.layout(maxWidth: size - 8);
  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size * 0.65 - textPainter.height) / 2 - 2,
    ),
  );

  final picture = pictureRecorder.endRecording();
  final pixels = (size * _drawScale).round();
  final image = await picture.toImage(pixels, pixels);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final png = bytes!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return BitmapDescriptor.bytes(png, width: _markerWidth, height: _markerWidth);
}

/// Abre la ruta hasta un punto en la app de mapas: directamente si solo hay
/// una instalada, o dejando elegir si hay varias.
Future<void> launchDirections(
  BuildContext context, {
  required double latitude,
  required double longitude,
  required String title,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final maps = await MapLauncher.installedMaps;
    if (maps.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.stationNoMapsInstalled)),
      );
      return;
    }
    final destination = Coords(latitude, longitude);
    if (maps.length == 1) {
      await maps.first.showDirections(
        destination: destination,
        destinationTitle: title,
      );
      return;
    }
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.stationChooseMapApp,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...maps.map(
              (map) => ListTile(
                leading: Image.asset(
                  map.icon,
                  width: 40,
                  height: 40,
                  errorBuilder: (_, error, stack) => const Icon(Icons.map),
                ),
                title: Text(map.mapName),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await map.showDirections(
                    destination: destination,
                    destinationTitle: title,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.stationMapOpenError('$e'))),
    );
  }
}
