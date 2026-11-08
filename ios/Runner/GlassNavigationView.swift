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

  init(frame: CGRect, id: Int64, messenger: FlutterBinaryMessenger, configuration: [String: Any]) {
    root = UIView(frame: frame)
    channel = FlutterMethodChannel(name: "gasocan/glass-navigation/\(id)", binaryMessenger: messenger)
    self.configuration = configuration
    super.init()
    root.backgroundColor = .clear
    surface.translatesAutoresizingMaskIntoConstraints = false
    surface.layer.cornerRadius = 32
    surface.layer.cornerCurve = .continuous
    surface.clipsToBounds = true
    root.addSubview(surface)
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.spacing = 4
    stack.translatesAutoresizingMaskIntoConstraints = false
    surface.contentView.addSubview(stack)
    NSLayoutConstraint.activate([
      surface.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      surface.trailingAnchor.constraint(equalTo: root.trailingAnchor),
      surface.topAnchor.constraint(equalTo: root.topAnchor),
      surface.bottomAnchor.constraint(equalTo: root.bottomAnchor),
      stack.leadingAnchor.constraint(equalTo: surface.contentView.leadingAnchor, constant: 6),
      stack.trailingAnchor.constraint(equalTo: surface.contentView.trailingAnchor, constant: -6),
      stack.topAnchor.constraint(equalTo: surface.contentView.topAnchor, constant: 5),
      stack.bottomAnchor.constraint(equalTo: surface.contentView.bottomAnchor, constant: -5),
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

  private func update() {
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
      style.imagePadding = 3
      style.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 21, weight: .medium)
      style.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
        outgoing.font = UIFont.preferredFont(forTextStyle: .caption1)
        return outgoing
      }
      style.baseForegroundColor = index == selected ? tint : .secondaryLabel
      style.background.backgroundColor = index == selected ? tint.withAlphaComponent(0.14) : .clear
      style.background.cornerRadius = 26
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
