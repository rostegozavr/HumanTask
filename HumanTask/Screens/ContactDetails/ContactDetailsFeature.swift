import Foundation
import UIKit
import ComposableArchitecture
import API

@Reducer
class ContactDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let contact: Contact
        
        var locationAlertText: String {
            return "Location not found"
        }
    }
    
    enum Action {
    }
    
    var body: some ReducerOf<ContactDetailsFeature> {
        Reduce { _, _ in
            return .none
        }
    }
}
