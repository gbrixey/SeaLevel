import SwiftUI
import Combine
import MapKit

/// The root view of the application
struct MainView: View {
    @State private var showModalView = false
    @State private var modalViewType: ModalViewType = .searchView
    @State private var mapShowsOverlays = true
    @State private var mapShowsUserLocation = false
    @State private var programmaticMapRegion: MKCoordinateRegion?
    @ObservedObject private var seaLevelObservable = SeaLevelObservable()
    @ObservedObject private var tutorialObservable = TutorialObservable()
    @ObservedObject private var loadingObservable = ResourceManager.shared.loadingObservable

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topTrailing) {
            mapView
            VStack(alignment: .trailing, spacing: buttonPadding) {
                if !mapShowsOverlays {
                    recenterMapButton
                }
                SeaLevelSlider(seaLevel: $seaLevelObservable.seaLevel)
                userLocationButton
                searchButton
                infoButton
            }
            .animation(.easeInOut(duration: .defaultAnimationDuration))
            .padding([.top, .leading, .trailing], buttonPadding)
            if !tutorialObservable.userHasFinishedTutorial {
                TutorialView(userHasFinishedTutorial: $tutorialObservable.userHasFinishedTutorial)
            } else if loadingObservable.isLoading {
                LoadingView()
            }
        }
        .sheet(isPresented: $showModalView) {
            if self.modalViewType == .searchView {
                SearchView(programmaticMapRegion: self.$programmaticMapRegion)
            } else {
                InfoView()
            }
        }
        .alert(isPresented: $loadingObservable.shouldDisplayError) {
            errorAlert
        }
    }

    // MARK: - Private

    private let buttonPadding: CGFloat = 8

    private enum ModalViewType {
        case searchView
        case infoView
    }

    private var mapView: some View {
        MapView(seaLevel: $seaLevelObservable.seaLevel,
                mapShowsOverlays: $mapShowsOverlays,
                mapShowsUserLocation: $mapShowsUserLocation,
                programmaticMapRegion: $programmaticMapRegion)
            .environment(\.compassButtonOffset, compassButtonOffset)
            .edgesIgnoringSafeArea(.all)
    }

    /// The offset of the compass button's center point from the top right corner of the safe area.
    private var compassButtonOffset: CGPoint {
        let numberOfButtons: CGFloat = mapShowsOverlays ? 3 : 4
        let offsetX = -buttonPadding - ActionButton.size / 2
        let offsetY = buttonPadding * (numberOfButtons + 1) + ActionButton.size * (numberOfButtons + 0.5)
        return CGPoint(x: offsetX, y: offsetY)
    }

    private var recenterMapButton: some View {
        ActionButton(text: String(key: "recenter.map.button")) {
            withAnimation {
                self.programmaticMapRegion = ResourceManager.shared.currentDataSet.region
            }
        }
        .transition(.fadeAndMove(edge: .top))
    }

    private var userLocationButton: some View {
        ActionButton(imageName: mapShowsUserLocation ? "location.fill" : "location") {
            LocationManager.shared.requestLocationPermissionIfNecessary {
                self.mapShowsUserLocation.toggle()
            }
        }
    }

    private var searchButton: some View {
        ActionButton(imageName: "magnifyingglass") {
            self.modalViewType = .searchView
            self.showModalView = true
        }
    }

    private var infoButton: some View {
        ActionButton(imageName: "info.circle") {
            self.modalViewType = .infoView
            self.showModalView = true
        }
    }

    private var errorAlert: Alert {
        Alert(title: Text("error.title"),
              message: Text("error.message"),
              dismissButton: .default(Text("error.dismiss")))
    }
}

// MARK: - Observable Objects

class SeaLevelObservable: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefaultsWrapped(key: "com.glenb.SeaLevel.MainView.seaLevel", defaultValue: 0)
    fileprivate(set) var seaLevel: Double {
        willSet {
            objectWillChange.send()
        }
    }
}

class TutorialObservable: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefaultsWrapped(key: "com.glenb.SeaLevel.MainView.userHasFinishedTutorial", defaultValue: false)
    fileprivate(set) var userHasFinishedTutorial: Bool {
        willSet {
            objectWillChange.send()
        }
    }
}
