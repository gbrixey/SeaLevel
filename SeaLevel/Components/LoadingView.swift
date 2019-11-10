import SwiftUI

struct LoadingView: View {

    var body: some View {
        VStack(spacing: 20) {
            Text("loading")
                .foregroundColor(.white)
            ProgressView()
                .frame(width: 320)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.black.opacity(0.6))
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - ProgressView

struct ProgressView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .black
        progressView.progressTintColor = .white
        progressView.observedProgress = ResourceManager.shared.progress
        return progressView
    }

    func updateUIView(_ progressView: UIProgressView, context: Context) {
    }
}
