import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'auth_bloc.dart';

/// «o» + botón oficial «Iniciar sesión con Apple». Solo en iOS: en Android
/// haría falta el flujo web de Apple, que no está configurado.
class AppleSignInSection extends StatelessWidget {
  final bool enabled;
  const AppleSignInSection({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        IgnorePointer(
          ignoring: !enabled,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: SignInWithAppleButton(
              text: 'Iniciar sesión con Apple',
              height: 52,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              // Guía de Apple: botón blanco sobre fondo oscuro y negro sobre claro.
              style: dark
                  ? SignInWithAppleButtonStyle.white
                  : SignInWithAppleButtonStyle.black,
              onPressed: () => context.read<AuthBloc>().signInWithApple(),
            ),
          ),
        ),
      ],
    );
  }
}
