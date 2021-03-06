//
//  KisiAPI.swift
//  Kisi demo application
//
//  Created by Raja on 27/09/18.
//  Copyright © 2018 FullCreative. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let BASE_URL = "https://api.getkisi.com"

enum AppError: Error {
    case InvalidParam(String)
    
    var description: String {
        switch self {
        case .InvalidParam(let error):
            return error
        }
    }
}

protocol ApiUrlRequest: URLRequestConvertible { }

extension ApiUrlRequest {
    
    func mutableUrlRequest(baseUrl: String, path: String, method: Alamofire.HTTPMethod, queruParams: Parameters?, params: Parameters?, encoding: Alamofire.ParameterEncoding = JSONEncoding.default) throws -> URLRequest {
        
        guard let url = URL(string: baseUrl) else {
            throw AppError.InvalidParam("URL is invalid")
        }
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        if let queryParams = queruParams {
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: queryParams)
        }
        
        urlRequest.httpMethod = method.rawValue
        urlRequest = addDefaultHeaders(request: urlRequest)
        
        return try encoding.encode(urlRequest, with: params)
    }
    
    fileprivate func addDefaultHeaders(request: URLRequest) -> URLRequest {
        var req = request
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }
    
    func addAuthorization(request: URLRequest, isAuthorizationToken: Bool) -> URLRequest {
        var req = request
        req.setValue("KISI-LOGIN \(isAuthorizationToken ? (UserDefaults.standard.string(forKey: AUTHORIZATION_TOKEN) ?? ""): (UserDefaults.standard.string(forKey: SECRET) ?? ""))", forHTTPHeaderField: "Authorization")
        return req
    }
    
}

enum KisiURLRequest: ApiUrlRequest {
    
    // POST https://api.getkisi.com/users/sign_up_token/sign_up the signup token is not needed can leave as blank https://api.getkisi.com/users//sign_up
    case signUpUser(name: String, email: String, password: String, terms_and_conditions: Bool)
    
    // POST https://api.getkisi.com/users/sign_in
    case signIn(email: String, password: String)
    
    // POST https://api.getkisi.com/users/sign_out no parameters requrired as per the documentation
    case signOut()
    
    // GET https://api.getkisi.com/places?name=FULL%20CREATIVE%20%5BCHENNAI%5D&user_id=0&transfer_to_id=0 parameters are optional
    // use this to get all the places that the user has access to and then using this place id fetch the lock information
    case getPlaceInformation(name: String?, user_id: Int?, transfer_to_id: Int?)
    
    // GET https://api.getkisi.com/locks?name=name&online=true&assigned=true&gateway_id=0&place_id=5850 returns all the locks available can be filtered by the above parameters
    case getLockInformation(name: String?, online: Bool?, assigned: Bool?, gateway_id: Int?, place_id: Int?)
    
    // POST https://api.getkisi.com/locks/(lock_id)/unlock
    case unlock(app: App?, becons: Becons?, device: Device?, location: Location?, os: OS?, services: Services?, wifi: Wifi?, lockId: String)
    
    
    func asURLRequest() throws -> URLRequest {
        
        let requestDetails: (method: HTTPMethod, queryParams: Parameters?, params: Parameters?, path: String, encoding: Alamofire.ParameterEncoding) = {
            
            switch self {
                
            case .signUpUser:
                
                return(.post, nil, nil, "/users/sign_up", JSONEncoding.default)
                
            case .signIn:
                
                return (.post, nil, nil, "/users/sign_in", JSONEncoding.default)
                
            case .signOut:
                
                return (.post, nil, nil, "/users/sign_out", JSONEncoding.default)
            
            case .getPlaceInformation(let name, let user_id, let transfer_to_id):
                
                let name_value = name != nil ? name! : ""
                let user_id_Value = user_id != nil ? String(user_id!) : ""
                let transfer_to_id_value = transfer_to_id != nil ? String(transfer_to_id!) : ""
                
                let queryParams: [String: Any] = ["name": name_value, "user_id": user_id_Value, "transfer_to_id": transfer_to_id_value]
                
                return (.get, queryParams, nil, "/places", JSONEncoding.default)
                
            case .getLockInformation(let name, let online, let assigned, let gateway_id, let place_id):
                
                let nameValue = name != nil ? name! : ""
                let onlineValue = online != nil ? String(online!) : ""
                let assignedValue = assigned != nil ? String(assigned!) : ""
                let gateway_id_Value = gateway_id != nil ? String(gateway_id!) : ""
                let place_id_Value = place_id != nil ? String(place_id!) : ""
                
                let quertParams: [String: Any] = ["name": nameValue, "online": onlineValue, "assigned": assignedValue, "gateway_id": gateway_id_Value, "place_id": place_id_Value]
                
                return (.get, quertParams, nil, "/locks", JSONEncoding.default)
                
            case .unlock(_, _, _, _, _, _, _, let lockId):
                
                return (.post, nil, nil, "/locks/\(lockId)/unlock", JSONEncoding.default)
            }
        }()
        
        var rawBody: Data? {
            
            switch self {
            case .unlock(let app, let becons, let device, let location, let os, let services, let wifi, _):
                return "{\n  \"context\": {\n    \"app\": \(app?.toJSONstring() ?? "no app"),\n    \"beacons\": [\(becons?.toJSONstring() ?? "no becons")    ],\n    \"device\": \(device?.toJSONstring() ?? "no device"),\n    \"location\": \(location?.toJSONstring() ?? "no location"),\n    \"os\": \(os?.toJSONstring() ?? "no os"),\n    \"services\": [\n      \(services?.toJSONstring() ?? "no services")    ],\n    \"wifi\": \(wifi?.toJSONstring() ?? "no wifi")  }\n}".data(using: .utf8)
                
             case .signUpUser(let name, let email, let password, let terms_and_condition):
                return """
                {
                    "user": {
                        "email": "\(email)",
                        "name": "\(name)",
                        "password": "\(password)",
                        "terms_and_conditions": \(terms_and_condition)
                    }
                }
                """.data(using: .utf8)
                
             case .signIn(let email, let password):
                return "{\n  \"user\": {\n    \"email\": \"\(email)\",\n    \"password\": \"\(password)\"\n  }\n}".data(using: .utf8)
                
            default:
                return nil
            }
        }
        
        let url = BASE_URL
        
        var request = try! mutableUrlRequest(baseUrl: url, path: requestDetails.path, method: requestDetails.method, queruParams: requestDetails.queryParams, params: requestDetails.params)
        
        if rawBody != nil {
            request.httpMethod = "POST"
            request.httpBody = rawBody
        }
        
        var finalRequest: URLRequest = addDefaultHeaders(request: request)
        
        finalRequest = {
            switch self {
  
            case .signOut:
                
                return addAuthorization(request: request, isAuthorizationToken: true)
                
            case .getPlaceInformation:
                
                return addAuthorization(request: request, isAuthorizationToken: true)
                
            case .getLockInformation:
                
                return addAuthorization(request: request, isAuthorizationToken: true)
                
            case .unlock:
                
                return addAuthorization(request: request, isAuthorizationToken: true)

            default:
                return request
            }
        }()
        
        return finalRequest
    }
}

class KisiApiService {
    
    typealias ApiResponseHandler = ( _ responseJson : JSON?, _ response : HTTPURLResponse?, _ error : Error?) -> Void

    func makeApiRequest(urlRequest: URLRequestConvertible, handler: ApiResponseHandler?) -> Request {
        
        return Alamofire.request(urlRequest).responseJSON { dataResponse in
            
            if let completion = handler {
                completion(JSON(dataResponse.data ?? Data()), dataResponse.response, dataResponse.error)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: ApiResponseHandler?) {
        
        _ = makeApiRequest(urlRequest: KisiURLRequest.signIn(email: email, password: password)) { (responseJSON, response, error) in
            
            guard error == nil else {
                completion?(nil, nil, error)
                return
            }
            completion?(responseJSON, response, nil)
        }
    }
    
    func getPlaceInformation(name: String? = nil, user_id: Int? = nil, transfer_to_id: Int? = nil, completion: ApiResponseHandler?) {
        
        _ = makeApiRequest(urlRequest: KisiURLRequest.getPlaceInformation(name: name, user_id: user_id, transfer_to_id: transfer_to_id)) { (responseJSON, response, error) in
            guard error == nil else {
                completion?(nil, nil, error)
                return
            }
            completion?(responseJSON, response, nil)
        }
    }
    
    func retriveLockInformation(name: String? = nil, online: Bool? = nil, assigned: Bool? = nil, gateway_id: Int? = nil, place_id: Int? = nil, completion: ApiResponseHandler?) {
        
        _ = makeApiRequest(urlRequest: KisiURLRequest.getLockInformation(name: name, online: online, assigned: assigned, gateway_id: gateway_id, place_id: place_id)) { (responseJSON, response, error) in
            
            guard error == nil else {
                completion?(nil, nil, error)
                return
            }
            completion?(responseJSON, response, nil)
        }
    }
    
    func unlockDoor(app: App?, becons: Becons?, device: Device?, location: Location?, os: OS?, services: Services?, wifi: Wifi?, lockId: String, completion: ApiResponseHandler?) {
        
        _ = makeApiRequest(urlRequest: KisiURLRequest.unlock(app: app, becons: becons, device: device, location: location, os: os, services: services, wifi: wifi, lockId: lockId)) { (responseJSON, response, error) in
            
            guard error == nil else {
                completion?(nil, nil, error)
                return
            }
            completion?(responseJSON, response, nil)
        }
    }
    
    func signOut(completions: ApiResponseHandler?) {
        _ = makeApiRequest(urlRequest: KisiURLRequest.signOut()) { (responseJSON, response, error) in
            
            guard error == nil else {
                completions?(nil, nil, error)
                return
            }
            completions?(responseJSON, response, nil)
        }
    }
}
