import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var seaLevel: Double
    @Binding private(set) var mapShowsOverlays: Bool
    @Binding var programmaticMapRegion: MKCoordinateRegion?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(.defaultRegion, animated: false)
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if let region = programmaticMapRegion {
            mapView.setRegion(region, animated: context.transaction.animation != nil)
            DispatchQueue.main.async {
                self.programmaticMapRegion = nil
            }
        }
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(SeaLevelMapOverlay(seaLevel: Int(seaLevel)))
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var mapView: MapView

        init(_ mapView: MapView) {
            self.mapView = mapView
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            self.mapView.mapShowsOverlays = mapViewShowsOverlays(mapView)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            MKTileOverlayRenderer(overlay: overlay)
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
}
