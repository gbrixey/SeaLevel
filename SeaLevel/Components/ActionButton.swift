import SwiftUI

/// A button with a `BlurView` background capable of showing a
struct ActionButton: View {

    let imageName: String
    let text: String
    let action: () -> Void

    init(imageName: String = "", text: String = "", action: @escaping () -> Void) {
        self.imageName = imageName
        self.text = text
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if !imageName.isEmpty {
                    Image(systemName: imageName)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                if !text.isEmpty {
                    Text(text)
                        .font(.system(size: 12, weight: .bold))
                        .padding([.leading, .trailing], 20)
                        .frame(height: 40, alignment: .center)
                }
            }
        }
        .foregroundColor(Color(.label))
        .background(BlurView())
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
