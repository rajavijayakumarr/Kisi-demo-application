//
//  ViewController.swift
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

let kisiApiService = KisiApiService()

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    public let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestForLocation()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func requestForLocation() {
        self.locationManager.requestAlwaysAuthorization()
    }

    @IBAction func loginButtonAction(_ sender: Any) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        kisiApiService.loginUser(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "") { json, httpResponse, error in
            
            guard error == nil else {
                MBProgressHUD.hide(for: self.view, animated: true)
                print("Login failed with errors. response code: ", httpResponse?.statusCode as Any)
                print("error: ", error as Any)
                let alert = UIAlertController(title: "error", message: "response returned a \(String(describing: httpResponse?.statusCode)) error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            guard let json = json else { return }
            print(json as Any)
            let secret = json["secret"].stringValue
            let authenticationToken = json["authentication_token"].stringValue
            UserDefaults.standard.set(secret, forKey: SECRET)
            UserDefaults.standard.set(authenticationToken, forKey: AUTHORIZATION_TOKEN)
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "opendoorviewcontroller") as! OpenDoorViewController
            MBProgressHUD.hide(for: self.view, animated: true)
            self.present(viewController, animated: true)
            
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

