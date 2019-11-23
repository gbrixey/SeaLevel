import MapKit

enum DataSet: String, CaseIterable {
    case amsterdamSRTM
    case athensSRTM
    case aucklandSRTM
    case bangkokSRTM
    case barcelonaSRTM
    case berlinSRTM
    case brusselsSRTM
    case buenosAiresSRTM
    case cairoSRTM
    case capeTownSRTM
    case chennaiSRTM
    case copenhagenSRTM
    case dhakaSRTM
    case dubaiSRTM
    case dublinSRTM
    case edinburghSRTM
    case guangzhouSRTM
    case hanoiSRTM
    case havanaSRTM
    case hoChiMinhCitySRTM
    case hongKongSRTM
    case istanbulSRTM
    case jakartaSRTM
    case karachiSRTM
    case kolkataSRTM
    case kualaLumpurSRTM
    case lagosSRTM
    case limaSRTM
    case lisbonSRTM
    case londonSRTM
    case manilaSRTM
    case melbourneSRTM
    case miamiSRTM
    case montrealSRTM
    case mumbaiSRTM
    case newYorkCitySRTM
    case osakaSRTM
    case panamaCanalSRTM
    case parisSRTM
    case phnomPenhSRTM
    case pyongyangSRTM
    case rioDeJaneiroSRTM
    case romeSRTM
    case seoulSRTM
    case shanghaiSRTM
    case singaporeSRTM
    case stockholmSRTM
    case sydneySRTM
    case taipeiSRTM
    case telAvivSRTM
    case tokyoSRTM
    case veniceSRTM

    var resourceName: String {
        return rawValue
    }

    var index: Int {
        return DataSet.allCases.firstIndex(of: self)!
    }

    // MARK: - Metadata
    // This metadata could also be stored in a file instead of hardcoded for each enum case.

    var region: MKCoordinateRegion {
        let tuple: (CLLocationDegrees, CLLocationDegrees, CLLocationDegrees, CLLocationDegrees)
        switch self {
        case .amsterdamSRTM:     tuple = ( 52.321911,    4.833984, 0.322, 0.879)
        case .athensSRTM:        tuple = ( 37.996163,   23.730469, 0.554, 0.703)
        case .aucklandSRTM:      tuple = (-36.879621,  174.726562, 0.562, 0.703)
        case .bangkokSRTM:       tuple = ( 13.752725,  100.546875, 0.683, 0.703)
        case .barcelonaSRTM:     tuple = ( 41.442726,    2.109375, 0.395, 0.703)
        case .berlinSRTM:        tuple = ( 52.482780,   13.359375, 0.428, 0.703)
        case .brusselsSRTM:      tuple = ( 50.847573,    4.394531, 0.222, 0.352)
        case .buenosAiresSRTM:   tuple = (-34.597042,  -58.447266, 0.579, 0.879)
        case .cairoSRTM:         tuple = ( 30.069094,   31.201172, 0.456, 0.879)
        case .capeTownSRTM:      tuple = (-34.089061,   18.632812, 0.728, 0.703)
        case .chennaiSRTM:       tuple = ( 13.068777,   80.244141, 0.685, 0.527)
        case .copenhagenSRTM:    tuple = ( 55.677584,   12.744141, 0.396, 0.879)
        case .dhakaSRTM:         tuple = ( 23.805450,   90.439453, 0.482, 0.527)
        case .dubaiSRTM:         tuple = ( 25.165173,   55.283203, 0.636, 0.879)
        case .dublinSRTM:        tuple = ( 53.330873,   -6.328125, 0.420, 0.703)
        case .edinburghSRTM:     tuple = ( 55.973798,   -3.251953, 0.197, 0.527)
        case .guangzhouSRTM:     tuple = ( 23.160563,  113.291016, 0.808, 0.527)
        case .hanoiSRTM:         tuple = ( 21.043491,  105.820312, 0.492, 0.703)
        case .havanaSRTM:        tuple = ( 23.079732,  -82.265625, 0.323, 0.703)
        case .hoChiMinhCitySRTM: tuple = ( 10.746969,  106.787109, 0.863, 0.879)
        case .hongKongSRTM:      tuple = ( 22.431340,  114.082031, 0.650, 0.703)
        case .istanbulSRTM:      tuple = ( 41.046217,   29.003906, 0.663, 1.055)
        case .jakartaSRTM:       tuple = ( -6.315299,  106.787109, 0.699, 0.527)
        case .karachiSRTM:       tuple = ( 24.926295,   67.060547, 0.478, 0.879)
        case .kolkataSRTM:       tuple = ( 22.674847,   88.330078, 0.811, 0.527)
        case .kualaLumpurSRTM:   tuple = (  3.074695,  101.513672, 0.527, 0.879)
        case .lagosSRTM:         tuple = (  6.577303,    3.339844, 0.524, 0.703)
        case .limaSRTM:          tuple = (-12.039321,  -77.080078, 0.688, 0.527)
        case .lisbonSRTM:        tuple = ( 38.685510,   -9.140625, 0.549, 0.703)
        case .londonSRTM:        tuple = ( 51.508742,   -0.175781, 0.438, 0.703)
        case .manilaSRTM:        tuple = ( 14.604847,  121.025391, 0.680, 0.527)
        case .melbourneSRTM:     tuple = (-37.857507,  145.019531, 0.555, 0.703)
        case .miamiSRTM:         tuple = ( 26.194877,  -80.244141, 1.735, 0.527)
        case .montrealSRTM:      tuple = ( 45.583290,  -73.652344, 0.492, 0.703)
        case .mumbaiSRTM:        tuple = ( 19.145168,   72.949219, 0.664, 0.703)
        case .newYorkCitySRTM:   tuple = ( 40.713956,  -74.003906, 0.533, 0.703)
        case .osakaSRTM:         tuple = ( 34.597042,  135.351562, 0.579, 0.703)
        case .panamaCanalSRTM:   tuple = (  9.102097,  -79.628906, 0.694, 0.703)
        case .parisSRTM:         tuple = ( 48.864715,    2.373047, 0.347, 0.527)
        case .phnomPenhSRTM:     tuple = ( 11.609193,  104.853516, 0.517, 0.527)
        case .pyongyangSRTM:     tuple = ( 39.095963,  125.771484, 0.546, 0.527)
        case .rioDeJaneiroSRTM:  tuple = (-22.917923,  -43.330078, 0.648, 0.879)
        case .romeSRTM:          tuple = ( 41.902277,   12.480469, 0.523, 0.703)
        case .seoulSRTM:         tuple = ( 37.509726,  126.738281, 0.418, 1.055)
        case .shanghaiSRTM:      tuple = ( 31.203405,  121.552734, 0.601, 0.879)
        case .singaporeSRTM:     tuple = (  1.318243,  103.886719, 0.527, 0.703)
        case .stockholmSRTM:     tuple = ( 59.355596,   18.105469, 0.358, 0.703)
        case .sydneySRTM:        tuple = (-33.870416,  150.908203, 0.584, 0.879)
        case .taipeiSRTM:        tuple = ( 25.085599,  121.464844, 0.478, 0.703)
        case .telAvivSRTM:       tuple = ( 32.026706,   34.804688, 0.447, 0.352)
        case .tokyoSRTM:         tuple = ( 35.675147,  139.833984, 0.714, 0.879)
        case .veniceSRTM:        tuple = ( 45.336702,   12.480469, 0.494, 0.703)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: tuple.0, longitude: tuple.1),
                                  span: MKCoordinateSpan(latitudeDelta: tuple.2, longitudeDelta: tuple.3))
    }

    /// Size of the data set in megabytes (base-10)
    var size: Double {
        switch self {
        case .amsterdamSRTM:    return 10.4
        case .athensSRTM:       return 28.3
        case .aucklandSRTM:     return 53.3
        case .bangkokSRTM:      return 27.2
        case .barcelonaSRTM:    return 13.4
        case .berlinSRTM:       return 31.5
        case .brusselsSRTM:     return 10.0
        case .buenosAiresSRTM:  return 28.9
        case .cairoSRTM:        return 26.3
        case .capeTownSRTM:     return 27.1
        case .chennaiSRTM:      return 17.3
        case .copenhagenSRTM:   return 19.1
        case .dhakaSRTM:        return 15.9
        case .dubaiSRTM:        return 35.1
        case .dublinSRTM:       return 18.9
        case .edinburghSRTM:    return 10.7
        case .guangzhouSRTM:    return 64.1
        case .hanoiSRTM:        return 29.1
        case .havanaSRTM:       return 13.8
        case .hoChiMinhCitySRTM:return 58.7
        case .hongKongSRTM:     return 61.9
        case .istanbulSRTM:     return 63.8
        case .jakartaSRTM:      return 19.9
        case .karachiSRTM:      return 28.5
        case .kolkataSRTM:      return 27.0
        case .kualaLumpurSRTM:  return 43.2
        case .lagosSRTM:        return 30.3
        case .limaSRTM:         return 10.7
        case .lisbonSRTM:       return 33.7
        case .londonSRTM:       return 34.6
        case .manilaSRTM:       return 25.9
        case .melbourneSRTM:    return 31.2
        case .miamiSRTM:        return 49.1
        case .montrealSRTM:     return 29.3
        case .mumbaiSRTM:       return 47.8
        case .newYorkCitySRTM:  return 39.6
        case .osakaSRTM:        return 29.0
        case .panamaCanalSRTM:  return 39.4
        case .parisSRTM:        return 20.1
        case .phnomPenhSRTM:    return 17.5
        case .pyongyangSRTM:    return 47.5
        case .rioDeJaneiroSRTM: return 62.4
        case .romeSRTM:         return 31.8
        case .seoulSRTM:        return 62.9
        case .shanghaiSRTM:     return 26.4
        case .singaporeSRTM:    return 37.9
        case .stockholmSRTM:    return 45.8
        case .sydneySRTM:       return 55.5
        case .taipeiSRTM:       return 26.0
        case .telAvivSRTM:      return 13.5
        case .tokyoSRTM:        return 74.0
        case .veniceSRTM:       return 4.6
        }
    }

    var infoTitle: String {
        return String(format: String(key: "info.title.format.srtm"), String(key: "info.title.\(resourceName)"))
    }

    var infoText: String {
        return String(key: "info.srtm.text")
    }

    var searchTitle: String {
        return String(key: "search.\(resourceName)")
    }
}
