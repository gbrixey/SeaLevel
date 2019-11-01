import SwiftUI

/// Expanding view that contains some info about the app.
struct InfoView: View {
    var body: some View {
        ExpandingView(iconName: "info.circle") {
            VStack(alignment: .leading, spacing: 10) {
                Text("info.title").bold()
                Text("info.paragraph.one")
                Text("info.paragraph.two")
            }.padding()
        }
    }
}
