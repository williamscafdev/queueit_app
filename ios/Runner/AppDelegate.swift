import UIKit
import Flutter
import QueueITLibrary

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate , QueuePassedDelegate, QueueViewWillOpenDelegate, QueueDisabledDelegate, QueueITUnavailableDelegate, QueueViewClosedDelegate, QueueSessionRestartDelegate, QueueUserExitedDelegate {
  private let CHANNEL = "flutter.native/helper"
  private var engine: QueueITEngine?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     let controller = window?.rootViewController as! FlutterViewController
        let queueChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        queueChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "openQueueItWaitingRoom" {
                if let args = call.arguments as? [String: Any],
                   let customerId = args["customerId"] as? String,
                   let event = args["eventOrAliasId"] as? String,
                   let layoutName = args["layoutName"] as? String?, 
                   let language = args["language"] as? String? {  
                    self?.initAndRunQueueIt(customerId: customerId, eventOrAliasId: event, layoutName: layoutName, language: language, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for 'openQueueItWaitingRoom'", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


    private func initAndRunQueueIt(customerId: String, eventOrAliasId: String, layoutName: String?, language: String?, result: @escaping FlutterResult) {
        guard let rootViewController = self.window?.rootViewController else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No root view controller available", details: nil))
            return
        }

        self.engine = QueueITEngine(host: rootViewController, customerId: customerId, eventOrAliasId: eventOrAliasId, layoutName: layoutName, language: language)
        self.engine?.queuePassedDelegate = self
        self.engine?.queueViewWillOpenDelegate = self
        self.engine?.queueDisabledDelegate = self
        self.engine?.queueITUnavailableDelegate = self
        self.engine?.queueViewClosedDelegate = self
        self.engine?.queueSessionRestartDelegate = self
        self.engine?.queueUserExitedDelegate = self

        do {
            try self.engine?.run()
        } catch {
            result(FlutterError(code: "QUEUE_ENGINE_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    func notifyYourTurn(_ queuePassedInfo: QueuePassedInfo?) {
       print("notifyYourTurn init")
        guard let token = queuePassedInfo?.queueitToken else { return }

    let args = ["token": token] 

    if let controller = self.window?.rootViewController as? FlutterViewController {
        let queueChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        
        queueChannel.invokeMethod("onQueuePassed", arguments: args)
    } else {
        print("FlutterViewController no está disponible")
    }
    }

    func notifyQueueViewWillOpen() {
      print("notifyQueueViewWillOpen init")
    }

    func notifyQueueDisabled(_ queueDisabledInfo: QueueDisabledInfo?) {
    let args = ["token": "token"] 

    if let controller = self.window?.rootViewController as? FlutterViewController {
        let queueChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

        queueChannel.invokeMethod("onQueueDisabled", arguments: args)
    } else {
        print("FlutterViewController no está disponible")
    }
    }

    func notifyQueueITUnavailable(_ errorMessage: String) {
      print("notifyQueueITUnavailable init")
    }

    func notifyViewClosed() {
      print("notifyViewClosed init")
    }

    func notifySessionRestart() {
      print("notifySessionRestart init")
    }

    func notifyUserExited() {
      print("notifyUserExited init")
    }
}
