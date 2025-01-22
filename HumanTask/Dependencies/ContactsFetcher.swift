import Foundation
import Combine
import ComposableArchitecture
import API

public class ContactsFetcher {
    private let value = CurrentValueSubject<APIResult<[Contact], Error>, Never>(.uninitialized)
    @Dependency(\.contactsAPI) private var contactsAPI
    
    nonisolated func publisher() -> AnyPublisher<APIResult<[Contact], Error>, Never> {
        return value.eraseToAnyPublisher()
    }
    
    func reload() async {
        if case .loading = value.value {
            return
        }
        value.send(.loading)
        do {
            let contacts = try await contactsAPI.getContacts()
            value.send(.success(contacts))
        } catch {
            value.send(.failure(error))
        }
    }
}

extension ContactsFetcher: DependencyKey {
    public static let liveValue = ContactsFetcher()
    public static var testValue = ContactsFetcher()
}

public extension DependencyValues {
    var contactsFetcher: ContactsFetcher {
        get { self[ContactsFetcher.self] }
        set { self[ContactsFetcher.self] = newValue }
    }
}
