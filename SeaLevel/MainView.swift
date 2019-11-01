import SwiftUI
import MapKit

struct MainView: View {
    @State var seaLevel: Double = .initialSeaLevel
    @State var mapShowsOverlays: Bool = true
    @State var programmaticMapRegion: MKCoordinateRegion? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapView(seaLevel: $seaLevel,
                    mapShowsOverlays: $mapShowsOverlays,
                    programmaticMapRegion: $programmaticMapRegion)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing, spacing: 10) {
                if !mapShowsOverlays {
                    recenterMapButton
                        .transition(.fadeAndMove(edge: .top))
                }
                SeaLevelSlider(seaLevel: $seaLevel)
                InfoView()
            }
            .animation(.easeInOut)
            .padding([.top, .leading, .trailing], 10)
        }
    }

    private var recenterMapButton: some View {
        Button(action: {
            withAnimation {
                self.programmaticMapRegion = .defaultRegion
            }
        }, label: {
            Text("recenter.map.button")
                .font(.system(size: 12, weight: .bold))
                .padding([.leading, .trailing], 20)
                .frame(height: 40, alignment: .center)
        })
            .foregroundColor(Color(.label))
            .background(BlurView())
            .cornerRadius(20)
            .shadow(radius: 10)
    }
}

private extension Double {

    /// The initial sea level is 1.0 so that the app will start off showing overlay tiles.
    /// If the sea level is set to 0, then no tiles are shown, because the map already reflects the current sea level.
    static var initialSeaLevel: Double { 1.0 }
}
