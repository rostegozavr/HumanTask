import Foundation
import Combine
import ComposableArchitecture
import API

public class ExchangeRatesFetcher {
    private let value = CurrentValueSubject<APIResult<[ExchangeRate], Error>, Never>(.uninitialized)
    @Dependency(\.exchangeAPI) private var exchangeAPI
    
    nonisolated func publisher() -> AnyPublisher<APIResult<[ExchangeRate], Error>, Never> {
        return value.eraseToAnyPublisher()
    }
    
    func reload() async {
        if case .loading = value.value {
            return
        }
        value.send(.loading)
        do {
            let rates = try await exchangeAPI.loadExchangeRates(.BTC, Date().addingTimeInterval(-50 * 24 * 3600), "5DAY")
            value.send(.success(rates ?? []))
        } catch {
            value.send(.failure(error))
        }
    }
}

extension ExchangeRatesFetcher: DependencyKey {
    public static let liveValue = ExchangeRatesFetcher()
    public static var testValue = ExchangeRatesFetcher()
}

public extension DependencyValues {
    var exchangeRatesFetcher: ExchangeRatesFetcher {
        get { self[ExchangeRatesFetcher.self] }
        set { self[ExchangeRatesFetcher.self] = newValue }
    }
}
