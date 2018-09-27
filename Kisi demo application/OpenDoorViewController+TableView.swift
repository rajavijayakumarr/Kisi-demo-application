//
//  OpenDoorViewController+TableView.swift
//  Kisi demo application
//
//  Created by Raja on 27/09/18.
//  Copyright © 2018 FullCreative. All rights reserved.
//

import UIKit


extension OpenDoorViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameOfPlacesCell") as! LocksTableViewCell
        cell.locks = self.locks[indexPath.row]
        cell.textLabel?.text = self.locks[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! LocksTableViewCell
        
        let alert = UIAlertController(title: "confirmation", message: "do you want to unlock this door", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            self.unlock(lockId: cell.locks?.id ?? "", becon: cell.locks?.beacon ?? Becons(uuid: "", major: 0, minor: 0))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
}

class LocksTableViewCell: UITableViewCell {
    
    var locks: LocksInformation?
    
}
