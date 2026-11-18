import 'dart:ui';

import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Idiomas de la app. Sustituye a AppLocalizations.localizationsDelegates:
/// el archivo que genera Flutter (gen-l10n) aún registra las traducciones del
/// Material antiguo (flutter_localizations) y los widgets de material_ui no
/// las encuentran («No MaterialLocalizations found»).
const List<LocalizationsDelegate<dynamic>> delegadosIdioma = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

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
