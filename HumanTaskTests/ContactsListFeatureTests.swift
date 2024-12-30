import XCTest
import ComposableArchitecture
import SnapshotTesting
import API
@testable import HumanTask

final class ContactsListFeatureTests: XCTestCase {
    enum TestContactsListError: Error {
        case `default`
    }
    
    let defaultContacts: [Contact] = [
        Contact(id: 1, name: nil),
        Contact(id: 2, name: "John"),
        Contact(id: 3, name: "Hans"),
        Contact(id: 4, name: "Alexander", username: "Alex"),
    ]
    var testClock: TestClock<Duration>!
    
    override func setUpWithError() throws {
        testClock = TestClock()
    }
    
    @MainActor
    func testContactsListReload() async throws {
        let clock = testClock!
        let defaultContacts = defaultContacts
        let store = TestStore(
            initialState: ContactsListFeature.State(),
            reducer: {
                ContactsListFeature()
            },
            withDependencies: {
                $0.contactsAPI.getContacts = {
                    try await clock.sleep(for: .seconds(2))
                    return defaultContacts
                }
                $0.contactsFetcher = ContactsFetcher()
            }
        )
        store.exhaustivity = .off
        
        await store.send(.waitContacts)
        XCTAssert(store.state.snapshot.itemIdentifiers.isEmpty)
        await store.send(.reloadContacts)
        await store.receive(\.setLoadingContacts) {
            $0.isLoading = true
        }
        XCTAssert(store.state.snapshot.itemIdentifiers.isEmpty)
        await testClock.run()
        await store.receive(\.receiveContactsResponse) {
            $0.isLoading = false
            $0.error = nil
            $0.contacts = defaultContacts
        }
        XCTAssert(store.state.snapshot.itemIdentifiers.count == defaultContacts.count)
        await store.send(.reloadContacts)
        await store.receive(\.setLoadingContacts) {
            $0.isLoading = true
        }
        XCTAssert(store.state.snapshot.itemIdentifiers.count == defaultContacts.count)
        await testClock.run()
        await store.receive(\.receiveContactsResponse) {
            $0.isLoading = false
            $0.error = nil
            $0.contacts = defaultContacts
        }
        XCTAssert(store.state.snapshot.itemIdentifiers.count == defaultContacts.count)
    }
    
    @MainActor
    func testContactsListReloadWithError() async throws {
        let clock = testClock!
        let store = TestStore(
            initialState: ContactsListFeature.State(),
            reducer: {
                ContactsListFeature()
            },
            withDependencies: {
                $0.contactsAPI.getContacts = {
                    await XCTWaiter().fulfillment(of: [XCTestExpectation()], timeout: 0.5)
                    throw TestContactsListError.default
                }
                $0.contactsFetcher = ContactsFetcher()
            }
        )
        store.exhaustivity = .off
        
        await store.send(.waitContacts)
        XCTAssert(store.state.snapshot.itemIdentifiers.isEmpty)
        await store.send(.reloadContacts)
        await store.receive(\.setLoadingContacts) {
            $0.isLoading = true
        }
        XCTAssert(store.state.snapshot.itemIdentifiers.isEmpty)
        await clock.run()
        await store.receive(\.receiveContactsResponse) {
            $0.isLoading = false
            $0.error = TestContactsListError.default
            $0.contacts = []
        }
        XCTAssert(store.state.snapshot.itemIdentifiers.isEmpty)
        await store.send(.reloadContacts)
        await store.receive(\.setLoadingContacts) {
            $0.isLoading = true
        }
        XCTAssert(store.state.snapshot.itemIdentifiers.isEmpty)
        await clock.run()
        await store.receive(\.receiveContactsResponse) {
            $0.isLoading = false
            $0.error = TestContactsListError.default
            $0.contacts = []
        }
        XCTAssert(store.state.snapshot.itemIdentifiers.isEmpty)
    }
    
    // MARK: - UI Snapshots

//    @MainActor
//    func testContactsList() async throws {
//        let navigationController = UINavigationController(
//            rootViewController: ContactsListViewController(
//                store: Store(
//                    initialState: ContactsListFeature.State(),
//                    reducer: {
//                        ContactsListFeature()
//                    },
//                    withDependencies: { dependencies in
//                        dependencies.contactsAPI.getContacts = {
//                            [
//                                Contact(id: 1, name: nil),
//                                Contact(id: 2, name: "John"),
//                                Contact(id: 3, name: "Kirill"),
//                                Contact(id: 4, name: "Alexander", username: "Alex"),
//                            ]
//                        }
//                        
//                        let contactsFetcher = dependencies.contactsFetcher
//                        Task {
//                            await contactsFetcher.reload()
//                        }
//                    }
//                )
//            )
//        )
//        navigationController.loadViewIfNeeded()
//        navigationController.view.setNeedsLayout()
//        navigationController.view.layoutIfNeeded()
//
//        await XCTWaiter().fulfillment(of: [XCTestExpectation()], timeout: 3)
//        assertSnapshot(of: navigationController, as: .image(on: .iPhone13ProMax(.portrait), precision: 3, perceptualPrecision: 3))
//    }
}
