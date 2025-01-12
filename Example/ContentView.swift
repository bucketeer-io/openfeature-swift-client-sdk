import SwiftUI
import BucketeerOpenFeature

struct ContentView: View {

    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            if viewModel.showNewFeature {
                Text("Should show new feature")
            } else {
                Text("Should not show new feature")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
