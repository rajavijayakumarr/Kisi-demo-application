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

let LOGIN_ENDPOINT = "https://api.getkisi.com/users/sign_in"

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.requestForLocation()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func requestForLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func loginButtonAction(_ sender: Any) {
        
        let url = URL(string: LOGIN_ENDPOINT)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = "{\"user\": {\"email\": \"\(self.emailTextField.text ?? "no email")\",\"password\": \"\(self.passwordTextField.text ?? "no password")\"}}".data(using: .utf8)
        
        Alamofire.request(request).responseJSON { (responseData) in
            
            guard responseData.error == nil else {
                print("Login failed with errors. response code: ", responseData.response?.statusCode as Any)
                print("error: ", responseData.error as Any)
                let alert = UIAlertController(title: "error", message: "response returned a \(String(describing: responseData.response?.statusCode)) error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(alert, animated: true)
                
                return
            }
            
            let json = JSON(responseData.data!)
            print(json as Any)
            let secret = json["secret"].stringValue
            let authenticationToken = json["authentication_token"].stringValue
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "opendoorviewcontroller") as! OpenDoorViewController
            
            viewController.secret = secret
            viewController.authenticationToken = authenticationToken
            
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

