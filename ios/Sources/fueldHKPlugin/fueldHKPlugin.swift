import Foundation
import Capacitor

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
        CAPPluginMethod(name: "requestAuthorization", returnType: CAPPluginReturnPromise)
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
}
