import Foundation
import UIKit
import ComposableArchitecture

class ContactsListCoordinator {
    let navigationController: UINavigationController
    
    init() {
        let contactsListViewController = ContactsListViewController(
            store: Store(
                initialState: ContactsListFeature.State(),
                reducer: {
                    ContactsListFeature()
                }
            )
        )
        navigationController = UINavigationController(rootViewController: contactsListViewController)
        navigationController.navigationBar.tintColor = DesignSystem.Color.traitBlue
        
        contactsListViewController.didSelectContact = { [weak self] contact in
            guard let self else {
                return
            }
            let contactDetailsViewController = ContactDetailsViewController(
                store: Store(
                    initialState: ContactDetailsFeature.State(
                        contact: contact
                    ),
                    reducer: {
                        ContactDetailsFeature()
                    }
                )
            )
            if contact.id <= 3 {
                navigationController.pushViewController(contactDetailsViewController, animated: true)
            } else {
                contactDetailsViewController.modalPresentationStyle = .popover
                navigationController.present(contactDetailsViewController, animated: true)
            }
        }
    }
}

struct TimerEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}
