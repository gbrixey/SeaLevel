import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(.defaultRegion, animated: false)
        mapView.showsCompass = false
        mapView.delegate = context.coordinator
        mapView.addOverlay(SeaLevelMapOverlay())
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var mapView: MapView

        init(_ mapView: MapView) {
            self.mapView = mapView
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            MKTileOverlayRenderer(overlay: overlay)
        }
    }
}
