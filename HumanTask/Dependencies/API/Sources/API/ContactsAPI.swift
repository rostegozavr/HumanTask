import Foundation
import Alamofire
import Dependencies

public class ContactsAPI {
    public var getContacts: () async throws -> [Contact]
    
    public init(getContacts: @escaping () async throws -> [Contact]) {
        self.getContacts = getContacts
    }
}

extension ContactsAPI: DependencyKey {
    public static let liveValue = ContactsAPI(
        getContacts: {
            try await AF
                .request(
                    "https://jsonplaceholder.typicode.com/users"
                )
                .validate(statusCode: 200..<300)
                .serializingDecodable([Contact].self)
                .value
        }
    )
}

public extension DependencyValues {
    var contactsAPI: ContactsAPI {
        get { self[ContactsAPI.self] }
        set { self[ContactsAPI.self] = newValue }
    }
}
