import SwiftUI

extension AnyTransition {
    static var expandingViewContent: AnyTransition {
        AnyTransition
            .move(edge: .leading)
            .combined(with: .opacity)
    }
}

/// Container view that expands and collapses by tapping a button
struct ExpandingView<Content: View>: View {

    let iconName: String
    let contentBuilder: () -> Content
    @State private var isExpanded = false

    init(iconName: String, @ViewBuilder builder: @escaping () -> Content) {
        self.iconName = iconName
        contentBuilder = builder
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isExpanded {
                contentBuilder()
                    .transition(.expandingViewContent)
            }
            Button(action: {
                withAnimation {
                    self.isExpanded.toggle()
                }
            }, label: {
                // This image has two frames to prevent it from appearing to move left/right when the icon changes
                Image(systemName: isExpanded ? "xmark" : iconName)
                    .frame(width: 17, height: 17, alignment: .leading)
                    .frame(width: 40, height: 40, alignment: .center)
            })
                .background(Color.white)
                .foregroundColor(.black)
        }
        .frame(minWidth: 40,
               maxWidth: isExpanded ? .infinity : 40,
               minHeight: 40,
               maxHeight: isExpanded ? .infinity : 40)
            .fixedSize(horizontal: false, vertical: isExpanded)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
    }
}
