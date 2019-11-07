import MapKit

extension MKCoordinateRegion {

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, latDelta: CLLocationDegrees, lonDelta: CLLocationDegrees) {
        self.init(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                  span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
    }

    /// Converts the coordinate region to a map rect.
    var mapRect: MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta / 2,
                                             longitude: center.longitude - span.longitudeDelta / 2)
        let bottomRight = CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta / 2,
                                                 longitude: center.longitude + span.longitudeDelta / 2)
        // These corners are not always the top left and bottom right, hence why the name is changed.
        let cornerA = MKMapPoint(topLeft)
        let cornerB = MKMapPoint(bottomRight)
        let origin = MKMapPoint(x: min(cornerA.x, cornerB.x), y: min(cornerA.y, cornerB.y))
        let size = MKMapSize(width: abs(cornerA.x - cornerB.x), height: abs(cornerA.y - cornerB.y))
        return MKMapRect(origin: origin, size: size)
    }
}
