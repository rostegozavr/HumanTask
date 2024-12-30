import Foundation
import UIKit

enum DesignSystem {
    struct Color {
        static let traitWhite = UIColor(dynamicProvider: { trait in
            if trait.userInterfaceStyle == .dark {
                UIColor(white: 0, alpha: 1)
            } else {
                UIColor(white: 1, alpha: 1)
            }
        })
        static let traitBlue = UIColor(dynamicProvider: { trait in
            if trait.userInterfaceStyle == .dark {
                UIColor(white: 1, alpha: 1)
            } else {
                UIColor.systemBlue
            }
        })
    }
}
