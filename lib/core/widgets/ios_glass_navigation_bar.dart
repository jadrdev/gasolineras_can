import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Native UIKit material on iOS (Liquid Glass on iOS 26+, blur on older iOS).
/// The host remains responsible for safe areas and the selected page.
class IosGlassNavigationBar extends StatefulWidget {
  final List<String> labels;
  final List<String> symbols;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const IosGlassNavigationBar({
    super.key,
    required this.labels,
    required this.symbols,
    required this.selectedIndex,
    required this.onSelected,
  });
  @override
  State<IosGlassNavigationBar> createState() => _IosGlassNavigationBarState();
}

class _IosGlassNavigationBarState extends State<IosGlassNavigationBar> {
  MethodChannel? _channel;

  Map<String, Object> _configuration(BuildContext context) => {
    'labels': widget.labels,
    'symbols': widget.symbols,
    'selectedIndex': widget.selectedIndex,
    'dark': Theme.of(context).brightness == Brightness.dark,
    'highContrast': MediaQuery.highContrastOf(context),
    'tint': Theme.of(context).colorScheme.primary.toARGB32(),
  };

  @override
  void didUpdateWidget(covariant IosGlassNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _update();
  }

  Future<void> _update() async {
    await _channel?.invokeMethod<void>('update', _configuration(context));
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UiKitView(
    viewType: 'gasocan/glass-navigation',
    creationParamsCodec: const StandardMessageCodec(),
    creationParams: _configuration(context),
    onPlatformViewCreated: (id) {
      if (!mounted) return;
      _channel = MethodChannel('gasocan/glass-navigation/$id');
      _channel!.setMethodCallHandler((call) async {
        if (!mounted || call.method != 'select' || call.arguments is! int) {
          return;
        }
        final index = call.arguments as int;
        if (index >= 0 && index < widget.labels.length) {
          widget.onSelected(index);
        }
      });
      _update();
    },
  );
}
