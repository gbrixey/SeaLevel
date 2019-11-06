import SwiftUI
import MapKit

/// The root view of the application
struct MainView: View {
    @State private var seaLevel: Double = .initialSeaLevel
    @State private var showInfoView = false
    @State private var mapShowsOverlays = true
    @State private var mapShowsUserLocation = false
    @State private var programmaticMapRegion: MKCoordinateRegion?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(seaLevel: $seaLevel,
                    mapShowsOverlays: $mapShowsOverlays,
                    mapShowsUserLocation: $mapShowsUserLocation,
                    programmaticMapRegion: $programmaticMapRegion)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing, spacing: 8) {
                if !mapShowsOverlays {
                    ActionButton(text: String(key: "recenter.map.button")) {
                        withAnimation {
                            self.programmaticMapRegion = .defaultRegion
                        }
                    }
                    .transition(.fadeAndMove(edge: .top))
                }
                SeaLevelSlider(seaLevel: $seaLevel)
                ActionButton(imageName: mapShowsUserLocation ? "location.fill" : "location") {
                    LocationManager.shared.requestLocationPermissionIfNecessary {
                        self.mapShowsUserLocation.toggle()
                    }
                }
                ActionButton(imageName: "info.circle") {
                    self.showInfoView.toggle()
                }
            }
            .animation(.easeInOut)
            .padding([.top, .leading, .trailing], 8)
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
