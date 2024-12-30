import SwiftUI

struct SparklineShape: Shape {
    var data: [Double]
    var shouldFill: Bool
    
    init(data: [Double], shouldFill: Bool) {
        let maxPoint = data.max() ?? 1.0
        var translatedData: [Double] = []
        for item in data {
            translatedData.append(item / maxPoint)
        }
        self.data = translatedData
        self.shouldFill = shouldFill
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: rect.minX, y: rect.maxY - ((data.first ?? 0.0) * rect.height))
        path.move(to: start)
        var point = CGPoint()
        var control1 = CGPoint()
        var control2 = CGPoint()
        for (index, value) in data.enumerated() {
            if index != 0 {
                 point = CGPoint(x: rect.minX + (rect.width / CGFloat(data.count - 1) * CGFloat(index)), y: rect.maxY - (value * rect.height) )
                 control2 = CGPoint(x: rect.minX + (rect.width / CGFloat(data.count - 1) * (CGFloat(index) - 0.4)), y: rect.maxY - (value * rect.height) )
                 path.addCurve(to: point, control1: control1, control2: control2)
             }
             control1 = CGPoint(x: rect.minX + (rect.width / CGFloat(data.count - 1) * (CGFloat(index) + 0.4)), y: rect.maxY - (value * rect.height) )
        }
        if shouldFill {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: start)
        }
        return path
    }
}

struct SparklineView: View {
    var data: [Double]
    
    var body: some View {
        ZStack {
            SparklineShape(data: data, shouldFill: true)
                .fill(
                    LinearGradient(colors: [Color.blue.opacity(0.2), Color.clear], startPoint: .top, endPoint: .bottom)
                )
            SparklineShape(data: data, shouldFill: false)
                .stroke(style: .init(lineWidth: 1.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
        }
    }
}

struct ChartTestView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            SparklineView(data: [7, 8, 10, 4, 15, 4, 6])
        }
        .frame(height: 300.0)
    }
}
