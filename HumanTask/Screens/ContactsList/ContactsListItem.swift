import API
import Foundation

struct ContactsListItem: Hashable {
    let contact: Contact
    let rates: [Double]
    let lastLoaded: Date
    
    public init(contact: Contact, rates: [Double], lastLoaded: Date) {
        self.contact = contact
        self.rates = rates
        self.lastLoaded = lastLoaded
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(contact.id)
        hasher.combine(lastLoaded)
    }
}
