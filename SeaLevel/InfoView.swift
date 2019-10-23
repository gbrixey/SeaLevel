import SwiftUI

struct InfoView: View {
    @State private var isExpanded = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isExpanded {
                Text("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                    .padding()
            }
            Button(action: {
                withAnimation(.easeInOut) {
                    self.isExpanded.toggle()
                }
            }, label: {
                Image(systemName: isExpanded ? "xmark" : "info.circle")
                    .frame(width: 17, height: 12, alignment: .leading)
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

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
