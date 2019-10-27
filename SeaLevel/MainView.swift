import SwiftUI

struct MainView: View {
    @State var seaLevel: Double = .initialSeaLevel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(seaLevel: $seaLevel).edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing, spacing: 10) {
                SeaLevelSlider(seaLevel: $seaLevel)
                InfoView()
            }
            .padding([.top, .leading, .trailing], 10)
        }
    }
}
