import SwiftUI

extension Double {

    static var defaultAnimationDuration: Double { 0.3 }
}

extension AnyTransition {

    static func fadeAndMove(edge: Edge) -> AnyTransition {
        AnyTransition
            .move(edge: edge)
            .combined(with: .opacity)
    }
}
