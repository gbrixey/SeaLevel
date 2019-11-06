import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var seaLevel: Double
    @Binding var mapShowsOverlays: Bool
    @Binding var mapShowsUserLocation: Bool
    @Binding var programmaticMapRegion: MKCoordinateRegion?

    /// The offset of the compass button's center point from the top right corner of the safe area.
    @Environment(\.compassButtonOffset) var compassButtonOffset: CGPoint

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MapContainerView {
        let mapView = MKMapView()
        mapView.setRegion(.defaultRegion, animated: false)
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        mapView.delegate = context.coordinator
        mapView.addOverlay(context.coordinator.overlay)
        let container = MapContainerView()
        container.mapView = mapView
        return container
    }

    func updateUIView(_ container: MapContainerView, context: Context) {
        let mapView = container.mapView!
        updateOverlaySeaLevel(context: context)
        updateShowsUserLocation(for: mapView)
        setProgrammaticMapRegion(for: mapView, context: context)
        container.setCompassButtonOffset(compassButtonOffset)
    }

    private func updateOverlaySeaLevel(context: Context) {
        // Making the tile overlay renderer reload data causes a flickering animation,
        // so don't do it unless the sea level has actually changed.
        let seaLevelInt = Int(seaLevel)
        guard seaLevelInt != context.coordinator.overlay.seaLevel else { return }
        context.coordinator.overlay.seaLevel = seaLevelInt
        context.coordinator.renderer.reloadData()
    }

    private func updateShowsUserLocation(for mapView: MKMapView) {
        LocationManager.shared.shouldTrackUserLocation = mapShowsUserLocation
        mapView.showsUserLocation = mapShowsUserLocation
    }

    private func setProgrammaticMapRegion(for mapView: MKMapView, context: Context) {
        guard let region = programmaticMapRegion else { return }
        mapView.setRegion(region, animated: context.transaction.animation != nil)
        DispatchQueue.main.async {
            self.programmaticMapRegion = nil
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var mapView: MapView
        var overlay: SeaLevelMapOverlay
        var renderer: MKTileOverlayRenderer

        init(_ mapView: MapView) {
            self.mapView = mapView
            overlay = SeaLevelMapOverlay()
            renderer = MKTileOverlayRenderer(tileOverlay: overlay)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            self.mapView.mapShowsOverlays = mapViewShowsOverlays(mapView)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            return renderer
        }

        private func mapViewShowsOverlays(_ mapView: MKMapView) -> Bool {
            // Case 1: The visible map area doesn't intersect the area with overlay data
            if !mapView.visibleMapRect.intersects(MKCoordinateRegion.defaultRegion.mapRect) {
                return false
            }
            // Case 2: If the user zooms out too far, the overlays will disappear.
            let longitudeDelta = mapView.region.span.longitudeDelta
            let mercatorRadius = 85445659.44705395
            let zoomScale = 21 - log2((longitudeDelta * mercatorRadius * .pi) / Double(180 * mapView.frame.width))
            // It seems MKMapView requests tiles at 2 zoom levels greater than the current zoom level.
            return round(zoomScale + 2) > Double(SeaLevelMapOverlay.minimumSupportedZoomLevel)
        }
    }

    // MARK: - MapContainerView

    /// View that contains the map view and a compass button
    class MapContainerView: UIView {

        var mapView: MKMapView? {
            didSet {
                subviews.forEach { $0.removeFromSuperview() }
                addMapView(mapView)
                addCompassButton(for: mapView)
            }
        }

        func setCompassButtonOffset(_ offset: CGPoint) {
            compassButtonTopSpaceConstraint?.constant = offset.y
            compassButtonTrailingSpaceConstraint?.constant = offset.x
            UIView.animate(withDuration: .defaultAnimationDuration) {
                self.layoutIfNeeded()
            }
        }

        private var compassButtonTopSpaceConstraint: NSLayoutConstraint?
        private var compassButtonTrailingSpaceConstraint: NSLayoutConstraint?

        private func addMapView(_ mapView: MKMapView?) {
            guard let mapView = mapView else { return }
            addSubview(mapView)
            mapView.translatesAutoresizingMaskIntoConstraints = false
            mapView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }

        private func addCompassButton(for mapView: MKMapView?) {
            guard let mapView = mapView else { return }
            let compassButton = MKCompassButton(mapView: mapView)
            compassButton.translatesAutoresizingMaskIntoConstraints = false
            compassButton.compassVisibility = .adaptive

            addSubview(compassButton)
            let safe = safeAreaLayoutGuide
            compassButtonTopSpaceConstraint = compassButton.centerYAnchor.constraint(equalTo: safe.topAnchor)
            compassButtonTrailingSpaceConstraint = compassButton.centerXAnchor.constraint(equalTo: safe.trailingAnchor)
            compassButtonTopSpaceConstraint?.isActive = true
            compassButtonTrailingSpaceConstraint?.isActive = true
        }
    }
}

// MARK: - Environment extension

struct CompassButtonOffsetKey: EnvironmentKey {
    static let defaultValue: CGPoint = .zero
}

extension EnvironmentValues {
    var compassButtonOffset: CGPoint {
        get {
            return self[CompassButtonOffsetKey.self]
        }
        set {
            self[CompassButtonOffsetKey.self] = newValue
        }
    }
}
