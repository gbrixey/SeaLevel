import SwiftUI
import MapKit

struct SearchView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var programmaticMapRegion: MKCoordinateRegion?
    @State private var dataIndex = ResourceManager.shared.currentDataSet.index
    @ObservedObject private var reachabilityObservable = ReachabilityManager.shared.observable

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Text("search.subtitle")
                self.dataPicker
                Text(selectedDataSet.infoTitle)
                Text(dataSizeText)
                    .bold()
                if !reachabilityObservable.isConnectedToInternet {
                    Text("search.internet.warning")
                        .bold()
                } else if !reachabilityObservable.isConnectedToWifi {
                    Text("search.wifi.warning")
                        .bold()
                }
                Text(selectedDataSet.infoText)
                Spacer()
            }
            .padding(20)
            .navigationBarTitle("search.title")
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Private

    private var selectedDataSet: DataSet {
        DataSet.allCases[dataIndex]
    }

    private var dataSizeText: String {
        let format = String(key: "search.data.size.format")
        return String(format: format, selectedDataSet.size)
    }

    private var cancelButton: some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
        }, label: {
            Text("button.cancel")
        })
    }

    private var doneButton: some View {
        Button(action: {
            if self.reachabilityObservable.isConnectedToInternet &&
                self.selectedDataSet != ResourceManager.shared.currentDataSet {
                self.programmaticMapRegion = self.selectedDataSet.region
                ResourceManager.shared.requestDataSet(self.selectedDataSet)
            }
            self.presentation.wrappedValue.dismiss()
        }, label: {
            Text("button.done")
        })
    }

    private var dataPicker: some View {
        Picker("", selection: $dataIndex) {
            ForEach((0..<DataSet.allCases.count), id: \.self) {
                Text(DataSet.allCases[$0].searchTitle)
            }
        }
        .labelsHidden()
        .frame(maxWidth: .infinity)
    }
}
