import SwiftUI

struct LoadingView: View {
    @EnvironmentObject private var resourceManager: ResourceManager

    var body: some View {
        VStack(spacing: 20) {
            Text("loading")
                .foregroundColor(.white)
            ProgressView()
                .frame(width: 320)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - ProgressView

struct ProgressView: UIViewRepresentable {
    @EnvironmentObject private var resourceManager: ResourceManager

    func makeUIView(context: Context) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .darkGray
        progressView.progressTintColor = .white
        progressView.observedProgress = resourceManager.progress
        return progressView
    }

    func updateUIView(_ progressView: UIProgressView, context: Context) {
    }
}
