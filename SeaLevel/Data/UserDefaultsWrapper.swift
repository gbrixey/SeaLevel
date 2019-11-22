import Foundation

@propertyWrapper
struct UserDefaultsWrapped<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            return (UserDefaults.standard.object(forKey: key) as? T) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
