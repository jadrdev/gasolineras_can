import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Atajo para los textos traducidos en las pantallas: `context.l10n.clave`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Textos fuera de las pantallas (blocs, servicios, notificaciones): usa el
/// idioma del móvil, con español si no es uno de los que tiene la app.
AppLocalizations get l10nSistema => lookupAppLocalizations(
  basicLocaleListResolution(
    PlatformDispatcher.instance.locales,
    AppLocalizations.supportedLocales,
  ),
);
