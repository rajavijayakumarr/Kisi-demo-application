//
//  OpenDoorViewController+Beacons.swift
//  Kisi demo application
//
//  Created by Raja on 28/09/18.
//  Copyright © 2018 FullCreative. All rights reserved.
//

import UIKit
import CoreLocation

extension OpenDoorViewController: CLLocationManagerDelegate {
    
    @IBAction func scanForLocksButtonPressed(_ sender: UIButton) {
        self.scanForLocksAction()
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
        
        for lock in self.locks {
            let uuid = lock.beacon.uuid
            let majorValue = CLBeaconMajorValue(lock.beacon.major)
            let minorValue = CLBeaconMinorValue(lock.beacon.minor)
            let identifier = lock.beacon.uuid
            
            let region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid)!, major: majorValue, minor: minorValue, identifier: identifier)
            
            locationManager.startRangingBeacons(in: region)
        }
        
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
            case .far:
                self.distanceInformationOfLock.text = "distance far"
                print("far")
            case .near:
                self.distanceInformationOfLock.text = "distance near"
                self.unlockForBeacon(for: becon.proximityUUID.uuidString)
                print("near")
            case .immediate:
                self.distanceInformationOfLock.text = "distance immediate"
                print("immediate")
            }
        }
    }
    
}
