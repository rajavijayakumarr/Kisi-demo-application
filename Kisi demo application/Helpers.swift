//
//  Helpers.swift
//  Kisi demo application
//
//  Created by Raja on 26/09/18.
//  Copyright © 2018 FullCreative. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

// MARK:- Constants
let AUTHORIZATION_TOKEN = "AUTHORIZATION_TOKEN"
let SECRET = "SECRET"

// MARK:- Structures
struct Becons: Codable {
    var uuid: String
    var major: Int
    var minor: Int
    var rssi: Int = 12
    var accuracy: Int = 2
    var age: Int = 10000
    
    init(uuid: String, major: Int, minor: Int) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
    }
    
    func toJSONstring() -> String? {
        
        let jsonEncoded = try? JSONEncoder().encode(self)
        guard let json = jsonEncoded else { return nil }
        let jsonString = String(data: json, encoding: .utf8)
        return jsonString
    }
}

struct Device: Codable {
    var ip: String
    var mac: String
    var manufacturer: String = "apple"
    var model: String
    
    func toJSONstring() -> String? {
        
        let jsonEncoded = try? JSONEncoder().encode(self)
        guard let json = jsonEncoded else { return nil }
        let jsonString = String(data: json, encoding: .utf8)
        return jsonString
    }
}

struct Location: Codable {
    var longitude: Double
    var latitude: Double
    var altitude: Int = 14
    var age: Int = 10000
    var horizontal_accuracy: Int = 10
    var vertical_accuracy: Int = 10
    
    init(longitude: Double, latitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func toJSONstring() -> String? {
        
        let jsonEncoded = try? JSONEncoder().encode(self)
        guard let json = jsonEncoded else { return nil }
        let jsonString = String(data: json, encoding: .utf8)
        return jsonString
    }
}

struct OS: Codable {
    var name: String = "iOS"
    var rooted: Bool = false
    var version: String
    
    init(version: String) {
        self.version = version
    }
    func toJSONstring() -> String? {
        
        let jsonEncoded = try? JSONEncoder().encode(self)
        guard let json = jsonEncoded else { return nil }
        let jsonString = String(data: json, encoding: .utf8)
        return jsonString
    }
}

struct Services: Codable {
    var type: String
    var available: Bool = true
    var authorized: Bool = true
    var enabled: Bool = true
    
    init(type: String) {
        self.type = type
    }
    func toJSONstring() -> String? {
        
        let jsonEncoded = try? JSONEncoder().encode(self)
        guard let json = jsonEncoded else { return nil }
        let jsonString = String(data: json, encoding: .utf8)
        return jsonString
    }
}

struct Wifi: Codable {
    var bssid: String
    var open: Bool = false
    var ssid: String
    var rssi: Int
    
    func toJSONstring() -> String? {
        
        let jsonEncoded = try? JSONEncoder().encode(self)
        guard let json = jsonEncoded else { return nil }
        let jsonString = String(data: json, encoding: .utf8)
        return jsonString
    }
}
struct App: Codable {
    let deviceUUID = "A21F553F-9AE1-5512-B0F5-AD637351E951"
    let version = "12.0"
    
    init() {
    }
    func toJSONstring() -> String? {
        
        let jsonEncoded = try? JSONEncoder().encode(self)
        guard let json = jsonEncoded else { return nil }
        let jsonString = String(data: json, encoding: .utf8)
        return jsonString
    }
}

struct LocksInformation {
    var name: String
    var id: String
    var beacon: Becons
}


// MARK:-  Return IP address of WiFi interface (en0) as a String, or `nil`
func getWiFiAddress() -> String? {
    var address : String?
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }
    
    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        
        // Check for IPv4 or IPv6 interface:
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            
            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if  name == "en0" {
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
    }
    freeifaddrs(ifaddr)
    
    return address
}

// MARK:- To get the wifi ssid and the bssid
func getWiFiInfo() -> (ssid: String?, bssid: String?) {
    var ssid: String?
    var bssid: String?
    if let interfaces = CNCopySupportedInterfaces() as NSArray? {
        for interface in interfaces {
            if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
                break
            }
        }
    }
    return (ssid, bssid)
}

// MARK:- Show alert
func showAlert(titleMessage: String?, message: String?, viewController: UIViewController, completionHandler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: completionHandler))
    viewController.present(alert, animated: true)
}
