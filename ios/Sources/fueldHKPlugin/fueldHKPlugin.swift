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
        CAPPluginMethod(name: "queryCaloriesTimeSeries", returnType: CAPPluginReturnPromise)
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
}
