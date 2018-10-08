//
//  AppDelegate.swift
//  Kisi demo application
//
//  Created by Raja on 26/09/18.
//  Copyright © 2018 FullCreative. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        self.registerForNotifications()
        self.rangeBeacons()
        self.locationManager.delegate = self
        guard UserDefaults.standard.value(forKey: AUTHORIZATION_TOKEN) != nil else {
            return true
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let openDoorVC = storyboard.instantiateViewController(withIdentifier: "opendoorviewcontroller") as! OpenDoorViewController
        self.window?.rootViewController = openDoorVC
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    // MARK:- Helper methods

    func registerForNotifications() {
        
        // Request Notification Settings
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
            // Request Authorization
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    
                    // Schedule Local Notification
                })
            case .authorized:
            // Schedule Local Notification
                print("successfully authorized")
            case .denied:
                print("application not allowed to show notification")
            case .provisional:
                break
            }
        }
    }
    
    func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }

}

extension AppDelegate: CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        switch beacons.first?.proximity {
        case .unknown?:
            print("unknown")
        case .far?:
            unlockForBeacon(beacon: Becons(uuid: "54b2dd06-91ba-4fb7-b1ff-0a6fd97fa593", major: 50872, minor: 20663))
            print("far")
        case .near?:
            print("near")
        case .immediate?:
            
            print("immediate")
        case .none:
            print("none")
        case .some(_):
            print("some")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        showNotification(title: "Lock detected nearby")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        showNotification(title: "user moved away from lock region")
    }
    
    // helper methods
    func showNotification(title: String) {
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = title
        notificationContent.subtitle = "user in becon region"
        notificationContent.body = "user in becon region"
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest = UNNotificationRequest(identifier: "com.fullCreative.Kisi-demo-application", content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { error in
            if error != nil {
                print("notification request failed to post")
            }
        }
    }
    
    func rangeBeacons() {
        
        let uuid = UUID(uuidString: "54b2dd06-91ba-4fb7-b1ff-0a6fd97fa593")!
        let majorValue: CLBeaconMajorValue = 50872
        let minorValue: CLBeaconMinorValue = 20663
        let identifier = "serverroomlock"
        
        let region = CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: identifier)
        self.locationManager.startMonitoring(for: region)
        self.locationManager.startRangingBeacons(in: region)
    }
    
    // MARK:- AppDelegate delegate methods
    
    func unlockForBeacon(beacon: Becons) {
        showNotification(title: "Unlocking the door")
        kisiApiService.unlockDoor(app: self.setApp(), becons: beacon, device: self.setDevice(), location: Location(longitude: 80.246071000000001, latitude: 12.985803000000001), os: self.setOs(), services: self.setServices(), wifi: self.setWifi(), lockId: "8322") { json, httpResponse, error in
            
            guard error == nil else {
                self.showNotification(title: "error occured while unlocking the door")
                return
            }
            
            guard let json = json else { return }
            self.showNotification(title: "Unlocked the doors successfully \(json.description)")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
        let uuid = UUID(uuidString: "54b2dd06-91ba-4fb7-b1ff-0a6fd97fa593")!
        let majorValue: CLBeaconMajorValue = 50872
        let minorValue: CLBeaconMinorValue = 20663
        let identifier = "serverroomlock"
        
        let region = CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: identifier)
        self.locationManager.startMonitoring(for: region)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    // MARK:- Methods to unlock the doors
    func setDevice() -> Device {
        
        let ipAddress = getWiFiAddress() ?? "no ip address"
        let macAddress = UIDevice.current.identifierForVendor?.uuidString ?? "no macaddress"
        //let macAddress = "48:4B:AA:20:0E:D7"
        let model = UIDevice.current.model
        return Device(ip: ipAddress, mac: macAddress, manufacturer: "apple", model: model)
    }
    
    func setLocation(currentLocation: CLLocation) -> Location {
        var location = Location(longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
        location.altitude = Int(currentLocation.altitude)
        location.horizontal_accuracy = Int(currentLocation.horizontalAccuracy)
        location.vertical_accuracy = Int(currentLocation.verticalAccuracy)
        return location
    }
    
    func setOs() -> OS{
        let os = OS(version: UIDevice.current.systemVersion)
        return os
    }
    
    func setServices() -> Services {
        return Services(type: "type")
    }
    
    func setWifi() -> Wifi {
        let wifiInfo = getWiFiInfo()
        let bssid = wifiInfo.bssid ?? "no bssid"
        let ssid = wifiInfo.ssid ?? "no ssid"
        return Wifi(bssid: bssid, open: false, ssid: ssid, rssi: 23)
    }
    
    func setApp() -> App {
        return App()
    }
}

