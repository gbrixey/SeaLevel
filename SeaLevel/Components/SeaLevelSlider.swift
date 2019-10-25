import SwiftUI

struct SeaLevelSlider: View {
    @State private var sliderValue = 0.0

    var body: some View {
        ExpandingView(iconName: "slider.horizontal.3") {
            HStack {
                Text("\(Int(round(self.sliderValue))) m")
                    .frame(width: 50, height: 40, alignment: .center)
                    .padding(.leading, 10)
                Slider(value: self.$sliderValue, in: 0...100)
                    .frame(height: 40, alignment: .center)
                    .padding(.trailing, 10)
            }
        }
    }
}
