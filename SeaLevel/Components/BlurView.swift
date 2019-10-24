import SwiftUI

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }

    func updateUIView(_ view: UIVisualEffectView, context: Context) {
    }
}


struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        BlurView()
    }
}
