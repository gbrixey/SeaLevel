import SwiftUI

struct TutorialView: View {
    @Binding var userHasFinishedTutorial: Bool
    @State private var step: TutorialStep = .seaLevel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
                Text("tutorial.title")
                    .bold()
                Text(tutorialText)
                    .animation(nil)
                Button(action: {
                    withAnimation {
                        if self.step == .info {
                            self.userHasFinishedTutorial = true
                        } else {
                            self.step = self.step.nextStep
                        }
                    }
                }, label: {
                    Text(step == .info ? "button.done" : "button.next")
                        .frame(minWidth: 100, alignment: .center)
                })
                    .animation(nil)
            }
            .padding(20)
            .frame(width: 320)
            .fixedSize()
            .background(BlurView())
            .cornerRadius(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.black.opacity(0.6))
            .edgesIgnoringSafeArea(.all)

            VStack(alignment: .trailing, spacing: buttonPadding) {
                fakeButton(step: .seaLevel)
                fakeButton(step: .location)
                fakeButton(step: .search)
                fakeButton(step: .info)
            }
            .animation(.easeInOut(duration: .defaultAnimationDuration))
            .padding([.top, .leading, .trailing], buttonPadding)
        }

    }

    // MARK: - Private

    private enum TutorialStep: CaseIterable {
        case seaLevel
        case location
        case search
        case info

        var imageName: String {
            switch self {
            case .seaLevel: return "slider.horizontal.3"
            case .location: return "location"
            case .search: return "magnifyingglass"
            case .info: return "info.circle"
            }
        }

        var nextStep: TutorialStep {
            switch self {
            case .seaLevel: return .location
            case .location: return .search
            case .search, .info: return .info
            }
        }
    }

    private let buttonPadding: CGFloat = 8

    private var tutorialText: String {
        switch step {
        case .seaLevel: return String(key: "tutorial.sea.level")
        case .location: return String(key: "tutorial.location")
        case .search: return String(key: "tutorial.search")
        case .info: return String(key: "tutorial.info")
        }
    }

    private func fakeButton(step: TutorialStep) -> some View {
        Image(systemName: step.imageName)
            .frame(width: ActionButton.size, height: ActionButton.size, alignment: .center)
            .foregroundColor(Color(.label))
            .background(BlurView())
            .cornerRadius(20)
            .shadow(radius: 10)
            .opacity(step == self.step ? 1 : 0)
    }
}
