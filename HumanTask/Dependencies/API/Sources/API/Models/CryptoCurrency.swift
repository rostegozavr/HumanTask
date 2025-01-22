import UIKit

public enum CryptoCurrency: String, CaseIterable {
    case BTC
    case ETH
    case XRP
    case DOGE
    
    var name: String {
        switch self {
        case .BTC:
            return "Bitcoin"
        case .ETH:
            return "Ethereum"
        case .XRP:
            return "XRP"
        case .DOGE:
            return "Dogecoin"
        }
    }
}
