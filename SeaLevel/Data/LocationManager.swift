import CoreLocation

/// Class responsible for finding the user's current location
class LocationManager: NSObject {

    // MARK: - Public

    static let shared = LocationManager()

    func requestLocationPermissionIfNecessary(then block: @escaping () -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            blockToExecuteAfterRequestingLocation = block
            manager.requestWhenInUseAuthorization()
        default:
            block()
        }
    }

    var shouldTrackUserLocation: Bool = false {
        didSet {
            guard shouldTrackUserLocation != oldValue else { return }
            let status = CLLocationManager.authorizationStatus()
            guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
            if shouldTrackUserLocation {
                manager.startUpdatingLocation()
            } else {
                manager.stopUpdatingLocation()
            }
        }
    }

    // MARK: - Overrides

    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }

    // MARK: - Private

    private let manager: CLLocationManager = CLLocationManager()

    private var blockToExecuteAfterRequestingLocation: (() -> Void)?
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        blockToExecuteAfterRequestingLocation?()
        blockToExecuteAfterRequestingLocation = nil
    }
}
