import SwiftUI
import MapKit

struct SearchView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var programmaticMapRegion: MKCoordinateRegion?
    @ObservedObject private var dataIndexObservable = DataIndexObservable()
    @ObservedObject private var reachabilityObservable = ReachabilityManager.shared.observable
    @ObservedObject private var dataSetAvailabilityObservable = DataSetAvailabilityObservable()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Text("search.subtitle")
                self.dataPicker
                Text(selectedDataSet.infoTitle)
                if !self.dataSetAvailabilityObservable.isDataSetAvailable {
                    Text(dataSizeText)
                        .bold()
                    if !reachabilityObservable.isConnectedToInternet {
                        Text("search.internet.warning")
                            .bold()
                    } else if !reachabilityObservable.isConnectedToWifi {
                        Text("search.wifi.warning")
                            .bold()
                    }
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
        DataSet.allCases[dataIndexObservable.dataIndex]
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
        Picker("", selection: $dataIndexObservable.dataIndex) {
            ForEach((0..<DataSet.allCases.count), id: \.self) {
                Text(DataSet.allCases[$0].searchTitle)
            }
        }
        .onReceive(dataIndexObservable.$dataIndex, perform: { dataIndex in
            self.dataSetAvailabilityObservable.checkDataSet(DataSet.allCases[dataIndex])
        })
        .labelsHidden()
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Observable Objects

class DataIndexObservable: ObservableObject {
    @Published var dataIndex: Int = ResourceManager.shared.currentDataSet.index
}

class DataSetAvailabilityObservable: ObservableObject {
    @Published fileprivate(set) var isDataSetAvailable: Bool = false

    /// Checks if the given data set is stored on disk, and updates the `isDataSetAvailable` with the result.
    func checkDataSet(_ dataSet: DataSet) {
        self.dataSet = dataSet
        ResourceManager.shared.checkIfDataSetIsAvailable(dataSet) { isDataSetAvailable in
            DispatchQueue.main.async {
                guard self.dataSet == dataSet else { return }
                self.isDataSetAvailable = isDataSetAvailable
            }
        }
    }

    private var dataSet: DataSet?
}
