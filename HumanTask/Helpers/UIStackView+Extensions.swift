import Foundation
import UIKit
import Then

public protocol UIStackViewSubviewType {
    func accept(_ visitor: UIStackViewSubviewVisitor)
}

extension Int: UIStackViewSubviewType {
    public func accept(_ visitor: UIStackViewSubviewVisitor) {
        visitor.forInt(self)
    }
}

extension Double: UIStackViewSubviewType {
    public func accept(_ visitor: UIStackViewSubviewVisitor) {
        visitor.forDouble(self)
    }
}

extension CGFloat: UIStackViewSubviewType {
    public func accept(_ visitor: UIStackViewSubviewVisitor) {
        visitor.forCGFloat(self)
    }
}

extension UIView: UIStackViewSubviewType {
    public func accept(_ visitor: UIStackViewSubviewVisitor) {
        visitor.forUIView(self)
    }
}

extension Optional<UIView>: UIStackViewSubviewType {
    public func accept(_ visitor: UIStackViewSubviewVisitor) {
        visitor.forUIView(self)
    }
}

extension Array: UIStackViewSubviewType where Element: UIStackViewSubviewType {
    public func accept(_ visitor: UIStackViewSubviewVisitor) {
        visitor.forUIStackViewSubviewGroup(UIStackViewSubviewGroup(elements: self))
    }
}

struct UIStackViewSubviewGroup: UIStackViewSubviewType {
    let elements: [UIStackViewSubviewType]

    func accept(_ visitor: UIStackViewSubviewVisitor) {
        visitor.forUIStackViewSubviewGroup(self)
    }
}

public struct UIStackViewSubviewVisitor {
    let forUIView: (UIView?) -> Void
    let forUIStackViewSubviewGroup: (UIStackViewSubviewGroup) -> Void
    let forInt: (Int) -> Void
    let forDouble: (Double) -> Void
    let forCGFloat: (CGFloat) -> Void
}

@resultBuilder
public enum UIStackViewArrangedSubviewBuilder {
    public typealias Component = UIStackViewSubviewType

    public static func buildBlock(_ components: Component...) -> Component {
        return UIStackViewSubviewGroup(elements: components)
    }

    public static func buildEither(first: Component) -> Component {
        return first
    }

    public static func buildEither(second: Component) -> Component {
        return second
    }

    public static func buildArray(_ components: [Component]) -> Component {
        return UIStackViewSubviewGroup(elements: components)
    }
}

public extension UIStackView {
    private func createSubviewVisitor() -> UIStackViewSubviewVisitor {
        var previousView: UIView?
        return UIStackViewSubviewVisitor(
            forUIView: { view in
                if let view = view {
                    self.addArrangedSubview(view)
                    previousView = view
                }
            },
            forUIStackViewSubviewGroup: { group in
                let visitor = self.createSubviewVisitor()
                for element in group.elements {
                    element.accept(visitor)
                }
            },
            forInt: { spacing in
                if let view = previousView {
                    self.setCustomSpacing(CGFloat(spacing), after: view)
                }
            },
            forDouble: { spacing in
                if let view = previousView {
                    self.setCustomSpacing(spacing, after: view)
                }
            },
            forCGFloat: { spacing in
                if let view = previousView {
                    self.setCustomSpacing(spacing, after: view)
                }
            }
        )
    }

    @discardableResult
    func addArrangedSubviews(@UIStackViewArrangedSubviewBuilder content: () -> UIStackViewSubviewType) -> Self {
        content().accept(createSubviewVisitor())
        return self
    }
}

public extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { view in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}


public extension UIStackView {
    static func horizontal(alignment: Alignment = .fill, distribution: Distribution = .fill, spacing: CGFloat = 0) -> UIStackView {
        UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = alignment
            $0.distribution = distribution
            $0.spacing = spacing
        }
    }
    
    static func vertical(alignment: Alignment = .fill, distribution: Distribution = .fill, spacing: CGFloat = 0) -> UIStackView {
        UIStackView().then {
            $0.axis = .vertical
            $0.alignment = alignment
            $0.distribution = distribution
            $0.spacing = spacing
        }
    }
}
