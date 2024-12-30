import Foundation
import UIKit
import ComposableArchitecture
import API

enum ContactsListSection: Hashable {
    case `default`
}

@Reducer
class ContactsListFeature {
    struct TimerID: Hashable {}
    
    @ObservableState
    struct State: Equatable {
        // countdown
        var timestamp: Date = Date()
        var submissionDate: Date = Date.distantFuture
        var isSubmissionClosed: Bool = false
        
        // list
        var lastLoaded: Date = Date()
        var contacts: [Contact] = []
        var rates: [Double] = []
        var isLoading = false
        var error: Error?
        
        var snapshot: NSDiffableDataSourceSnapshot<ContactsListSection, ContactsListItem> {
            var snapshot = NSDiffableDataSourceSnapshot<ContactsListSection, ContactsListItem>()
            snapshot.appendSections([.default])
            snapshot.appendItems(contacts.map { ContactsListItem(contact: $0, rates: rates, lastLoaded: lastLoaded) })
            return snapshot
        }

        var hasError: Bool {
            error != nil
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.contacts == rhs.contacts &&
            lhs.isLoading == rhs.isLoading &&
            lhs.hasError == rhs.hasError &&
            lhs.lastLoaded == rhs.lastLoaded &&
            lhs.timestamp == rhs.timestamp
        }
    }
    
    enum Action {
        // countdown
        case startCountdownTimer
        case updateCountdownTimer
        // exchangeRate
        case startExchangeRatesTimer
        case waitExchangeRates
        case reloadExchangeRates
        case setLoadingExchangeRates
        case receiveExchangeRatesResponse(Result<[Double], Error>)
        // contacts
        case waitContacts
        case reloadContacts
        case setLoadingContacts
        case receiveContactsResponse(Result<[Contact], Error>)
    }

    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.exchangeRatesFetcher) var exchangeRatesFetcher
    @Dependency(\.contactsFetcher) var contactsFetcher
    @Dependency(\.mainRunLoop) var mainRunLoop
    private let mainQueue: AnySchedulerOf<DispatchQueue> = .main
    
    var body: some ReducerOf<ContactsListFeature> {
        Reduce { state, action in
            switch action {
                
            case .startCountdownTimer:
                let date = Date()
                var submissionDate = self.userDefaultsClient.getSubmissionDate()
                if submissionDate == Date.distantFuture {
                    submissionDate = date.addingTimeInterval(6 * 3600)
                    //submissionDate = date.addingTimeInterval(15)
                    self.userDefaultsClient.setSubmissionDate(submissionDate)
                }
                state.timestamp = date
                state.submissionDate = submissionDate
                state.isSubmissionClosed = submissionDate < date
                return .run { [weak self] send in
                    guard let self else {
                        return
                    }
                    for await _ in self.mainRunLoop.timer(interval: .seconds(1)) {
                        await send(.updateCountdownTimer)
                    }
                }
                
            case .updateCountdownTimer:
                let date = Date()
                state.timestamp = date
                state.isSubmissionClosed = state.submissionDate < date
                return .none
                
            case .startExchangeRatesTimer:
                return .run { [weak self] send in
                    guard let self else {
                        return
                    }
                    for await _ in self.mainRunLoop.timer(interval: .seconds(10)) {
                        await send(.reloadExchangeRates)
                    }
                }
                
            case .reloadExchangeRates:
                state.error = nil
                return .run(operation: { _ in
                    await self.exchangeRatesFetcher.reload()
                })
                
            case .waitExchangeRates:
                return .publisher {
                    self.exchangeRatesFetcher.publisher()
                        .compactMap { value in
                            switch value {
                            case .uninitialized:
                                return nil
                            case .loading:
                                return .setLoadingExchangeRates
                            case let .success(exchangeRates):
                                let rates = exchangeRates.map { $0.rate }
                                return .receiveExchangeRatesResponse(.success(rates))
                            case let .failure(error):
                                return .receiveExchangeRatesResponse(.failure(error))
                            }
                        }
                        .receive(on: DispatchQueue.main)
                }
                
            case .setLoadingExchangeRates:
                return .none
                
            case let .receiveExchangeRatesResponse(result):
                state.isLoading = false
                switch result {
                case let .success(rates):
                    state.rates = rates
                    state.lastLoaded = Date()
                case let .failure(error):
                    state.error = error
                    state.rates = []
                }
                return .none

            case .waitContacts:
                return .publisher {
                    self.contactsFetcher.publisher()
                        .compactMap { value in
                            switch value {
                            case .uninitialized:
                                return nil
                            case .loading:
                                return .setLoadingContacts
                            case let .success(contacts):
                                return .receiveContactsResponse(.success(contacts))
                            case let .failure(error):
                                return .receiveContactsResponse(.failure(error))
                            }
                        }
                        .receive(on: DispatchQueue.main)
                }
                
            case .reloadContacts:
                state.error = nil
                return .run(operation: { _ in
                    await self.contactsFetcher.reload()
                })
                
            case .setLoadingContacts:
                state.isLoading = true
                return .none
                
            case let .receiveContactsResponse(result):
                state.isLoading = false
                switch result {
                case let .success(contacts):
                    state.contacts = contacts
                case let .failure(error):
                    state.error = error
                    state.contacts = []
                }
                return .none
            }
        }
    }
}
