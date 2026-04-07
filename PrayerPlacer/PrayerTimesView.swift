//
//  PrayerTimesView.swift
//  PrayerPlacer
//
//  Created by Zaky Hashi on 2025-04-17.
//

import Foundation
import SwiftUI

// View shown when the user taps the prayer time button
struct PrayerTimesView: View {
    var body: some View {
        List {
            Text("🕊 FAJR: 5:02 AM")
            Text("☀️ DHUR: 1:32 PM")
            Text("🌇 ASR: 5:12 PM")
            Text("🌆 MAGHRIB: 8:06 PM")
            Text("🌌 ISHA: 9:24 PM")
        }
        .navigationTitle("Today’s Prayer Times")
    }
}
