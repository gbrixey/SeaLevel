enum DataSet: String {
    case londonSRTM
    case newYorkCitySRTM

    var resourceName: String {
        return rawValue
    }
}
