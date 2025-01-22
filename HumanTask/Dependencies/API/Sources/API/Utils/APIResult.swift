import Foundation
import Alamofire

public enum APIResult<Success, Failure> where Failure: Error {
    case uninitialized
    case loading
    case success(Success)
    case failure(Failure)
}
