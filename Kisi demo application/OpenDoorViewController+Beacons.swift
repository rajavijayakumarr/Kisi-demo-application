//
//  OpenDoorViewController+Beacons.swift
//  Kisi demo application
//
//  Created by Raja on 28/09/18.
//  Copyright © 2018 FullCreative. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

extension OpenDoorViewController: CLLocationManagerDelegate {
    
    @IBAction func scanForLocksButtonPressed(_ sender: UIButton) {
        self.scanForLocksAction()
        //self.showNotification(title: "scanning for devices")
    }
    
    func scanForLocksAction() {
        
        guard self.locationAccessEnabled else {
            showAlert(titleMessage: "enable location services in settings", message: nil, viewController: self)
            return
        }
        
        self.scanForLocksButton.setTitle("Scanning...", for: .normal)
        self.distanceInformationOfLock.text = "started scanning"
        self.scanForLocksButton.isEnabled = false
        
        self.rangeBeacons()
    }

    func rangeBeacons() {
        
//        for lock in self.locks {
//            let uuid = lock.beacon.uuid
//            let majorValue = CLBeaconMajorValue(lock.beacon.major)
//            let minorValue = CLBeaconMinorValue(lock.beacon.minor)
//            let identifier = lock.beacon.uuid
//
//            let region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, major: majorValue, minor: minorValue, identifier: identifier)
//            region.notifyOnEntry = true
//            region.notifyOnExit = true
//            self.locationManager.startMonitoring(for: region)
//            self.locationManager.startRangingBeacons(in: region)
//        }
        
        let uuid = UUID(uuidString: "54b2dd06-91ba-4fb7-b1ff-0a6fd97fa593")!
        let majorValue: CLBeaconMajorValue = 50872
        let minorValue: CLBeaconMinorValue = 20663
        let identifier = "serverroomlock"
        
        let region = CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: identifier)
        self.locationManager.startMonitoring(for: region)
        self.locationManager.startRangingBeacons(in: region)
        
    }
    
    func unlockForBeacon(for uuid: String) {
        
        guard let lockInfo = self.locks.first else { return }
        
        self.unlock(lockId: lockInfo.id, becon: lockInfo.beacon)        
    }
    
    // MARK:- Location manager Delegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways:
            self.locationAccessEnabled = true
      //      self.scanForLocksAction()
            break
        case .authorizedWhenInUse:
            // code here to inform the user that always allowed location for this application will be more functional
            break
        case .denied:
            // code here to inform user that the location service has been denied permission
            break
        case .notDetermined:
            // code here to show alert that the loction of the user could not be determined
            break
        case .restricted:
            // code here to alert the user that permission for the location has been manually restricted by ther user only for this applicaton
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for becon in beacons {
            
            switch becon.proximity {
            case .unknown:
                self.distanceInformationOfLock.text = "distance unknown"
                print("unknown")
   //             self.showNotification(title: "unknown")
            case .far:
                self.distanceInformationOfLock.text = "distance far"
                print("far")
   //             self.showNotification(title: "far")
            case .near:
                self.distanceInformationOfLock.text = "distance near so unlocked"
                self.unlockForBeacon(for: becon.proximityUUID.uuidString)
                print("near")
            case .immediate:
                self.distanceInformationOfLock.text = "distance immediate"
                print("immediate")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //showAlert(titleMessage: "user entered beacon region", message: "user entered!", viewController: self)
        self.showNotification(title: "Lock detected in this region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //showAlert(titleMessage: "user exited becon region", message: "user exited", viewController: self)
        self.showNotification(title: "user moved away from the lock")
    }
    
    func showNotification(title: String) {
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = title
        notificationContent.subtitle = "testing"
        notificationContent.body = "scanning for becons"
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest = UNNotificationRequest(identifier: "com.fullCreative.Kisi-demo-application", content: notificationContent, trigger: notificationTrigger)
        UNUserNotificationCenter.current().add(notificationRequest) { error in
            if error != nil {
                print("notification request failed to post")
            }
        }
    }
    
}

extension OpenDoorViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}
