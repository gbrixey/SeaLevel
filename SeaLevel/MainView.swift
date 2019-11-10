import SwiftUI
import MapKit

/// The root view of the application
struct MainView: View {
    @State private var seaLevel: Double = 0
    @State private var showInfoView = false
    @State private var mapShowsOverlays = true
    @State private var mapShowsUserLocation = false
    @State private var programmaticMapRegion: MKCoordinateRegion?
    @EnvironmentObject private var resourceManager: ResourceManager

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(seaLevel: $seaLevel,
                    mapShowsOverlays: $mapShowsOverlays,
                    mapShowsUserLocation: $mapShowsUserLocation,
                    programmaticMapRegion: $programmaticMapRegion)
                .environment(\.compassButtonOffset, compassButtonOffset)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing, spacing: buttonPadding) {
                if !mapShowsOverlays {
                    ActionButton(text: String(key: "recenter.map.button")) {
                        withAnimation {
                            self.programmaticMapRegion = self.resourceManager.currentDataSet.region
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
            .animation(.easeInOut(duration: .defaultAnimationDuration))
            .padding([.top, .leading, .trailing], buttonPadding)
            if resourceManager.isLoading {
                LoadingView()
            }
        }
        .sheet(isPresented: $showInfoView) {
            InfoView()
        }
    }

    // MARK: - Private

    private let buttonPadding: CGFloat = 8

    /// The offset of the compass button's center point from the top right corner of the safe area.
    private var compassButtonOffset: CGPoint {
        let numberOfButtons: CGFloat = mapShowsOverlays ? 3 : 4
        let offsetX = -buttonPadding - ActionButton.size / 2
        let offsetY = buttonPadding * (numberOfButtons + 1) + ActionButton.size * (numberOfButtons + 0.5)
        return CGPoint(x: offsetX, y: offsetY)
    }
}
