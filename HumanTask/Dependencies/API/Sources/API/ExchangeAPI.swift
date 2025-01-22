import Foundation
import Dependencies
import Alamofire

public class ExchangeAPI {
    private static let apiKey = "26807AD6-C5AF-41AD-BE0B-D6A1049C182A"
    private static let exchangeRateURL = "https://rest.coinapi.io/v1/exchangerate/%@/%@/history?period_id=%@&time_start=%@T00:00:00&apikey=\(apiKey)"
    
    public var loadExchangeRates: (_ token: CryptoCurrency, _ start: Date, _ period: String) async throws -> [ExchangeRate]?
    
    public init(loadExchangeRates: @escaping (_ token: CryptoCurrency, _ start: Date, _ period: String) async throws -> [ExchangeRate]?) {
        self.loadExchangeRates = loadExchangeRates
    }
}

extension ExchangeAPI: DependencyKey {
    public static let liveValue = ExchangeAPI(
        loadExchangeRates: { token, start, period in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            return try await AF
                .request(
                    String(format: ExchangeAPI.exchangeRateURL, token.rawValue, "USD", period, DateFormatter.iso8601Short.string(from: start))
                )
                .validate(statusCode: 200..<300)
                .serializingDecodable([ExchangeRate].self, decoder: decoder)
                .value
        }
    )
}

public extension DependencyValues {
    var exchangeAPI: ExchangeAPI {
        get { self[ExchangeAPI.self] }
        set { self[ExchangeAPI.self] = newValue }
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let iso8601Short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
