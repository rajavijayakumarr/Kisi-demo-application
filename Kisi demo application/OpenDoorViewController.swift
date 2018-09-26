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


struct Becons {
    var uuid: String
    var major: String
    var minor: String
    var rssi: Int = 12
    var accuracy: Int = 2
    var age: Int = 10000
}

struct Device {
    var ip: String
    var mac: String
    var manufacturer: String = "apple"
    var model: String
}

struct Location {
    var longitude: Double
    var latitude: Double
    var altitude: Int = 14
    var age: Int = 10000
    var horizontal_accuracy: Int = 10
    var vertical_accuracy: Int = 10
}

struct OS {
    var name: String = "iOS"
    var rooted: Bool = false
    var version: String
}

struct Services {
    var type: String
    var available: Bool = true
    var authorized: Bool = true
    var enabled: Bool = true
}


struct Wifi {
    var bssid: String
    var open: Bool
    var ssid: String
    var rssi: Int
}
struct App {
    let deviceUUID = "A21F553F-9AE1-5512-B0F5-AD637351E951"
    let version = "12.0"
}


class OpenDoorViewController: UIViewController {
    
    var secret: String?
    var authenticationToken: String?
    
    var location: Location?
    var macAddress: String?
    var deviceUUID: String?
    var deviceVersion: String?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func getAllNecessaryParameters() {
        
    }
    
}
