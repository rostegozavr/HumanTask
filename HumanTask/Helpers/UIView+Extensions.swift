import Foundation
import UIKit

public protocol UIViewSubviewType {
    func accept(_ visitor: UIViewSubviewVisitor)
}

extension UIView: UIViewSubviewType {
    public func accept(_ visitor: UIViewSubviewVisitor) {
        visitor.forUIView(self)
    }
}

extension Optional<UIView>: UIViewSubviewType {
    public func accept(_ visitor: UIViewSubviewVisitor) {
        visitor.forUIView(self)
    }
}

extension Array: UIViewSubviewType where Element: UIViewSubviewType {
    public func accept(_ visitor: UIViewSubviewVisitor) {
        visitor.forUIViewSubviewGroup(UIViewSubviewGroup(elements: self))
    }
}

struct UIViewSubviewGroup: UIViewSubviewType {
    let elements: [UIViewSubviewType]

    func accept(_ visitor: UIViewSubviewVisitor) {
        visitor.forUIViewSubviewGroup(self)
    }
}

public struct UIViewSubviewVisitor {
    let forUIView: (UIView?) -> Void
    let forUIViewSubviewGroup: (UIViewSubviewGroup) -> Void
}

@resultBuilder
public enum UIViewSubviewBuilder {
    public typealias Component = UIViewSubviewType

    public static func buildBlock(_ components: Component...) -> Component {
        return UIViewSubviewGroup(elements: components)
    }

    public static func buildEither(first: Component) -> Component {
        return first
    }

    public static func buildEither(second: Component) -> Component {
        return second
    }
}

public extension UIView {
    private func createSubviewVisitor() -> UIViewSubviewVisitor {
        return UIViewSubviewVisitor(
            forUIView: { view in
                if let view = view {
                    self.addSubview(view)
                }
            },
            forUIViewSubviewGroup: { group in
                let visitor = self.createSubviewVisitor()
                for element in group.elements {
                    element.accept(visitor)
                }
            }
        )
    }

    @discardableResult
    func addSubviews(@UIViewSubviewBuilder content: () -> UIViewSubviewType) -> Self {
        content().accept(createSubviewVisitor())
        return self
    }
}
