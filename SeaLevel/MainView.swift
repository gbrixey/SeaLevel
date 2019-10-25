import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView().edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing, spacing: 10) {
                SeaLevelSlider()
                InfoView()
            }
            .padding([.top, .leading, .trailing], 10)
        }
    }
}
