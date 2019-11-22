import Foundation
import Reachability

/// Class that monitors internet connectivity
class ReachabilityManager {

    // MARK: - Public

    static let shared = ReachabilityManager()
    let observable = ReachabilityObservable()

    // MARK: - Private

    private let reachability: Reachability?

    private init() {
        reachability = try? Reachability()
        reachability?.whenReachable = { reachability in
            self.observable.isConnectedToInternet = true
            self.observable.isConnectedToWifi = reachability.connection == .wifi
        }
        reachability?.whenUnreachable = { reachability in
            self.observable.isConnectedToInternet = false
            self.observable.isConnectedToWifi = false
        }
        try? reachability?.startNotifier()
    }
}

// MARK: - Observable Objects

class ReachabilityObservable: ObservableObject {
    @Published fileprivate(set) var isConnectedToInternet: Bool = false
    @Published fileprivate(set) var isConnectedToWifi: Bool = false
}

