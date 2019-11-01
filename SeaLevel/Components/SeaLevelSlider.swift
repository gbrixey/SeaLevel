import SwiftUI

/// Slider that allows the user to raise the sea level.
struct SeaLevelSlider: View {
    @Binding var seaLevel: Double

    var body: some View {
        ExpandingView(iconName: "slider.horizontal.3") {
            HStack {
                // I tried to use a Text component for this, but when the text changed, it would often get truncated
                // before animating to its new size. Using a TextField seems to solve that issue.
                TextField("", value: self.$seaLevel, formatter: SeaLevelFormatter())
                    .disabled(true)
                    .frame(width: 50, height: 40, alignment: .center)
                    .padding(.leading, 15)
                Slider(value: self.$seaLevel, in: 0...100, step: 1.0)
                    .frame(height: 40, alignment: .center)
                    .padding(.trailing, 50)
            }
        }
    }

    private class SeaLevelFormatter: Formatter {
        override func string(for obj: Any?) -> String? {
            guard let seaLevel = obj as? Double else { return nil }
            let format = String(key: "meters.format")
            return String(format: format, Int(seaLevel))
        }

        override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                     for string: String,
                                     errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
            let digits = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let seaLevel = Double(digits) ?? 0.0
            obj?.pointee = NSNumber(value: seaLevel)
            return true
        }
    }
}
