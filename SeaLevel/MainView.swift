import SwiftUI
import MapKit

struct MainView: View {
    @State var seaLevel: Double = .initialSeaLevel
    @State var showInfoView = false
    @State var mapShowsOverlays = true
    @State var programmaticMapRegion: MKCoordinateRegion?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(seaLevel: $seaLevel,
                    mapShowsOverlays: $mapShowsOverlays,
                    programmaticMapRegion: $programmaticMapRegion)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing, spacing: 10) {
                if !mapShowsOverlays {
                    ActionButton(text: String(key: "recenter.map.button")) {
                        withAnimation {
                            self.programmaticMapRegion = .defaultRegion
                        }
                    }
                    .transition(.fadeAndMove(edge: .top))
                }
                SeaLevelSlider(seaLevel: $seaLevel)
                ActionButton(imageName: "info.circle") {
                    self.showInfoView.toggle()
                }
            }
            .animation(.easeInOut)
            .padding([.top, .leading, .trailing], 10)
        }
        .sheet(isPresented: $showInfoView) {
            InfoView()
        }
    }
}

private extension Double {

    /// The initial sea level is 1.0 so that the app will start off showing overlay tiles.
    /// If the sea level is set to 0, then no tiles are shown, because the map already reflects the current sea level.
    static var initialSeaLevel: Double { 1.0 }
}
