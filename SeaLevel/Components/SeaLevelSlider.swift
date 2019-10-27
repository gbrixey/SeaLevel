import SwiftUI

/// Slider that allows the user to raise the sea level.
struct SeaLevelSlider: View {
    @Binding var seaLevel: Double

    var body: some View {
        ExpandingView(iconName: "slider.horizontal.3") {
            HStack {
                Text(self.sliderText)
                    .frame(width: 50, height: 40, alignment: .center)
                    .padding(.leading, 10)
                Slider(value: self.$seaLevel, in: 0...100, step: 1.0)
                    .frame(height: 40, alignment: .center)
                    .padding(.trailing, 50)
            }
        }
    }

    var sliderText: String {
        let format = String(key: "meters.format")
        return String(format: format, Int(seaLevel))
    }
}
