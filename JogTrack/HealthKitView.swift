//
//  HealthKitView.swift
//  JogTrack
//
//  Created by Ammar Alifian Fahdan on 20/10/25.
//

import SwiftUI
import HealthKit

var heartRateQuery: HKAnchoredObjectQuery?


struct HealthKitView: View {
    @State private var progress: CGFloat = 1.0
    @State private var timeRemaining: Int
    @State private var isPaused: Bool = false
    @State private var isBPMUnder: Bool = false
    @State private var bpm: Int = 0
    
    let totalTime: Int
    let activeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let totalTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let bpmNow = HealthKitManager().fetchLatestHeartRate()
    

    init(totalTime: Int) {
        self.totalTime = totalTime
        _timeRemaining = State(initialValue: totalTime)
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.appLightBlue.opacity(0.2), lineWidth: 30)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.appDarkBlue, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Text in the center
            VStack {
                VStack {
                    Text("Active Time")
                    Text("\(String(format: "%02d", timeRemaining / 60)):\(String(format: "%02d", timeRemaining % 60))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }.padding(.bottom, 12)
                
                VStack {
                    Text("BPM")

                    Text("\(bpm)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            isBPMUnder ? Color.red : Color.black
                        )
                }
            }
        }
        .frame(width: 260, height: 260)
        .onReceive(activeTimer) { _ in
            guard timeRemaining > 0 else { return }
            timeRemaining -= 1
            progress = CGFloat(timeRemaining) / CGFloat(totalTime)
        }
        .onReceive(bpm){
            
        }
    }
}

#Preview {
    HealthKitView(totalTime: 300)
}
