import SwiftUI

/// Modally presented view that contains some info about the app.
struct InfoView: View {
    @Environment(\.presentationMode) var presentation

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("info.paragraph.one")
                        Text("info.current.data.title").bold()
                        Text("info.srtm.title.nyc")
                        Text("info.srtm.text")
                        Spacer()
                    }.padding()
                }
            }
            .navigationBarTitle("info.title")
            .navigationBarItems(trailing: closeButton)
        }
    }

    private var closeButton: some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
                .foregroundColor(Color(.label))
        })
            .padding([.top, .leading, .bottom], 10)
    }
}
