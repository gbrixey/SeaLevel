import SwiftUI

/// SwiftUI wrapper for a `UIVisualEffectView` with `UIBlurEffect`
struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }

    func updateUIView(_ view: UIVisualEffectView, context: Context) {
    }
}
