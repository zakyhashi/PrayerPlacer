//
//  Prayer Space view .swift
//  PrayerPlacer
//
//  Created by Zaky Hashi on 2025-04-18.
//

import Foundation
import SwiftUI

struct AddPrayerSpaceView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var prayerSpaces: [PrayerSpace]
    var locationManager: LocationManager
    @State private var name: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Prayer Space")) {
                    TextField("Name", text: $name)
                    if let userLocation = locationManager.lastLocation {
                        Text("Lat: \(userLocation.coordinate.latitude), Lon: \(userLocation.coordinate.longitude)")
                    } else {
                        Text("Fetching your location...")
                    }
                }
                Button("Add") {
                    if let loc = locationManager.lastLocation {
                        let new = PrayerSpace(name: name, coordinate: loc.coordinate)
                        prayerSpaces.append(new)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(name.isEmpty)
            }
            .navigationTitle("Suggest Location")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
