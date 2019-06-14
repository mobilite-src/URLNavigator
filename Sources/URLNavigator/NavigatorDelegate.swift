#if os(iOS) || os(tvOS)
import UIKit

public enum PresentationMode {
    case push
    case present
    case replaceRootViewController
}

public protocol NavigatorDelegate: class {
    
    func routeToViewController(viewModel: ViewModel, presentationMode: PresentationMode, url: URLConvertible, context: Any?) -> Bool
}
#endif
