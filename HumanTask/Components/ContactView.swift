import SwiftUI

struct ContactView: View {    
    let name: String
    let username: String
    let marketCap: String
    let data: [Double]

    var body: some View {
        HStack(spacing: 12) {
            Image("avatar")
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("$")
                    .font(.subheadline)
                    .foregroundColor(.gray) +
                Text("\(marketCap)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                VStack {
                    SparklineView(data: data)
                }
                .frame(width: 50, height: 20)
            }
        }
        .padding()
    }
}
