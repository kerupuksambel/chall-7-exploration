//
//  HealthKitView.swift
//  JogTrack
//
//  Created by Ammar Alifian Fahdan on 20/10/25.
//

import SwiftUI
import HealthKit

var heartRateQuery: HKAnchoredObjectQuery?

func formatTime(duration: Int) -> String {
    return "\(String(format: "%02d", duration / 60)):\(String(format: "%02d", duration % 60))"
}

func handleFinishExercise() {
    
}

struct HealthKitView: View {
//    @StateObject private var healthKitManager = HealthKitManager()
    @State private var progress: CGFloat = 1.0
    @State private var activeTimeRemaining: Int
    @State private var timeRecorded: Int = 0
    @State private var isPaused: Bool = false
    @State private var isBPMUnder: Bool = false
    @State private var BPMNow: Double = Double.random(in: 60...120)
    
    let totalTime: Int
    let activeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let totalTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let BPMTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    

    init(totalTime: Int) {
        self.totalTime = totalTime
        _activeTimeRemaining = State(initialValue: totalTime)
//        _timeRemaining = State(initialValue: 0)
    }

    var body: some View {
        VStack {
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
                        Text(formatTime(duration: activeTimeRemaining))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }.padding(.bottom, 12)
                    
                    VStack {
                        Text("BPM")
                        
                        Text("\(Int(BPMNow))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                isBPMUnder ? Color.red : Color.black
                        )
                    }
                }
            }
            .frame(width: 260, height: 260)
            
            VStack {
                Text("Total Time").font(.title2).padding(.bottom, 4)
                
                Text(formatTime(duration: timeRecorded)).font(.title).fontWeight(.bold)
            }
            .padding(.vertical, 36)
            
            VStack {
                Button ("Pause") {
                    isPaused = true
                }
                
                Button ("End") {
                    handleFinishExercise()
                }
            }
        }
        .onReceive(activeTimer) { _ in
            guard activeTimeRemaining > 0 else { return }
            // TODO: get real BPM treshold
            let BPMTreshold = 90.0
            
            isBPMUnder = BPMNow < BPMTreshold

            if(BPMNow < BPMTreshold){
                activeTimeRemaining -= 1
            }
            progress = CGFloat(activeTimeRemaining) / CGFloat(totalTime)
        }
        .onReceive(totalTimer) { _ in
            timeRecorded += 1
        }
        .onReceive(BPMTimer) { _ in
            // TODO: change to a real HealthKit provider
            BPMNow = Double.random(in: 60...120)
            print("BPM Now: \(BPMNow), captured on: \(activeTimeRemaining)")
        }
    }
}

#Preview {
    HealthKitView(totalTime: 300)
}
