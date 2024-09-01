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
                HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
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
                HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
                HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
                HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
                HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,
                HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature)!,
                HKObjectType.quantityType(forIdentifier: .heartRateRecoveryOneMinute)!
            ]
            
            let writeTypes: Set<HKSampleType> = [
                HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
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
