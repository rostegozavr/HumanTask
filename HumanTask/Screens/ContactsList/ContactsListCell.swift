import Foundation
import UIKit
import SwiftUI
import API

class ContactsListCell: UITableViewCell {
    private var hostingController: UIHostingController<ContactView>?
    
    func configure(contact: Contact, data: [Double]) {
        let shuffledData = data.shuffled()
        let marketCap = shuffledData.last
        let contactsListItemView = ContactView(name: contact.name ?? "",
                                               username: contact.username ?? "",
                                               marketCap: marketCap != nil ? "\(Int(marketCap ?? 0))" : "",
                                               data: shuffledData)
        if hostingController == nil {
            hostingController = UIHostingController(rootView: contactsListItemView)
            if let hostingView = hostingController?.view {
                hostingView.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(hostingView)
                NSLayoutConstraint.activate([
                    hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
                ])
            }
        } else {
            hostingController?.rootView = contactsListItemView
        }
    }
}
