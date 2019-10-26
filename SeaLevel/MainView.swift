import SwiftUI

struct MainView: View {
    @State var elevation = 1.0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(elevation: $elevation).edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing, spacing: 10) {
                SeaLevelSlider(sliderValue: $elevation)
                InfoView()
            }
            .padding([.top, .leading, .trailing], 10)
        }
    }
}
