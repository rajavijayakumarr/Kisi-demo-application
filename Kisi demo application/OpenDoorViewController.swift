//
//  OpenDoorViewController.swift
//  Kisi demo application
//
//  Created by Raja on 26/09/18.
//  Copyright © 2018 FullCreative. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

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


class OpenDoorViewController: UIViewController {
    
    // MARK:- Outlet Properties
    @IBOutlet weak var placesTableView: UITableView!
    
    // MARK:- Properties
    var currentLocation: CLLocation?
    
    var becons: Becons? = nil
    var device: Device? = nil
    var location: Location? = nil
    var os: OS? = nil
    var services: Services? = nil
    var wifi: Wifi? = nil
    var app: App? = nil
    var lockId = ""
    
    var locks: [LocksInformation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignLocation()
        self.loadLocks()
        self.placesTableView.delegate = self
        self.placesTableView.dataSource = self
    }
    func loadLocks() {
        
        kisiApiService.retriveLockInformation { json, httpResponse, error in
            guard error == nil else {
                let alert = UIAlertController(title: "error", message: "request returned with exit code \(httpResponse?.statusCode ?? 90909)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            
            guard let json = json else { return }
            
            print(json as Any)
            self.setAllNecessaryParameters(from: json)

        }
        self.placesTableView.reloadData()
    }
    
    // MARK:- Helper functions
    func assignLocation() {
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse else { return }
        
        self.currentLocation = locationManager.location
        
        guard let currentLocation = self.currentLocation else {
            let alert = UIAlertController(title: "Location cannot be determined", message: "Please try again after some times", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(alert, animated: true)
            self.location = Location(longitude: 12, latitude: 80)
            return
        }
        
        self.setLocation(currentLocation: currentLocation)
    }
    
    func unlock(lockId: String, becon: Becons) {
        
        kisiApiService.unlockDoor(app: self.app, becons: becon, device: self.device, location: self.location, os: self.os, services: self.services, wifi: self.wifi, lockId: lockId) { json, httpResponse, error in
            
            guard error == nil else {
                let alert = UIAlertController(title: "error", message: "request returned with exit code \(httpResponse?.statusCode ?? 90909)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            
            guard let json = json else { return }
            let alert = UIAlertController(title: json.description, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setAllNecessaryParameters(from jsons: JSON) {
        
        for json in jsons.arrayValue {
            locks.append(LocksInformation(name: json["name"].stringValue, id: String(json["id"].intValue), beacon: self.setBecons(from: json)))
        }
        
        self.setDevice()
        self.setOs()
        self.setServices()
        self.setWifi()
        self.setApp()
    }
    
    func setBecons(from json: JSON) -> Becons {
        
        let becons = json["beacons"].arrayValue
        for becon in becons {
            if becon["transmission"].stringValue == "BLE" {
                self.becons = Becons(uuid: becon["uuid"].stringValue, major: becon["major"].intValue, minor: becon["minor"].intValue)
            }
        }
        return self.becons!
    }
    
    func setDevice() {
        
        let ipAddress = getWiFiAddress() ?? "no ip address"
        //let macAddress = UIDevice.current.identifierForVendor?.uuidString ?? "no macaddress"
        let macAddress = "48:4B:AA:20:0E:D7"
        let model = UIDevice.current.model
        self.device = Device(ip: ipAddress, mac: macAddress, manufacturer: "apple", model: model)
    }
    
    func setLocation(currentLocation: CLLocation) {
        
        self.location = Location(longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
        self.location?.altitude = Int(currentLocation.altitude)
        self.location?.horizontal_accuracy = Int(currentLocation.horizontalAccuracy)
        self.location?.vertical_accuracy = Int(currentLocation.verticalAccuracy)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.placesTableView.reloadData()
    }
    func setOs() {
        self.os = OS(version: UIDevice.current.systemVersion)
    }
    
    func setServices() {
        self.services = Services(type: "type")
    }
    
    func setWifi() {
        let wifiInfo = getWiFiInfo()
        let bssid = wifiInfo.bssid ?? "no bssid"
        let ssid = wifiInfo.ssid ?? "no ssid"
        self.wifi = Wifi(bssid: bssid, open: false, ssid: ssid, rssi: 23)
    }
    
    func setApp() {
        self.app = App()
    }
}
