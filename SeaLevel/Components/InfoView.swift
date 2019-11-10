import SwiftUI

/// Modally presented view that contains some info about the app.
struct InfoView: View {
    @Environment(\.presentationMode) var presentation

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 15) {
                    Text("info.introduction")
                    Text("info.current.data.title").bold()
                    Text(ResourceManager.shared.currentDataSet.infoTitle)
                    Text(ResourceManager.shared.currentDataSet.infoText)
                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitle("info.title")
            .navigationBarItems(trailing: doneButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var doneButton: some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
        }, label: {
            Text("button.done")
        })
    }
}
