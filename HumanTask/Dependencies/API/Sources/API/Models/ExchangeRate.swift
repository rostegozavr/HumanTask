import Foundation

public struct ExchangeRate: Codable {
    public let time: Date
    public let rate: Double
    
    enum CodingKeys: String, CodingKey {
        case time = "time_open"
        case rate = "rate_open"
    }
}
