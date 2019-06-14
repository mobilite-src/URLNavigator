#if os(iOS) || os(tvOS)
import UIKit

#if !COCOAPODS
import URLMatcher
#endif

open class Navigator<T: ViewModel> /*: NavigatorType*/ {
  public let matcher = URLMatcher()
  open weak var delegate: NavigatorDelegate?

  private var viewModelFactories = [URLPattern: ViewModelFactory<T>]()
  private var handlerFactories = [URLPattern: URLOpenHandlerFactory<T>]()
  private var insertionList = [URLPattern]()
  private var presentationModes = [URLPattern: PresentationMode]()

  public init() {
    // ⛵ I'm a Navigator!
  }

    open func addRoute(_ pattern: URLPattern, _ viewModelFactory: @escaping ViewModelFactory<T>, handlerFactory: @escaping URLOpenHandlerFactory<T>) {
    self.addPattern(pattern: pattern, viewModelFactory, handlerFactory: handlerFactory, presentationMode: nil)
  }
    
    open func addRoute(_ pattern: URLPattern, presentationMode: PresentationMode, _ viewModelFactory: @escaping ViewModelFactory<T>) {
        self.addPattern(pattern: pattern, viewModelFactory, handlerFactory: nil, presentationMode: presentationMode)
    }
    
    private func addPattern(pattern: URLPattern, _ viewModelFactory: @escaping ViewModelFactory<T>, handlerFactory: URLOpenHandlerFactory<T>? = nil, presentationMode: PresentationMode? = nil) {
        self.viewModelFactories[pattern] = viewModelFactory
        self.handlerFactories[pattern] = handlerFactory
        self.presentationModes[pattern] = presentationMode
        self.insertionList.append(pattern)
    }

  open func handler(for url: URLConvertible, context: Any?) -> URLOpenHandler? {
    guard let match = self.matcher.match(url, from: insertionList) else { return nil }
    guard let viewModelFactory = self.viewModelFactories[match.pattern] else { return nil }
    guard let viewModel = viewModelFactory(url, match.values, context) else { return nil }
    if let handlerFactory = self.handlerFactories[match.pattern] {
        return { handlerFactory(viewModel, url, match.values, context) }
    } else {
        guard let presentationMode = self.presentationModes[match.pattern] else { return nil }
        return {
            return self.delegate?.routeToViewController(viewModel: viewModel, presentationMode: presentationMode, url: url, context: context) ?? false
        }
    }
  }
    
    open func getViewModel(_ url: URLConvertible, context: Any?) -> ViewModel? {
        let urlPatterns = Array(self.viewModelFactories.keys)
        guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
        guard let viewModelFactory = self.viewModelFactories[match.pattern] else { return nil }
        return viewModelFactory(url, match.values, context)
    }
    
    open func openURL(_ url: URLConvertible, context: Any?) -> Bool {
        if let handle = handler(for: url, context: context) {
            return handle()
        }
        return false
    }
}

#endif
