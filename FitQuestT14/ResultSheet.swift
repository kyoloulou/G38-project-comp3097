import SwiftUI

struct ResultSheet: View {
    let calories: Double
    let onSave: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Result")
                .font(.largeTitle)
                .bold()

            Text("Calories Burned:")
            Text("\(calories, specifier: "%.2f")")
                .font(.title)
                .bold()
                .foregroundColor(.orange)

            Button("Save & Close") { onSave() }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

            Button("Close") { onClose() }
                .padding()
        }
        .padding()
    }
}
