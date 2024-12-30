import Foundation
import UIKit

class ContactDetailsAlertView: UIView {
    private lazy var iconView = UIImageView()
    private lazy var titleLabel = UILabel()

    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let horizontalStack = UIStackView.horizontal(alignment: .center)
        addSubviews {
            horizontalStack.addArrangedSubviews {
                iconView
                12
                titleLabel
            }
        }
        self.do {
            $0.layer.cornerRadius = 8
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowOffset = CGSize(width: 2, height: 6)
            $0.backgroundColor = DesignSystem.Color.traitWhite
        }
        horizontalStack.do {
            $0.edgesToSuperview(insets: .uniform(16))
        }
        iconView.do {
            $0.image = UIImage(systemName: "exclamationmark.circle")
            $0.tintColor = .red
        }
        titleLabel.do {
            $0.numberOfLines = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
