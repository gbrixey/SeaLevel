import SwiftUI

struct InfoView: View {
    var body: some View {
        ExpandingView(iconName: "info.circle") {
            VStack(alignment: .leading, spacing: 10) {
                Text(String(key: "info.title")).bold()
                Text(String(key: "info.paragraph.one"))
                Text(String(key: "info.paragraph.two"))
            }.padding()
        }
    }
}
