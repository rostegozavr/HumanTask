import Foundation
import ComposableArchitecture

enum UserDefaultsKey: String {
    case submissionDate
}

struct UserDefaultsClient {
    var isSubmissionClosed: () -> Bool
    var setSubmissionDate: (Date) -> Void
    var getSubmissionDate: () -> Date
}

extension UserDefaultsClient: DependencyKey {
    static var liveValue = Self(
        isSubmissionClosed: {
            let date = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: UserDefaultsKey.submissionDate.rawValue))
            return date < Date()
        },
        setSubmissionDate: { date in
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: UserDefaultsKey.submissionDate.rawValue)
        },
        getSubmissionDate: {
            let doubleValue = UserDefaults.standard.double(forKey: UserDefaultsKey.submissionDate.rawValue)
            if doubleValue == 0 {
                return Date.distantFuture
            } else {
                return Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: UserDefaultsKey.submissionDate.rawValue))
            }
        })
}

extension DependencyValues {
    var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}
