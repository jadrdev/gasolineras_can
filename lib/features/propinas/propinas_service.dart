import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Resultado de una propina, para que la hoja muestre el agradecimiento o el
/// aviso que toque.
enum ResultadoPropina { gracias, pendiente, cancelada, error }

/// «Invítame a un café»: propinas de pago único con el sistema de compras de
/// Apple y Google. Son productos consumibles (se pueden repetir) y no
/// desbloquean nada, así que no hace falta guardarlas en el servidor.
///
/// Los productos se crean en App Store Connect y Play Console con estos
/// identificadores (ver store/propinas.md).
class Propinas {
  Propinas._();

  /// Identificadores de producto, iguales en las dos tiendas.
  static const ids = {'propina_cafe', 'propina_cafe_dulce', 'propina_desayuno'};

  static InAppPurchase get _iap => InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _sub;
  static final _resultados = StreamController<ResultadoPropina>.broadcast();

  /// Avisa cada vez que termina una compra (o falla o se cancela).
  static Stream<ResultadoPropina> get resultados => _resultados.stream;

  /// Se llama al arrancar: escucha las compras desde el principio para cerrar
  /// las que se quedaran a medias (si no se cierran, la tienda las devuelve).
  static void init() {
    _sub ??= _iap.purchaseStream.listen(
      _alComprar,
      onError: (Object e) => debugPrint('⚠️ Propinas: $e'),
    );
  }

  /// Productos disponibles, de más barato a más caro. Vacío si la tienda no
  /// responde o los productos aún no están creados.
  static Future<List<ProductDetails>> productos() async {
    try {
      if (!await _iap.isAvailable()) return [];
      final respuesta = await _iap.queryProductDetails(ids);
      if (respuesta.notFoundIDs.isNotEmpty) {
        debugPrint(
          '⚠️ Propinas sin crear en la tienda: ${respuesta.notFoundIDs}',
        );
      }
      return respuesta.productDetails.toList()
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    } catch (e) {
      debugPrint('⚠️ Propinas: no se pudieron cargar: $e');
      return [];
    }
  }

  /// Abre el pago de la tienda. El resultado llega por [resultados].
  static Future<bool> comprar(ProductDetails producto) => _iap.buyConsumable(
    purchaseParam: PurchaseParam(productDetails: producto),
  );

  static Future<void> _alComprar(List<PurchaseDetails> compras) async {
    for (final compra in compras) {
      switch (compra.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _resultados.add(ResultadoPropina.gracias);
        case PurchaseStatus.pending:
          _resultados.add(ResultadoPropina.pendiente);
        case PurchaseStatus.canceled:
          _resultados.add(ResultadoPropina.cancelada);
        case PurchaseStatus.error:
          debugPrint('⚠️ Propina con error: ${compra.error}');
          _resultados.add(ResultadoPropina.error);
      }
      if (compra.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(compra);
        } catch (e) {
          debugPrint('⚠️ Propinas: no se pudo cerrar la compra: $e');
        }
      }
    }
  }
}
