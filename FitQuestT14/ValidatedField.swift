import SwiftUI

struct ValidatedField: View {
    let label: String
    @Binding var text: String
    let isValid: Bool
    let keyboardType: UIKeyboardType

    var body: some View {
        TextField(label, text: $text)
            .keyboardType(keyboardType)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isValid ? Color.clear : Color.red.opacity(0.7), lineWidth: 1.5)
            )
    }
}
