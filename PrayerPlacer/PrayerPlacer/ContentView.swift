//
//  ContentView.swift
//  PrayerPlacer
//
//  Created by Zaky Hashi on 2025-04-17.
//

// MARK: - Prayer Placer App (SwiftUI Version)
// --------------------------------------------
// This version uses SwiftUI to display a map with prayer locations,
// user’s current location, and a dynamic prayer time button.
import SwiftUI
import MapKit
import CoreLocation

// MARK: - Prayer Space Model
struct PrayerSpace: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}



// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var prayerSpaces = [
        PrayerSpace(name: "Masjid Toronto", coordinate: CLLocationCoordinate2D(latitude: 43.655, longitude: -79.38)),
        PrayerSpace(name: "George Brown Prayer Room", coordinate: CLLocationCoordinate2D(latitude: 43.670, longitude: -79.375))
    ]
    
    @State private var nextPrayer = "DHUR 1:32 PM"
    @State private var showQibla = false
    @State private var showAddPrayer = false
    @State private var showSettings = false
    @State private var searchText = ""

    var filteredPrayerSpaces: [PrayerSpace] {
        if searchText.isEmpty {
            return prayerSpaces
        } else {
            return prayerSpaces.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: filteredPrayerSpaces) { space in
                    MapMarker(coordinate: space.coordinate, tint: .blue)
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    updateNextPrayer()
                    if let loc = locationManager.lastLocation {
                        region.center = loc.coordinate
                    }
                }

                VStack {
                    // Top prayer button
                    HStack {
                        Spacer()
                        NavigationLink(destination: PrayerTimesView()) {
                            Text(nextPrayer)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                        .padding(.top, 60)
                        .padding(.trailing, 15)
                    }

                    Spacer()

                    // Search Bar
                    HStack {
                        TextField("Search for a prayer space...", text: $searchText)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle("Prayer Placer", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showQibla = true }) {
                        Image(systemName: "location.north.line.fill")
                    }
                    Button(action: { showAddPrayer = true }) {
                        Image(systemName: "plus")
                    }
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showQibla) {
                QiblaCompassView(locationManager: locationManager)
            }
            .sheet(isPresented: $showAddPrayer) {
                AddPrayerSpaceView(prayerSpaces: $prayerSpaces, locationManager: locationManager)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // Prayer time logic
    func updateNextPrayer() {
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let h = now.hour ?? 0
        let m = now.minute ?? 0

        let schedule: [(String, Int, Int)] = [
            ("FAJR", 5, 2),
            ("DHUR", 13, 32),
            ("ASR", 17, 12),
            ("MAGHRIB", 20, 6),
            ("ISHA", 21, 24)
        ]

        for (name, hour, minute) in schedule {
            if h < hour || (h == hour && m < minute) {
                let timeString = String(format: "%d:%02d %@", hour > 12 ? hour - 12 : hour, minute, hour >= 12 ? "PM" : "AM")
                nextPrayer = "\(name) \(timeString)"
                return
            }
        }

        nextPrayer = "FAJR 5:02 AM"
    }
}

// MARK: - Qibla Compass View
struct QiblaCompassView: View {
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 30) {
            Text("Qibla Direction")
                .font(.largeTitle)
            if let heading = locationManager.heading?.magneticHeading {
                Image(systemName: "location.north.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(heading - 60)) // Offset for Makkah from Toronto
                Text("Point your phone toward the arrow")
            } else {
                ProgressView("Calibrating Compass...")
            }
        }
        .padding()
    }
}

