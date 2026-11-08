import 'package:flutter/material.dart';

/// Kept outside the result list so zero matches never removes the input/focus.
class StationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const StationSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
    key: const ValueKey('station-search'),
    controller: controller,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Marca, dirección o municipio',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Borrar búsqueda',
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
    ),
    onChanged: onChanged,
  );
}
