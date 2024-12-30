import Foundation
import UIKit
import MapKit
import ComposableArchitecture
import Then
import TinyConstraints
import API

class ContactDetailsViewController: UIViewController {
    private let store: Store<ContactDetailsFeature.State, ContactDetailsFeature.Action>
    private lazy var mapView = MKMapView()
    private lazy var locationAlertView = ContactDetailsAlertView()
    private lazy var titleLabel = UILabel()
    private lazy var emailLabel = UILabel()
    
    init(store: Store<ContactDetailsFeature.State, ContactDetailsFeature.Action>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let verticalStack = UIStackView.vertical()
        let mapViewWrapper = UIView()
        let horizontalStackWrapper = UIView()
        let horizontalStack = UIStackView.horizontal()
        let infoVStack = UIStackView.vertical()
        view.addSubviews {
            verticalStack.addArrangedSubviews {
                horizontalStackWrapper.addSubviews {
                    horizontalStack.addArrangedSubviews {
                        infoVStack.addArrangedSubviews {
                            titleLabel
                            6
                            emailLabel
                        }
                    }
                }
                mapViewWrapper.addSubviews {
                    mapView
                    locationAlertView
                }
            }
        }
        
        view.do {
            $0.backgroundColor = DesignSystem.Color.traitWhite
        }
        verticalStack.do {
            $0.edgesToSuperview()
        }
        mapView.do {
            $0.edgesToSuperview()
        }
        locationAlertView.do {
            $0.leftToSuperview(offset: 24, relation: .equalOrGreater)
            $0.rightToSuperview(offset: -24, relation: .equalOrLess)
            $0.centerInSuperview()
        }
        horizontalStack.do {
            $0.isLayoutMarginsRelativeArrangement = true
            $0.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.insetsLayoutMarginsFromSafeArea = false
            $0.alignment = .center
            $0.height(80)
            $0.edgesToSuperview(insets: .vertical(16), usingSafeArea: true)
        }
        titleLabel.do {
            $0.numberOfLines = 0
            $0.accessibilityIdentifier = "contact-detail-user-title"
        }
        emailLabel.do {
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.accessibilityIdentifier = "contact-detail-user-email"
        }

        observe { [weak self] in
            guard let self else {
                return
            }
            if let coordinate = coordinate(for: store.contact) {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
                mapView.region = MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 5000,
                    longitudinalMeters: 5000
                )
                locationAlertView.isHidden = true
            } else {
                locationAlertView.title = store.locationAlertText
                locationAlertView.isHidden = false
            }
            titleLabel.text = store.contact.name ?? "<No Name>"
            emailLabel.text = store.contact.email
        }
    }
    
    func coordinate(for contact: Contact) -> CLLocationCoordinate2D? {
        if let address = contact.address, let latitude = address.geo?.lat, let longitude = address.geo?.lng {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
}
