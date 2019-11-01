import Foundation

extension String {

    init(key: String) {
        self = NSLocalizedString(key, comment: "")
    }
}
