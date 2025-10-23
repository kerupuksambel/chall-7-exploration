//
//  ContentView.swift
//  JogTrack
//
//  Created by Ammar Alifian Fahdan on 14/10/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 1)
        )
    )
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Map(position: $position){
                
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
