import UIKit
import Flutter
#if !targetEnvironment(simulator)
import Identy
#endif
import WebKit
import SystemConfiguration
import SwiftyJSON
import Foundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      GeneratedPluginRegistrant.register(with: self)
      
      self.window.makeSecure()
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
      let channel = FlutterMethodChannel(name: "identy_finger",
                                         binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if call.method == "capture" {
              #if targetEnvironment(simulator)
              // Running on simulator: Identy not available
              result(FlutterError(code: "SimulatorNotSupported",
                                  message: "Identy framework is not available on the simulator",
                                  details: nil))
              #else
              // Running on physical device: Use Identy framework
              let data = call.arguments as? [String: Any]
              let handType = data?["hand"] as? String ?? ""
              let bundlePath = Bundle.main.path(forResource: "3852-tz.co.itrust.iwealth-ios-31-03-2025", ofType: "lic")
              let instance = IdentyFramework.init(with: bundlePath,
                                                  localizablePath: Bundle.main.path(forResource: "en", ofType: "lproj"),
                                                  table: "Main")

              if handType.lowercased() == "left" {
                  instance.handScanTypeArray = [.l4f]
              } else {
                  instance.handScanTypeArray = [.r4f]
              }

              instance.isDemo = false
              instance.isBoxes = true
              instance.isShowGuide = false
              instance.isFlash = true
              instance.isCustomIntroScreen = false
              instance.isCustomResultScreen = false
              instance.isNeedShowTraining = false
              instance.wsqCompression = WSQCompressionType.WSQ_5_1
              instance.displayResult = false
              instance.uiSelect = AppUI.boxes
              
              let currentViewController = UIApplication.shared.keyWindow?.rootViewController
              instance.capture(viewcontrol: currentViewController, onSuccess: { (response, transactionID, noOfAttempts) in
                  let dict: Dictionary<String, Any> = (response?.responseDictionary)!
                  let datadict: Dictionary<String, Any> = dict["data"] as! Dictionary<String, Any>
                  
                  var allTemplates: [String: String] = [:]
                  if handType.lowercased() == "left" {
                      allTemplates = self.generateTemplates(for: "left", dataDict: datadict)
                  } else if handType.lowercased() == "right" {
                      allTemplates = self.generateTemplates(for: "right", dataDict: datadict)
                  }
                  
                  do {
                      let jsonData = try JSONSerialization.data(withJSONObject: allTemplates, options: [])
                      if let jsonString = String(data: jsonData, encoding: .utf8) {
                          result(jsonString) // Return the combined templates as a JSON string
                      } else {
                          result(FlutterError(code: "SerializationError",
                                              message: "Failed to convert JSON data to string",
                                              details: nil))
                      }
                  } catch {
                      result(FlutterError(code: "SerializationError",
                                          message: "Failed to serialize dictionary to JSON",
                                          details: error.localizedDescription))
                  }
              }, onFailure: { (error, response, transactionID, noOfAttempts) in
                  result(error)
                  return
              }, onAttempts: { (attempts) in
              })
              #endif
          } else {
              result(FlutterMethodNotImplemented)
          }
      })
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  #if !targetEnvironment(simulator)
  // Helper function to generate templates (only for physical devices)
  private func generateTemplates(for handType: String, dataDict: Dictionary<String, Any>) -> [String: String] {
      let fingerNames: [String] = ["thumb", "index", "middle", "ring", "little"]
      let handSide: [String] = handType == "left" ? ["left"] : ["right"]
      var templates = [String: String]()

      for side in handSide {
          for finger in fingerNames {
              let fingerKey = "\(side)\(finger)"
              
              if let fingerDict = dataDict[fingerKey] as? Dictionary<String, Any>,
                 let templatesData = fingerDict["templates"] as? Dictionary<String, Any>,
                 let templateList = templatesData["WSQ"] as? [Dictionary<TemplateSize, String>] {
                  
                  if let firstTemplate = templateList.first {
                      if let templateString = firstTemplate.values.first {
                          let name = getNameForFinger(fingerKey)
                          templates[name] = templateString
                      }
                  }
              }
          }
      }
      
      return templates
  }
  #endif
}

// Helper function to map finger names to your codes (available for both simulator and device)
private func getNameForFinger(_ filename: String) -> String {
    switch filename {
    case "leftindex": return "L2"
    case "leftmiddle": return "L3"
    case "leftring": return "L4"
    case "leftlittle": return "L5"
    case "leftthumb": return "12"
    case "rightindex": return "R2"
    case "rightmiddle": return "R3"
    case "rightring": return "R4"
    case "rightlittle": return "R5"
    case "rightthumb": return "11"
    default: return "unknown"
    }
}

// Existing extensions (unchanged)
extension UIWindow {
    func makeSecure() {
        let field = UITextField()
        field.isSecureTextEntry = true
        self.addSubview(field)
        field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.layer.superlayer?.addSublayer(field.layer)
        field.layer.sublayers?.first?.addSublayer(self.layer)
    }
}

extension Dictionary {
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }
    
    func toJSONString() -> String? {
        if let jsonData = jsonData {
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }
        return nil
    }
}

extension String {
    var isString: Bool {
        return true
    }
}
