import Foundation
import HealthKit

@objc public class fueldHK: NSObject {
    let healthStore = HKHealthStore()
    
    @objc public func echo(_ value: String) -> String {
        let enhancedValue = value + " enhanced"
        print(enhancedValue)
        return enhancedValue
    }
    
    @objc public func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let readTypes: Set<HKSampleType> = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!
            ]
            
            let writeTypes: Set<HKSampleType> = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!
            ]
            
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
                if success {
                    print("Authorization successful")
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
}
