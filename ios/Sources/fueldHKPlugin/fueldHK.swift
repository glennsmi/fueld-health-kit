import Foundation
import HealthKit

@objc public class fueldHK: NSObject {
    let healthStore = HKHealthStore()
    
    @objc public func echo(_ value: String) -> String {
        let enhancedValue = value + " enhanced"
        print(enhancedValue)
        return enhancedValue
    }
    
   
    let readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
        ]

        if #available(iOS 14.0, *) {
            types.insert(HKObjectType.quantityType(forIdentifier: .walkingSpeed)!)
        }

        if #available(iOS 16.0, *) {
            types.insert(HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature)!);
            types.insert(HKObjectType.quantityType(forIdentifier: .heartRateRecoveryOneMinute)!)
        }

        return types
    }()
    
    let writeTypes: Set<HKSampleType> = {
        var types: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
        ]

        return types
    }()
    
    @objc public func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes ) { (success, error) in
                if success {
                    print("Authorization successful")
                    
                    // Read date of birth
                    do {
                        let dateOfBirth = try self.healthStore.dateOfBirthComponents()
                        let dayOfBirth = dateOfBirth.day
                        let monthOfBirth = dateOfBirth.month
                        let yearOfBirth = dateOfBirth.year
                        print("Date of Birth: \(dayOfBirth ?? 0) \(monthOfBirth ?? 0) \(yearOfBirth ?? 0)")
                    } catch {
                        print("Error reading date of birth: \(error.localizedDescription)")
                    }
                    
                    // Read biological sex
                    do {
                        let biologicalSexObject = try self.healthStore.biologicalSex()
                        let biologicalSex = biologicalSexObject.biologicalSex
                        switch biologicalSex {
                        case .notSet:
                            print("Biological Sex: Not Set")
                        case .female:
                            print("Biological Sex: Female")
                        case .male:
                            print("Biological Sex: Male")
                        case .other:
                            print("Biological Sex: Other")
                        @unknown default:
                            print("Biological Sex: Unknown")
                        }
                    } catch {
                        print("Error reading biological sex: \(error.localizedDescription)")
                    }
                    
                } else {
                    if let error = error {
                        print("Authorization failed with error: \(error.localizedDescription)")
                    } else {
                        print("Authorization failed")
                    }
                }
            }
        } else {
            print("Health data not available")
        }
    }
    
    @objc public func getAuthorizationStatus(for quantityTypeIdentifier: String) -> String {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: quantityTypeIdentifier)) else {
            return "Invalid quantity type identifier"
        }
        
        let status = healthStore.authorizationStatus(for: quantityType)
        let authorizationStatus: [String: Any] = [
            "requestedType": [
                "identifier": quantityTypeIdentifier,
                "isAuthorized": (status == .sharingAuthorized),
                "status": statusToString(status)
            ]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: authorizationStatus, options: [])
        if let jsonString = String(data: jsonData!, encoding: .utf8) {
            return jsonString
        }
        
        return "Error creating JSON string"
    }

    @objc public func getAllAuthorizationStatuses() -> String {
    var authorizationStatus: [String: Any] = [:]
    
    for type in readTypes {
        let status = healthStore.authorizationStatus(for: type)
        let isAuthorized = (status == .sharingAuthorized)
        
        // Safely extract type identifier
        let typeIdentifier = (type as? HKObjectType)?.identifier ?? "Unknown"
        
        // Build the dictionary for each type
        authorizationStatus[typeIdentifier] = [
            "isAuthorized": isAuthorized,
            "status": statusToString(status)
        ]
    }
    
    // Convert dictionary to JSON safely
    if let jsonData = try? JSONSerialization.data(withJSONObject: authorizationStatus, options: []),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
    }
    
    return "{\"error\": \"Error creating JSON string\"}"
}
    
    private func statusToString(_ status: HKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "Not Determined"
        case .sharingDenied:
            return "Sharing Denied"
        case .sharingAuthorized:
            return "Sharing Authorized"
        @unknown default:
            return "Unknown"
        }
    }
    
    // Swift function with the completion handler
    typealias QueryTotalCaloriesComponentsCompletion = (Double?, Double?, Double?, Error?) -> Void

    func queryTotalCalories(completion: @escaping QueryTotalCaloriesComponentsCompletion) {
        print("In the queryTotalCalories in fueldHK.swift")

        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let basalEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) else {
            completion(nil, nil, nil, NSError(domain: "fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Energy types are not available"]))
            return
        }

        let now = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let activeEnergyQuery = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let activeEnergy = result.sumQuantity() else {
                completion(nil, nil, nil, error ?? NSError(domain: "fueldHK", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active energy data available"]))
                return
            }

            let activeCalories = activeEnergy.doubleValue(for: HKUnit.kilocalorie())

            let basalEnergyQuery = HKStatisticsQuery(quantityType: basalEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let basalEnergy = result.sumQuantity() else {
                    completion(nil, nil, nil, error ?? NSError(domain: "fueldHK", code: 3, userInfo: [NSLocalizedDescriptionKey: "No basal energy data available"]))
                    return
                }

                let basalCalories = basalEnergy.doubleValue(for: HKUnit.kilocalorie())
                let totalCalories = activeCalories + basalCalories

                print("Successfully queried calories - Active: \(activeCalories), Basal: \(basalCalories), Total: \(totalCalories)")
                completion(totalCalories, activeCalories, basalCalories, nil)
            }

            self.healthStore.execute(basalEnergyQuery)
        }

        healthStore.execute(activeEnergyQuery)
    }
    

    typealias QueryCaloriesTimeSeriesCompletion = ([Date: (Double, Double, Double)]?, Error?) -> Void

    func queryCaloriesTimeSeries(startDate: Date, endDate: Date, completion: @escaping QueryCaloriesTimeSeriesCompletion) {
    print("In the queryCaloriesTimeSeries in fueldHK.swift")

    guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
          let basalEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) else {
        completion(nil, NSError(domain: "fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Energy types are not available"]))
        return
    }

    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
    let interval = DateComponents(day: 1)
    
    // Initialize timeSeriesData
    var timeSeriesData: [Date: (Double, Double, Double)] = [:]

    let activeEnergyQuery = HKStatisticsCollectionQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)

    activeEnergyQuery.initialResultsHandler = { _, result, error in
        guard let result = result else {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }

        result.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let date = statistics.startDate
            let activeCalories = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
            timeSeriesData[date] = (activeCalories, 0.0, activeCalories)
        }

        let basalEnergyQuery = HKStatisticsCollectionQuery(quantityType: basalEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)

        basalEnergyQuery.initialResultsHandler = { _, result, error in
            guard let result = result else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            result.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let date = statistics.startDate
                let basalCalories = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0

                if var data = timeSeriesData[date] {
                    data.1 = basalCalories
                    data.2 = data.0 + basalCalories
                    timeSeriesData[date] = data
                } else {
                    timeSeriesData[date] = (0.0, basalCalories, basalCalories)
                }
            }

            DispatchQueue.main.async {
                completion(timeSeriesData, nil)
            }
        }

        self.healthStore.execute(basalEnergyQuery)
    }

    self.healthStore.execute(activeEnergyQuery)
}

@objc public func queryAllTimeCaloriesTimeSeries(completion: @escaping ([Date: (Double, Double, Double)]?, Error?) -> Void) {
    guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
          let basalEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) else {
        completion(nil, NSError(domain: "fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Energy types are not available"]))
        return
    }

    let calendar = Calendar.current
    let now = Date()
    let startDate = calendar.date(byAdding: .year, value: -100, to: now)!  // Start from 100 years ago
    let endDate = now
    let interval = DateComponents(day: 1)

    var timeSeriesData = [Date: (Double, Double, Double)]()

    let activeEnergyQuery = HKStatisticsCollectionQuery(quantityType: activeEnergyType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)

    activeEnergyQuery.initialResultsHandler = { _, result, error in
        guard let result = result else {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }

        result.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let date = statistics.startDate
            let activeCalories = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
            timeSeriesData[date] = (activeCalories, 0.0, activeCalories)
        }

        let basalEnergyQuery = HKStatisticsCollectionQuery(quantityType: basalEnergyType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)

        basalEnergyQuery.initialResultsHandler = { _, result, error in
            guard let result = result else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            result.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let date = statistics.startDate
                let basalCalories = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0

                if var data = timeSeriesData[date] {
                    data.1 = basalCalories
                    data.2 = data.0 + basalCalories
                    timeSeriesData[date] = data
                } else {
                    timeSeriesData[date] = (0.0, basalCalories, basalCalories)
                }
            }

            DispatchQueue.main.async {
                completion(timeSeriesData, nil)
            }
        }

        self.healthStore.execute(basalEnergyQuery)
    }

    self.healthStore.execute(activeEnergyQuery)
}

    
}
