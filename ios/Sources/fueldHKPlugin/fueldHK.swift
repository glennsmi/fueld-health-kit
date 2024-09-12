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

                DispatchQueue.main.async {
                    completion(totalCalories, activeCalories, basalCalories, nil)
                }
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

    func queryAllTimeCaloriesTimeSeries(completion: @escaping QueryCaloriesTimeSeriesCompletion) {
    guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
          let basalEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) else {
        completion(nil, NSError(domain: "fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Energy types are not available"]))
        return
    }

     // Calculate the start date (1 year ago from now)
    let calendar = Calendar.current
    let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    let startDate = oneYearAgo
    let endDate = Date() // Current date
    let predicate = HKQuery.predicateForSamples(withStart: oneYearAgo, end: endDate, options: .strictStartDate)
    let interval = DateComponents(day: 1)

    var timeSeriesData = [Date: (Double, Double, Double)]()

    let activeEnergyQuery = HKStatisticsCollectionQuery(quantityType: activeEnergyType, 
                                                        quantitySamplePredicate: predicate, 
                                                        options: .cumulativeSum, 
                                                        anchorDate: startDate, 
                                                        intervalComponents: interval)
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

    func queryHeartRateForLastSevenDaysPerMinute(completion: @escaping ([Date: Double]?, Error?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, NSError(domain: "com.fueldHK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Heart rate type is not available"]))
            return
        }

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            completion(nil, NSError(domain: "com.fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate start date"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let interval = DateComponents(minute: 1) // Change to per minute

        let query = HKStatisticsCollectionQuery(quantityType: heartRateType,
                                                quantitySamplePredicate: predicate,
                                                options: .discreteAverage,
                                                anchorDate: startDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { [weak self] query, results, error in
            guard let results = results else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            var heartRateData: [(date: Date, heartRate: Double)] = []

            results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let averageHeartRate = statistics.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) {
                    heartRateData.append((date: statistics.startDate, heartRate: averageHeartRate))
                } 
            }

            DispatchQueue.main.async {
                let heartRateDataDict = Dictionary(uniqueKeysWithValues: heartRateData.map { ($0.date, $0.heartRate) })
                completion(heartRateDataDict, nil)
            }
        }

        self.healthStore.execute(query)
    }

    func queryHeartbeatSeriesSamples(completion: @escaping ([Date: Double]?, Error?) -> Void) {
        guard let heartbeatSeriesType = HKObjectType.seriesType(forIdentifier: HKDataTypeIdentifierHeartbeatSeries) else {
            completion(nil, NSError(domain: "com.fueldHK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Heartbeat series type is not available"]))
            return
        }

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            completion(nil, NSError(domain: "com.fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate start date"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: heartbeatSeriesType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { (query, samples, error) in
            if let error = error {
                print("Error querying heartbeat series: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let samples = samples as? [HKHeartbeatSeriesSample], !samples.isEmpty else {
                completion(nil, nil) // No heartbeat series samples found
                return
            }

            var heartbeatData: [(Date, Double, [Double])] = [] // Store date, HRV value, and beat-to-beat data
            let group = DispatchGroup()

            for sample in samples {
                group.enter()
                self.getBeatToBeatData(for: sample) { beatToBeat in
                    if let beatToBeat = beatToBeat {
                        let hrvValue = 5.0
                        heartbeatData.append((sample.startDate, hrvValue, beatToBeat))
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                let dataDict = Dictionary(uniqueKeysWithValues: heartbeatData.map { ($0.0, $0.1) })
                completion(dataDict, nil)
            }
        }

        self.healthStore.execute(query)
    }


    
    private func getBeatToBeatData(for hrvSample: HKHeartbeatSeriesSample, completion: @escaping ([Double]?) -> Void) {
        var beatToBeatIntervals: [Double] = []

        // Create the query
        let query = HKHeartbeatSeriesQuery(heartbeatSeries: hrvSample) { (query, timeSinceSeriesStart, precededByGap, done, error) in
            if let error = error {
                print("Error querying heartbeat series: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            // If we have time data, add it to the array
            if timeSinceSeriesStart >= 0 { // This will check if timeSinceSeriesStart is valid
                beatToBeatIntervals.append(timeSinceSeriesStart)
            }

            // When done, return the results
            if done {
                DispatchQueue.main.async {
                    completion(beatToBeatIntervals)
                }
            }
        }

        // Execute the query
        self.healthStore.execute(query)
    }
    

    func queryHRVForLastWeek(completion: @escaping ([(Date, Double)]?, Error?) -> Void) {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion(nil, NSError(domain: "com.fueldHK", code: 0, userInfo: [NSLocalizedDescriptionKey: "HRV type is not available"]))
            return
        }

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            completion(nil, NSError(domain: "com.fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate start date"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { (query, samples, error) in
            if let error = error {
                print("Error querying HRV: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                completion([], nil) // No HRV samples found, return empty array
                return
            }

            let hrvData = samples.map { sample in
                (sample.startDate, sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)))
            }

            completion(hrvData, nil)
        }

        self.healthStore.execute(query)
    }




    func queryHRVAndBeatToBeatForLastDay(completion: @escaping ([(Date, Double)]?, [(Date, Double)]?, Error?) -> Void) {
        print("In the queryHRVAndBeatToBeatForLastDay in fueldHK.swift")
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion(nil, nil, NSError(domain: "com.fueldHK", code: 0, userInfo: [NSLocalizedDescriptionKey: "HRV type is not available"]))
            return
        }

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            completion(nil, nil, NSError(domain: "com.fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate start date"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        // Query for HRV data
        let hrvQuery = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { (query, samples, error) in
            if let error = error {
                print("Error querying HRV: \(error.localizedDescription)")
                completion(nil, nil, error)
                return
            }

            guard let hrvSamples = samples as? [HKQuantitySample], !hrvSamples.isEmpty else {
                completion(nil, nil, nil) // No HRV samples found
                return
            }

            // Prepare to store both HRV and beat-to-beat intervals
            var hrvData: [(Date, Double)] = []
            var beatToBeatData: [(Date, Double)] = []

            let dispatchGroup = DispatchGroup()

            for hrvSample in hrvSamples {
                                
                dispatchGroup.enter()

                // Store HRV data
                let hrvValue = hrvSample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                hrvData.append((hrvSample.startDate, hrvValue))

                // Query for heartbeat series samples within the HRV sample period
                let heartbeatPredicate = HKQuery.predicateForSamples(withStart: hrvSample.startDate, end: hrvSample.endDate, options: .strictStartDate)

                // First, query for HKHeartbeatSeriesSample
                let heartbeatSeriesQuery = HKSampleQuery(sampleType: HKSeriesType.heartbeat(), predicate: heartbeatPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                    guard error == nil else {
                        print("Error querying heartbeat series: \(String(describing: error?.localizedDescription))")
                        dispatchGroup.leave()
                        return
                    }

                    guard let heartbeatSeriesSamples = samples as? [HKHeartbeatSeriesSample] else {
                        print("No heartbeat series samples found")
                        dispatchGroup.leave()
                        return
                    }

                    // Now process each heartbeat series sample
                    for heartbeatSeriesSample in heartbeatSeriesSamples {
                        let seriesQuery = HKHeartbeatSeriesQuery(heartbeatSeries: heartbeatSeriesSample) { (query, timeSinceSeriesStart, precededByGap, done, error) in
                            if let error = error {
                                print("Error in heartbeat series query: \(error.localizedDescription)")
                                dispatchGroup.leave()
                                return
                            }

                            // Store beat-to-beat data
                            let beatInterval = timeSinceSeriesStart
                            beatToBeatData.append((heartbeatSeriesSample.startDate, beatInterval))

                            if done {
                                dispatchGroup.leave()
                            }
                        }

                        // Execute the query for this heartbeat series sample
                        HKHealthStore().execute(seriesQuery)
                    }
                }

                // Execute the heartbeat series sample query
                HKHealthStore().execute(heartbeatSeriesQuery)
            }

            // Once all HRV and heartbeat queries are done, call the completion handler
            dispatchGroup.notify(queue: .main) {
                completion(hrvData, beatToBeatData, nil)
            }
        }

        // Execute the HRV query
        HKHealthStore().execute(hrvQuery)
    }


     struct SleepData {
        let date: Date
        let duration: TimeInterval
        let sleepValue: HKCategoryValueSleepAnalysis
    }
    
    func querySleepData(from startDate: Date, to endDate: Date, completion: @escaping ([SleepData]?, Error?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil, NSError(domain: "com.fueldHK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sleep Analysis type is not available"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let sleepSamples = samples as? [HKCategorySample] else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "com.fueldHK", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not cast samples to HKCategorySample"]))
                }
                return
            }
            
            let sleepData = sleepSamples.compactMap { sample -> SleepData? in
                guard let sleepValue = HKCategoryValueSleepAnalysis(rawValue: sample.value) else {
                    return nil
                }
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                return SleepData(date: sample.startDate, duration: duration, sleepValue: sleepValue)
            }
            
            DispatchQueue.main.async {
                completion(sleepData, nil)
            }
        }
        
        healthStore.execute(query)
    }
}

    
}
