import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDoMdUvvKsGW95CrI1uXcjaN6l3c__g_m0")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GasocanGlassNavigation") {
      registrar.register(GlassNavigationFactory(messenger: registrar.messenger()), withId: "gasocan/glass-navigation")
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GasocanIcono") {
      registrarIconoApp(messenger: registrar.messenger())
    }
  }

  /// Icono alternativo de la app (regalo de «Invítame a un café»). Los
  /// nombres son los conjuntos AppIcon-Noche, AppIcon-Naranja y AppIcon-Cafe;
  /// nil vuelve al original.
  private func registrarIconoApp(messenger: FlutterBinaryMessenger) {
    let canal = FlutterMethodChannel(name: "gasocan/icono", binaryMessenger: messenger)
    canal.setMethodCallHandler { call, result in
      let app = UIApplication.shared
      switch call.method {
      case "actual":
        result(app.alternateIconName)
      case "cambiar":
        guard app.supportsAlternateIcons else { result(false); return }
        app.setAlternateIconName(call.arguments as? String) { error in
          result(error == nil)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
