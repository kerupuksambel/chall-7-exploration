//
//  Health.swift
//  JogTrack
//
//  Created by Ammar Alifian Fahdan on 21/10/25.
//

import Foundation
import HealthKit

@MainActor
class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var latestBPM: Double?

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable(),
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, error in
            if success {
                self.fetchLatestHeartRate()
            } else {
                print("HealthKit auth error: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }

    func fetchLatestHeartRate() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else { return }

            DispatchQueue.main.async {
                self.latestBPM = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }

        healthStore.execute(query)
    }
}

