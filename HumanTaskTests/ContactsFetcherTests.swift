import XCTest
import Combine
import ComposableArchitecture
import API
@testable import HumanTask

final class ContactsFetcherTests: XCTestCase {
    enum ContactsFetcherTestError: Swift.Error {
        case `default`(String)
    }
    
    let defaultContacts: [Contact] = [
        Contact(id: 1, name: nil),
        Contact(id: 2, name: "John"),
        Contact(id: 3, name: "Hans"),
        Contact(id: 4, name: "Alexander", username: "Alex"),
    ]
    
    func testNormalCase() async throws {
        let defaultContacts = defaultContacts
        try await withDependencies {
            $0.contactsAPI.getContacts = {
                await XCTWaiter().fulfillment(of: [XCTestExpectation()], timeout: 0.2)
                return defaultContacts
            }
            $0.contactsFetcher = ContactsFetcher()
        } operation: {
            @Dependency(\.contactsFetcher) var contactsFetcher
            let publisher = contactsFetcher.publisher().prefix(5)
            var idx = 0
            for await result in publisher.values {
                switch idx {
                case 0:
                    guard case .uninitialized = result else {
                        throw ContactsFetcherTestError.default("Result should be `uninitialized`")
                    }
                    Task {
                        await contactsFetcher.reload()
                    }
                case 1:
                    guard case .loading = result else {
                        throw ContactsFetcherTestError.default("Result should be `loading`")
                    }
                case 2:
                    guard case let .success(contacts) = result, contacts == defaultContacts else {
                        throw ContactsFetcherTestError.default("Result should be `success`")
                    }
                    Task {
                        await contactsFetcher.reload()
                    }
                case 3:
                    guard case .loading = result else {
                        throw ContactsFetcherTestError.default("Result should be `loading`")
                    }
                case 4:
                    guard case let .success(contacts) = result, contacts == defaultContacts else {
                        throw ContactsFetcherTestError.default("Result should be `success`")
                    }
                default:
                    break
                }
                idx += 1
            }
        }
    }
    
    func testQuickReload() async throws {
        let defaultContacts = defaultContacts
        try await withDependencies {
            $0.contactsAPI.getContacts = {
                await XCTWaiter().fulfillment(of: [XCTestExpectation()], timeout: 0.5)
                return defaultContacts
            }
            $0.contactsFetcher = ContactsFetcher()
        } operation: {
            @Dependency(\.contactsFetcher) var contactsFetcher
            let publisher = contactsFetcher.publisher().prefix(3)
            var idx = 0
            for await result in publisher.values {
                switch idx {
                case 0:
                    guard case .uninitialized = result else {
                        throw ContactsFetcherTestError.default("Result should be `uninitialized`")
                    }
                    Task {
                        await contactsFetcher.reload()
                    }
                    Task {
                        await contactsFetcher.reload()
                    }
                    Task {
                        await contactsFetcher.reload()
                    }
                case 1:
                    guard case .loading = result else {
                        throw ContactsFetcherTestError.default("Result should be `loading`")
                    }
                case 2:
                    guard case let .success(contacts) = result, contacts == defaultContacts else {
                        throw ContactsFetcherTestError.default("Result should be `success`")
                    }
                default:
                    break
                }
                idx += 1
            }
        }
    }
    
    func testErrorCase() async throws {
        try await withDependencies {
            $0.contactsAPI.getContacts = {
                await XCTWaiter().fulfillment(of: [XCTestExpectation()], timeout: 0.5)
                throw ContactsFetcherTestError.default("Something went wrong")
            }
            $0.contactsFetcher = ContactsFetcher()
        } operation: {
            @Dependency(\.contactsFetcher) var contactsFetcher
            let publisher = contactsFetcher.publisher().prefix(3)
            var idx = 0
            for await result in publisher.values {
                switch idx {
                case 0:
                    guard case .uninitialized = result else {
                        throw ContactsFetcherTestError.default("Result should be `uninitialized`")
                    }
                    Task {
                        await contactsFetcher.reload()
                    }
                case 1:
                    guard case .loading = result else {
                        throw ContactsFetcherTestError.default("Result should be `loading`")
                    }
                case 2:
                    guard case .failure = result else {
                        throw ContactsFetcherTestError.default("Result should be `failure`")
                    }
                default:
                    break
                }
                idx += 1
            }
        }
    }
}
