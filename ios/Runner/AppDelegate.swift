import UIKit
import Flutter
import LocalAuthentication

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
      let faceIdChannel = FlutterMethodChannel(name: "faceid", binaryMessenger: controller.binaryMessenger)
      faceIdChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          self.requestPermission(call, result: result)
      })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func requestPermission(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        var error: NSError?
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Auth required"){ success, error in
                result(["compatible": true, "result": success, "error": error?.localizedDescription])
                return
            }
        }else{
            result(["compatible": false, "result": nil, "error": nil])
        }
    }
    
}
