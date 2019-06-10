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

  public init() {
    // ⛵ I'm a Navigator!
  }

  open func addRoute(_ pattern: URLPattern, _ viewModelFactory: @escaping ViewModelFactory<T>, handlerFactory: URLOpenHandlerFactory<T>? = nil) {
    self.viewModelFactories[pattern] = viewModelFactory
    self.handlerFactories[pattern] = handlerFactory
  }

  open func handler(for url: URLConvertible, context: Any?) -> URLOpenHandler? {
    let urlPatterns = Array(self.viewModelFactories.keys)
    guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
    guard let viewModelFactory = self.viewModelFactories[match.pattern] else { return nil }
    guard let viewModel = viewModelFactory(url, match.values, context) else { return nil }
    if let handlerFactory = self.handlerFactories[match.pattern] {
        return { handlerFactory(viewModel, url, match.values, context) }
    } else {
        return {
            return self.delegate?.present(viewModel: viewModel, url: url, context: context) ?? false
        }
    }
  }
    
    open func openURL(_ url: URLConvertible, context: Any?) -> Bool {
        if let handle = handler(for: url, context: context) {
            return handle()
        }
        return false
    }
}

#endif
