import SwiftUI
import ComposableArchitecture

struct CountdownView: View {
    @Environment(\.colorScheme) var colorScheme
    let store: Store<ContactsListFeature.State, ContactsListFeature.Action>
    @State private var isTimerStarted: Bool = false
    
    var body: some View {
        WithViewStore(store, observe: ({ $0 }) ) { viewStore in
            if viewStore.isSubmissionClosed {
                VStack(alignment: .center, spacing: 4) {
                    Text("Submission closed")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Text("You will be notified soon")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(24)
            } else {
                VStack(alignment: .center, spacing: 4) {
                    Text(viewStore.timestamp.timeRemaining(to: viewStore.submissionDate))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Text("Submissions close in few hours")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(24)
                .onAppear {
                    if !isTimerStarted {
                        viewStore.send(.startCountdownTimer)
                        isTimerStarted = true
                    }
                }
            }
        }
    }
}
