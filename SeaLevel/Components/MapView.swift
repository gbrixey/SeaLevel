import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        let coordinate = CLLocationCoordinate2D(latitude: 40.7, longitude: -74)
        let span = MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
