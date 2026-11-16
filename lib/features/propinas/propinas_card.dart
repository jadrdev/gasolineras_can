import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../l10n/l10n.dart';
import 'propinas_service.dart';

/// Tarjeta del perfil que abre «Invítame a un café».
class PropinasCard extends StatelessWidget {
  const PropinasCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_cafe_outlined),
        title: Text(l10n.tipCardTitle),
        subtitle: Text(l10n.tipCardSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const _PropinasSheet(),
        ),
      ),
    );
  }
}

class _PropinasSheet extends StatefulWidget {
  const _PropinasSheet();

  @override
  State<_PropinasSheet> createState() => _PropinasSheetState();
}

class _PropinasSheetState extends State<_PropinasSheet> {
  late final Future<List<ProductDetails>> _productos = Propinas.productos();
  late final StreamSubscription<ResultadoPropina> _sub;
  bool _comprando = false;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    _sub = Propinas.resultados.listen(_alTerminar);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _alTerminar(ResultadoPropina resultado) {
    if (!mounted) return;
    final l10n = context.l10n;
    switch (resultado) {
      case ResultadoPropina.gracias:
        final navigator = Navigator.of(context);
        navigator.pop();
        showDialog<void>(
          context: navigator.context,
          builder: (dialogContext) => AlertDialog(
            icon: const Text('☕', style: TextStyle(fontSize: 40)),
            title: Text(l10n.tipThanksTitle),
            content: Text(l10n.tipThanksBody, textAlign: TextAlign.center),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.tipClose),
              ),
            ],
          ),
        );
      case ResultadoPropina.pendiente:
        setState(() {
          _comprando = false;
          _aviso = l10n.tipPending;
        });
      case ResultadoPropina.cancelada:
        setState(() => _comprando = false);
      case ResultadoPropina.error:
        setState(() {
          _comprando = false;
          _aviso = l10n.tipError;
        });
    }
  }

  Future<void> _comprar(ProductDetails producto) async {
    setState(() {
      _comprando = true;
      _aviso = null;
    });
    try {
      await Propinas.comprar(producto);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _comprando = false;
        _aviso = context.l10n.tipError;
      });
    }
  }

  String _nombre(String id) {
    final l10n = context.l10n;
    return switch (id) {
      'propina_cafe' => '☕  ${l10n.tipCoffee}',
      'propina_cafe_dulce' => '🍰  ${l10n.tipCoffeeCake}',
      'propina_desayuno' => '🥐  ${l10n.tipBreakfast}',
      _ => id,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        // En iOS la barra inferior es nativa y se dibuja encima de Flutter:
        // se deja su hueco para que no tape el último botón.
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          defaultTargetPlatform == TargetPlatform.iOS ? 88 : 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.tipCardTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.tipSheetBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            FutureBuilder<List<ProductDetails>>(
              future: _productos,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final productos = snapshot.data ?? [];
                if (productos.isEmpty) {
                  return Text(
                    l10n.tipUnavailable,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final producto in productos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OutlinedButton(
                          onPressed: _comprando
                              ? null
                              : () => _comprar(producto),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _nombre(producto.id),
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                producto.price,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_comprando)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            if (_aviso != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _aviso!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
