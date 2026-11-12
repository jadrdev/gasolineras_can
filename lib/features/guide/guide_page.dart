import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gasolineras_can/l10n/l10n.dart';

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

  /// Los pasos se montan en cada build para que salgan en el idioma actual.
  static List<_GuideStep> _steps(AppLocalizations l10n) => [
    _GuideStep(
      icon: Icons.search,
      title: l10n.guideStep1Title,
      description: l10n.guideStep1Body,
      color: const Color(0xff087be8),
    ),
    _GuideStep(
      icon: Icons.price_check,
      title: l10n.guideStep2Title,
      description: l10n.guideStep2Body,
      color: const Color(0xff16855b),
    ),
    _GuideStep(
      icon: Icons.map_outlined,
      title: l10n.guideStep3Title,
      description: l10n.guideStep3Body,
      color: const Color(0xff8056c7),
    ),
    _GuideStep(
      icon: Icons.star_outline,
      title: l10n.guideStep4Title,
      description: l10n.guideStep4Body,
      color: const Color(0xffd88418),
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
    final steps = _steps(context.l10n);
    final isLast = _index == steps.length - 1;

    // Cerrar con el gesto o botón de atrás del sistema también cuenta como
    // vista; si no, la guía volvería a aparecer en cada arranque.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _markSeen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.guideTitle),
          leading: widget.firstLaunch
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: context.l10n.guideClose,
                  onPressed: _finish,
                  icon: const Icon(Icons.close),
                ),
          actions: [
            if (!isLast)
              TextButton(
                onPressed: _finish,
                child: Text(context.l10n.guideSkip),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: steps.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final item = steps[index];
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
                  steps.length,
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
                      child: Text(
                        isLast
                            ? context.l10n.guideStart
                            : context.l10n.guideNext,
                      ),
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
