//
//  WatchHealthManager.swift
//  JogTrack
//
//  Created by Ammar Alifian Fahdan on 27/10/25.
//


import HealthKit
import WatchConnectivity
import SwiftUI
import Combine

class WatchHealthManager: NSObject, ObservableObject, WCSessionDelegate {
    var objectWillChange: ObservableObjectPublisher = ObservableObjectPublisher()
    
    @Published var heartRate: Double = 0.0
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - HealthKit Authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types = Set([HKQuantityType.quantityType(forIdentifier: .heartRate)!])
        healthStore.requestAuthorization(toShare: [], read: types) { success, error in
            if !success { print("HealthKit auth failed:", error?.localizedDescription ?? "") }
        }
    }

    // MARK: - Heart Rate Streaming
    func startStreaming() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        heartRateQuery = HKAnchoredObjectQuery(type: type, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) {
            _, samples, _, _, _ in
            self.handle(samples)
        }
        heartRateQuery?.updateHandler = { _, samples, _, _, _ in
            self.handle(samples)
        }
        healthStore.execute(heartRateQuery!)
    }

    private func handle(_ samples: [HKSample]?) {
        guard let s = samples as? [HKQuantitySample],
              let last = s.last else { return }
        let bpm = last.quantity.doubleValue(for: .init(from: "count/min"))
        DispatchQueue.main.async {
            self.heartRate = bpm
        }
        WCSession.default.sendMessage(["bpm": bpm], replyHandler: nil)
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation error:", error.localizedDescription)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["command"] as? String == "start" {
            requestAuthorization()
            startStreaming()
        }
    }
}
