import Foundation
import Capacitor
import HealthKit 

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(fueldHKPlugin)
public class fueldHKPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "fueldHKPlugin"
    public let jsName = "fueldHK"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestAuthorization", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAuthorizationStatus", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAllAuthorizationStatuses", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "queryTotalCalories", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "queryCaloriesTimeSeries", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "queryAllTimeCaloriesTimeSeries", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "queryHeartRateForLastSevenDays", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "queryHRVForLastWeek", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "queryHRVAndBeatToBeatForLastDay", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "querySleepData", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = fueldHK()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    @objc func requestAuthorization(_ call: CAPPluginCall) {
        implementation.requestAuthorization()
        call.resolve([
            "status": "Authorization request sent"
        ])
    }

    @objc func getAuthorizationStatus(_ call: CAPPluginCall) {
        guard let string = call.getString("quantityTypeIdentifier"),
            let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: string)) else {
            call.reject("Invalid quantity type identifier")
            return
           }
        
        let status = implementation.getAuthorizationStatus(for: string)
        call.resolve([
            "status": status
        ])
    }

    @objc func getAllAuthorizationStatuses(_ call: CAPPluginCall) {
        let statuses = implementation.getAllAuthorizationStatuses()
        call.resolve([
            "statuses": statuses
        ])
    }

    @objc func queryTotalCalories(_ call: CAPPluginCall) {
        implementation.queryTotalCalories { (totalCalories, activeCalories, basalCalories, error) in
            if let error = error as NSError? {
                call.reject("Error querying total calories: \(error.localizedDescription)")
            } else if let totalCalories = totalCalories, let activeCalories = activeCalories, let basalCalories = basalCalories {
                call.resolve([
                    "totalCalories": totalCalories,
                    "activeCalories": activeCalories,
                    "basalCalories": basalCalories
                ])
            } else {
                call.reject("Unknown error querying total calories")
            }
        }
    }

    @objc public func queryCaloriesTimeSeries(_ call: CAPPluginCall) {
        print("In the call queryCaloriesTimeSeries")
        guard let startDateString = call.getString("startDate"),
              let endDateString = call.getString("endDate") else {
            call.reject("Invalid date format")
            return
        }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let startDate = dateFormatter.date(from: startDateString),
              let endDate = dateFormatter.date(from: endDateString) else {
            call.reject("Invalid date format. Please use ISO8601 format with fractional seconds, e.g., '2023-03-15T13:45:30.000Z'")
            return
        }

        implementation.queryCaloriesTimeSeries(startDate: startDate, endDate: endDate) { (timeSeriesData, error) in
            if let error = error as NSError? {
                call.reject("Error querying calories time series: \(error.localizedDescription)")
            } else if let timeSeriesData = timeSeriesData {
                let result = timeSeriesData.map { (date, values) -> [String: Any] in
                    return [
                        "date": ISO8601DateFormatter().string(from: date),
                        "activeCalories": values.0,
                        "basalCalories": values.1,
                        "totalCalories": values.2
                    ]
                }
                call.resolve([
                    "timeSeriesData": result
                ])
            } else {
                call.reject("Unknown error querying calories time series")
            }
        }
    }

    @objc public func queryAllTimeCaloriesTimeSeries(_ call: CAPPluginCall) {
        print("In the call queryAllTimeCaloriesTimeSeries")
        
        implementation.queryAllTimeCaloriesTimeSeries { (timeSeriesData, error) in
            if let error = error as NSError? {
                call.reject("Error querying all-time calories time series: \(error.localizedDescription)")
            } else if let timeSeriesData = timeSeriesData {
                let result = timeSeriesData.map { (date, values) -> [String: Any] in
                    return [
                        "date": ISO8601DateFormatter().string(from: date),
                        "activeCalories": values.0,
                        "basalCalories": values.1,
                        "totalCalories": values.2
                    ]
                }
                call.resolve([
                    "timeSeriesData": result
                ])
            } else {
                call.reject("Unknown error querying all-time calories time series")
            }
        }
    }

    @objc public func queryHeartRateForLastSevenDays(_ call: CAPPluginCall) {
        implementation.queryHeartRateForLastSevenDaysPerMinute { (heartRateData, error) in
            if let error = error as NSError? {
                call.reject("Error querying heart rate data: \(error.localizedDescription)")
            } else if let heartRateData = heartRateData {
                let result = heartRateData.map { (date, value) -> [String: Any] in
                    return [
                        "date": ISO8601DateFormatter().string(from: date),
                        "heartRate": value
                    ]
                }.sorted { ($0["date"] as? String ?? "") < ($1["date"] as? String ?? "") }
                call.resolve([
                    "heartRateData": result
                ])
            } else {
                call.reject("Unknown error querying heart rate data")
            }
        }
    }

    @objc public func queryHRVForLastWeek(_ call: CAPPluginCall) {
        implementation.queryHRVForLastWeek { (hrvData, error) in
            if let error = error {
                call.reject("Error querying HRV data: \(error.localizedDescription)")
            } else if let hrvData = hrvData {
                let result = hrvData.map { (date, value) -> [String: Any] in
                    return [
                        "date": ISO8601DateFormatter().string(from: date),
                        "hrv": value
                    ]
                }.sorted { ($0["date"] as? String ?? "") < ($1["date"] as? String ?? "") }
                call.resolve([
                    "hrvData": result
                ])
            } else {
                call.reject("Unknown error querying HRV data")
            }
        }
    }

    @objc public func queryHRVAndBeatToBeatForLastDay(_ call: CAPPluginCall) {
        print("In the call queryHRVAndBeatToBeatForLastDay in the wrapper")
        implementation.queryHRVAndBeatToBeatForLastDay { (hrvData, beatToBeatData, error) in
            if let error = error {
                call.reject("Error querying HRV and Beat-to-Beat data: \(error.localizedDescription)")
            } else if let hrvData = hrvData, let beatToBeatData = beatToBeatData {
                let hrvResult = hrvData.map { (date, value) -> [String: Any] in
                    return [
                        "date": ISO8601DateFormatter().string(from: date),
                        "hrv": value
                    ]
                }.sorted { ($0["date"] as? String ?? "") < ($1["date"] as? String ?? "") }
                
                let beatToBeatResult = beatToBeatData.map { (date, value) -> [String: Any] in
                    return [
                        "date": ISO8601DateFormatter().string(from: date),
                        "beatToBeat": value
                    ]
                }.sorted { ($0["date"] as? String ?? "") < ($1["date"] as? String ?? "") }
                
                call.resolve([
                    "hrvData": hrvResult,
                    "beatToBeatData": beatToBeatResult
                ])
            } else {
                call.reject("Unknown error querying HRV and Beat-to-Beat data")
            }
        }
    }
    
    @objc public func querySleepData(_ call: CAPPluginCall) {
        guard let startDateString = call.getString("startDate"),
              let endDateString = call.getString("endDate"),
              let startDate = ISO8601DateFormatter().date(from: startDateString),
              let endDate = ISO8601DateFormatter().date(from: endDateString) else {
            call.reject("Invalid date format. Please use ISO8601.")
            return
        }

        implementation.querySleepData(from: startDate, to: endDate) { (sleepData, error) in
            if let error = error {
                call.reject("Error querying sleep data: \(error.localizedDescription)")
            } else if let sleepData = sleepData {
                let result = sleepData.map { data -> [String: Any] in
                    return [
                        "date": ISO8601DateFormatter().string(from: data.date),
                        "duration": data.duration,
                        "sleepValue": data.sleepValue.rawValue
                    ]
                }.sorted { ($0["date"] as? String ?? "") < ($1["date"] as? String ?? "") }
                
                call.resolve([
                    "sleepData": result
                ])
            } else {
                call.reject("Unknown error querying sleep data")
            }
        }
    }
}
