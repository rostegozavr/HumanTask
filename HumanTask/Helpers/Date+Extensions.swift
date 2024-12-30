import Foundation

extension Date {
    func timeRemaining(to targetDate: Date) -> String {
        let timeInterval = targetDate.timeIntervalSince(self)
        if timeInterval <= 0 {
            return "00:00:00"
        }
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
