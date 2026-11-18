import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/l10n.dart';
import 'colaborador.dart';
import 'propinas_service.dart';

/// Tarjeta del perfil que abre «Invítame a un café». A quien ya ha dado una
/// propina le da las gracias y le lleva a cambiar el icono.
class PropinasCard extends StatelessWidget {
  const PropinasCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ValueListenableBuilder<bool>(
      valueListenable: Colaborador.activo,
      builder: (context, colaborador, _) => Card(
        child: ListTile(
          leading: Icon(
            colaborador ? Icons.local_cafe : Icons.local_cafe_outlined,
          ),
          title: Text(
            colaborador ? l10n.tipCardTitleThanks : l10n.tipCardTitle,
          ),
          subtitle: Text(
            colaborador ? l10n.tipCardSubtitleThanks : l10n.tipCardSubtitle,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => const _PropinasSheet(),
          ),
        ),
      ),
    );
  }
}

/// Insignia «☕ Colaborador» para la cabecera del perfil.
class InsigniaColaborador extends StatelessWidget {
  const InsigniaColaborador({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Colaborador.activo,
      builder: (context, colaborador, _) {
        if (!colaborador) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '☕  ${context.l10n.tipBadge}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
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
  IconoApp? _icono;
  bool _comprando = false;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    _sub = Propinas.resultados.listen(_alTerminar);
    Colaborador.iconoActual().then((icono) {
      if (mounted) setState(() => _icono = icono);
    });
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
        // La hoja se queda abierta para que pueda elegir icono ya mismo.
        setState(() {
          _comprando = false;
          _aviso = null;
        });
        showDialog<void>(
          context: context,
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

  Future<void> _elegirIcono(IconoApp icono) async {
    if (icono == _icono) return;
    final anterior = _icono;
    setState(() => _icono = icono);
    final ok = await Colaborador.cambiarIcono(icono);
    if (!mounted || ok) return;
    setState(() {
      _icono = anterior;
      _aviso = context.l10n.tipIconError;
    });
  }

  String _nombreProducto(String id) {
    final l10n = context.l10n;
    return switch (id) {
      'propina_cafe' => '☕  ${l10n.tipCoffee}',
      'propina_cafe_dulce' => '🍰  ${l10n.tipCoffeeCake}',
      'propina_desayuno' => '🥐  ${l10n.tipBreakfast}',
      _ => id,
    };
  }

  String _nombreIcono(IconoApp icono) {
    final l10n = context.l10n;
    return switch (icono) {
      IconoApp.original => l10n.tipIconOriginal,
      IconoApp.noche => l10n.tipIconNight,
      IconoApp.naranja => l10n.tipIconOrange,
      IconoApp.cafe => l10n.tipIconCoffee,
    };
  }

  Widget _iconos(bool colaborador) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.tipIconsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final icono in IconoApp.values)
              _IconoOpcion(
                asset: icono.asset,
                nombre: _nombreIcono(icono),
                elegido: colaborador && icono == _icono,
                bloqueado: !colaborador,
                onTap: colaborador ? () => _elegirIcono(icono) : null,
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (!colaborador)
          Text(l10n.tipIconsLocked, style: theme.textTheme.bodySmall)
        else if (Supabase.instance.client.auth.currentUser == null)
          Text(l10n.tipLoginHint, style: theme.textTheme.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        // En iOS la barra inferior es nativa y se dibuja encima de Flutter:
        // se deja su hueco para que no tape el último botón.
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          defaultTargetPlatform == TargetPlatform.iOS ? 88 : 24,
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: Colaborador.activo,
          builder: (context, colaborador, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                colaborador ? l10n.tipCardTitleThanks : l10n.tipCardTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.tipSheetBody, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              _iconos(colaborador),
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
                                    _nombreProducto(producto.id),
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
      ),
    );
  }
}

class _IconoOpcion extends StatelessWidget {
  const _IconoOpcion({
    required this.asset,
    required this.nombre,
    required this.elegido,
    required this.bloqueado,
    required this.onTap,
  });

  final String asset;
  final String nombre;
  final bool elegido;
  final bool bloqueado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: elegido ? colors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Opacity(
                  opacity: bloqueado ? 0.45 : 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(asset, width: 60, height: 60),
                  ),
                ),
              ),
              if (bloqueado)
                const Icon(Icons.lock, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Text(nombre, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
