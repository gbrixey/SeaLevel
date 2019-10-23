import SwiftUI

struct SeaLevelSlider: View {
    @State var sliderValue = 0.0
    @State private var isExpanded = false

    var body: some View {
        HStack(alignment: .top) {
            if isExpanded {
                Text("\(Int(round(sliderValue))) m")
                    .frame(width: 50, height: 40, alignment: .center)
                    .padding(.leading, 10)
                Slider(value: $sliderValue, in: 0...100)
                    .frame(height: 40, alignment: .center)
            }
            Button(action: {
                withAnimation(.easeInOut) {
                    self.isExpanded.toggle()
                }
            }, label: {
                Image(systemName: isExpanded ? "xmark" : "slider.horizontal.3")
                    .frame(width: 17, height: 12, alignment: .leading)
                    .frame(width: 40, height: 40, alignment: .center)
            })
                .background(Color.white)
                .foregroundColor(.black)
        }
        .frame(height: 40)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

struct SeaLevelSlider_Previews: PreviewProvider {
    static var previews: some View {
        SeaLevelSlider()
    }
}
