import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key, this.firstLaunch = false});

  /// Clave de SharedPreferences que indica que la guía ya se ha visto.
  static const seenKey = 'guide_seen_v1';

  final bool firstLaunch;

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final _controller = PageController();
  int _index = 0;

  static const _steps = <_GuideStep>[
    _GuideStep(
      icon: Icons.search,
      title: 'Encuentra gasolineras',
      description:
          'Busca por nombre, marca o municipio. Puedes explorar Canarias aunque no compartas tu ubicación.',
      color: Color(0xff087be8),
    ),
    _GuideStep(
      icon: Icons.price_check,
      title: 'Compara precios',
      description:
          'Consulta los precios por tipo de combustible y fíjate en la fecha de actualización para saber cuándo se comunicaron.',
      color: Color(0xff16855b),
    ),
    _GuideStep(
      icon: Icons.map_outlined,
      title: 'Elige cómo llegar',
      description:
          'Cambia entre lista y mapa para situar las estaciones. En la ficha, toca “Cómo llegar” para abrir una app de navegación.',
      color: Color(0xff8056c7),
    ),
    _GuideStep(
      icon: Icons.star_outline,
      title: 'Guarda tus preferidas',
      description:
          'Inicia sesión para guardar gasolineras favoritas. En tu perfil puedes configurar el vehículo y los litros para estimar el coste.',
      color: Color(0xffd88418),
    ),
  ];

  Future<void> _markSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(GuidePage.seenKey, true);
  }

  Future<void> _finish() async {
    await _markSeen();
    if (!mounted) return;
    context.pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _index == _steps.length - 1;

    // Cerrar con el gesto o botón de atrás del sistema también cuenta como
    // vista; si no, la guía volvería a aparecer en cada arranque.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _markSeen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cómo usar GasoCan'),
          leading: widget.firstLaunch
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Cerrar guía',
                  onPressed: _finish,
                  icon: const Icon(Icons.close),
                ),
          actions: [
            if (!isLast)
              TextButton(onPressed: _finish, child: const Text('Omitir')),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _steps.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final item = _steps[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 152,
                            height: 152,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon, size: 76, color: item.color),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (isLast) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Text(isLast ? 'Empezar' : 'Siguiente'),
                    ),
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

class _GuideStep {
  const _GuideStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}
