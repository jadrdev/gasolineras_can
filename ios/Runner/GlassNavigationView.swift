import Flutter
import UIKit

final class GlassNavigationFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  init(messenger: FlutterBinaryMessenger) { self.messenger = messenger }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    GlassNavigationView(frame: frame, id: viewId, messenger: messenger, configuration: args as? [String: Any] ?? [:])
  }
}

final class GlassNavigationView: NSObject, FlutterPlatformView {
  private let root: UIView
  private let surface = UIVisualEffectView()
  private let stack = UIStackView()
  private let channel: FlutterMethodChannel
  private var configuration: [String: Any]
  private var accessibilityObserver: NSObjectProtocol?
  private let separator = UIView()
  private var stackBottom: NSLayoutConstraint!
  private var separatorHeight: NSLayoutConstraint!

  init(frame: CGRect, id: Int64, messenger: FlutterBinaryMessenger, configuration: [String: Any]) {
    let rootView = RootView(frame: frame)
    root = rootView
    channel = FlutterMethodChannel(name: "gasocan/glass-navigation/\(id)", binaryMessenger: messenger)
    self.configuration = configuration
    super.init()
    rootView.onLayout = { [weak self] in
      guard let self else { return }
      let floating = self.configuration["floating"] as? Bool ?? true
      self.surface.layer.cornerRadius = floating ? self.root.bounds.height / 2 : 0
      // Un píxel de la pantalla en la que está ahora (cambia al plegar el iPhone Duo).
      self.separatorHeight.constant = 1 / max(self.root.traitCollection.displayScale, 1)
    }
    root.backgroundColor = .clear
    surface.translatesAutoresizingMaskIntoConstraints = false
    surface.layer.cornerCurve = .continuous
    surface.clipsToBounds = true
    root.addSubview(surface)
    separator.translatesAutoresizingMaskIntoConstraints = false
    separator.backgroundColor = .separator
    root.addSubview(separator)
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.spacing = 0
    stack.translatesAutoresizingMaskIntoConstraints = false
    surface.contentView.addSubview(stack)
    separatorHeight = separator.heightAnchor.constraint(equalToConstant: 1 / max(root.traitCollection.displayScale, 1))
    stackBottom = stack.bottomAnchor.constraint(equalTo: surface.contentView.bottomAnchor, constant: -4)
    NSLayoutConstraint.activate([
      separator.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      separator.trailingAnchor.constraint(equalTo: root.trailingAnchor),
      separator.topAnchor.constraint(equalTo: root.topAnchor),
      separatorHeight,
      surface.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      surface.trailingAnchor.constraint(equalTo: root.trailingAnchor),
      surface.topAnchor.constraint(equalTo: root.topAnchor),
      surface.bottomAnchor.constraint(equalTo: root.bottomAnchor),
      stack.leadingAnchor.constraint(equalTo: surface.contentView.leadingAnchor, constant: 6),
      stack.trailingAnchor.constraint(equalTo: surface.contentView.trailingAnchor, constant: -6),
      stack.topAnchor.constraint(equalTo: surface.contentView.topAnchor, constant: 4),
      stackBottom,
    ])
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { result(nil); return }
      guard call.method == "update", let config = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented); return
      }
      self.configuration = config
      self.update()
      result(nil)
    }
    accessibilityObserver = NotificationCenter.default.addObserver(
      forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
      object: nil, queue: .main
    ) { [weak self] _ in self?.update() }
    update()
  }

  func view() -> UIView { root }

  /// La cápsula siempre redonda, aunque cambie el alto con el tamaño de texto.
  private final class RootView: UIView {
    var onLayout: (() -> Void)?
    override func layoutSubviews() { super.layoutSubviews(); onLayout?() }

    override init(frame: CGRect) {
      super.init(frame: frame)
      // Al pasar de una pantalla a otra del iPhone Duo puede cambiar la escala:
      // vuelve a medir la línea fina. En iOS 15 y 16 se lee en el siguiente layout.
      if #available(iOS 17.0, *) {
        registerForTraitChanges([UITraitDisplayScale.self]) { (view: UIView, _: UITraitCollection) in
          view.setNeedsLayout()
        }
      }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  }

  private func update() {
    // Medidas de la barra de pestañas de Apple. iOS 26: cápsula flotante de
    // 62 pt (el margen lo pone Flutter). Antes: barra de 49 pt de lado a lado
    // con línea fina arriba y el hueco del indicador de inicio debajo.
    let floating = configuration["floating"] as? Bool ?? true
    let bottomInset = CGFloat((configuration["bottomInset"] as? NSNumber)?.doubleValue ?? 0)
    surface.layer.cornerRadius = floating ? root.bounds.height / 2 : 0
    separator.isHidden = floating
    stackBottom.constant = floating ? -4 : -(bottomInset + 1)
    root.overrideUserInterfaceStyle = configuration["dark"] as? Bool == true ? .dark : .light
    let opaque = UIAccessibility.isReduceTransparencyEnabled || configuration["highContrast"] as? Bool == true
    if opaque {
      surface.effect = nil
      surface.backgroundColor = .secondarySystemBackground
    } else if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: .regular)
      glass.isInteractive = true
      surface.backgroundColor = .clear
      surface.effect = glass
    } else {
      surface.backgroundColor = .clear
      surface.effect = UIBlurEffect(style: .systemChromeMaterial)
    }
    let raw = (configuration["tint"] as? NSNumber)?.uint32Value ?? 0xFF007AFF
    let tint = UIColor(red: CGFloat((raw >> 16) & 255) / 255,
                       green: CGFloat((raw >> 8) & 255) / 255,
                       blue: CGFloat(raw & 255) / 255, alpha: 1)
    let labels = configuration["labels"] as? [String] ?? []
    let symbols = configuration["symbols"] as? [String] ?? []
    let selected = configuration["selectedIndex"] as? Int ?? 0
    for view in stack.arrangedSubviews { stack.removeArrangedSubview(view); view.removeFromSuperview() }
    for (index, label) in labels.enumerated() {
      let button = UIButton(type: .system)
      var style = UIButton.Configuration.plain()
      style.title = label
      style.image = UIImage(systemName: index < symbols.count ? symbols[index] : "circle")
      style.imagePlacement = .top
      style.imagePadding = floating ? 3 : 2
      style.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
      style.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
      style.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
        // 10 pt como las pestañas del sistema, y crece con el tamaño de texto.
        outgoing.font = UIFontMetrics(forTextStyle: .caption2)
          .scaledFont(for: .systemFont(ofSize: 10, weight: .medium))
        return outgoing
      }
      style.baseForegroundColor = index == selected ? tint : .secondaryLabel
      // En iOS 26 la pestaña elegida lleva una píldora; antes, solo el color.
      style.background.backgroundColor = floating && index == selected ? tint.withAlphaComponent(0.12) : .clear
      style.background.cornerRadius = 27
      button.configuration = style
      button.titleLabel?.adjustsFontForContentSizeCategory = true
      button.accessibilityLabel = label
      button.accessibilityTraits = index == selected ? [.button, .selected] : [.button]
      button.accessibilityIdentifier = "navigation-\(index)"
      button.addAction(UIAction { [weak self] _ in
        self?.channel.invokeMethod("select", arguments: index)
      }, for: .touchUpInside)
      stack.addArrangedSubview(button)
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
    if let accessibilityObserver { NotificationCenter.default.removeObserver(accessibilityObserver) }
  }
}
