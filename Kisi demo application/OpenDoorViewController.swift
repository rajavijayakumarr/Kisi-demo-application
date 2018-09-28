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
import MBProgressHUD

class OpenDoorViewController: UIViewController {
    
    // MARK:- Outlet Properties
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var scanForLocksButton: UIButton!
    @IBOutlet weak var distanceInformationOfLock: UILabel!
    
    // MARK:- Properties
    var currentLocation: CLLocation?
    let locationManager: CLLocationManager = CLLocationManager()
    
    var becons: Becons? = nil
    var device: Device? = nil
    var location: Location? = nil
    var os: OS? = nil
    var services: Services? = nil
    var wifi: Wifi? = nil
    var app: App? = nil
    
    var locks: [LocksInformation] = []
    
    var locationAccessEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignLocation()
        self.locationManagerSetup()
        self.loadLocks()
        self.placesTableView.delegate = self
        self.placesTableView.dataSource = self
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.signOutFunction()
    }
    
    func loadLocks() {
        
        kisiApiService.retriveLockInformation { json, httpResponse, error in
            guard error == nil else {
                showAlert(titleMessage: "error", message: "request returned with exit code \(httpResponse?.statusCode ?? 90909)", viewController: self)
                return
            }
            
            guard let json = json else { return }
            
            print(json as Any)
            self.setAllNecessaryParameters(from: json)
            self.placesTableView.reloadData()
        }
    }
    
    // MARK:- Helper functions
    func locationManagerSetup() {
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func signOutFunction() {
        
        kisiApiService.signOut() { json , httpResponse, error in
            guard error == nil else {
                showAlert(titleMessage: json?.description, message: nil, viewController: self)
                return
            }
            if httpResponse?.statusCode == 204 {
                showAlert(titleMessage: "Logged Out Successfully", message: nil, viewController: self) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                showAlert(titleMessage: "something went wrong", message: "try again", viewController: self)
            }
            
        }
    }
    func assignLocation() {
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
            showAlert(titleMessage: "Please enable location services in settings", message: nil, viewController: self)
            return
        }
        
        self.currentLocation = locationManager.location
        
        guard let currentLocation = self.currentLocation else {
            showAlert(titleMessage: "Location cannot be determined", message: "Please try again after some times", viewController: self)
            self.location = Location(longitude: 12, latitude: 80)
            return
        }
        
        self.setLocation(currentLocation: currentLocation)
    }
    
    func unlock(lockId: String, becon: Becons) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        kisiApiService.unlockDoor(app: self.app, becons: becon, device: self.device, location: self.location, os: self.os, services: self.services, wifi: self.wifi, lockId: lockId) { json, httpResponse, error in
            
            guard error == nil else {
                MBProgressHUD.hide(for: self.view, animated: true)
                showAlert(titleMessage: "error", message: "request returned with exit code \(httpResponse?.statusCode ?? 90909)", viewController: self)
                return
            }
            
            guard let json = json else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            showAlert(titleMessage: json.description, message: nil, viewController: self)
        }
    }
    
    func setAllNecessaryParameters(from jsons: JSON) {
        
        for json in jsons.arrayValue {
            locks.append(LocksInformation(name: json["name"].stringValue, id: String(json["id"].intValue), beacon: self.setBecons(from: json) ?? Becons(uuid: "none", major: 0, minor: 0)))
        }
        
        self.setDevice()
        self.setOs()
        self.setServices()
        self.setWifi()
        self.setApp()
    }
    
    func setBecons(from json: JSON) -> Becons? {
        
        var beconValue: Becons?
        let becons = json["beacons"].arrayValue
        for becon in becons {
            if becon["transmission"].stringValue == "BLE" {
                beconValue = Becons(uuid: becon["uuid"].stringValue, major: becon["major"].intValue, minor: becon["minor"].intValue)
            }
        }
        return beconValue
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
