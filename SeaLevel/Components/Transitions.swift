import SwiftUI

extension AnyTransition {

    static func fadeAndMove(edge: Edge) -> AnyTransition {
        AnyTransition
            .move(edge: edge)
            .combined(with: .opacity)
    }
}
