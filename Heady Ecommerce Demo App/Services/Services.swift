//
//  Services.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 03/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//

import Foundation
import Alamofire

class Services {
      var array = [String:Any]()
    var userDefaults = UserDefaults.standard
    typealias JSON = NSArray
    typealias JSONHandler = (JSON?, HTTPURLResponse?, Error?) -> Void
//    var error = errorResponse
//MARK: api call to get post api response
 func getApiResponseGetMethod(apiUrl: String, completion: @escaping JSONHandler){
//     let jsonObjectFailed : [String:Any] = errorResponse(message: "Server Side Error")
     DispatchQueue.main.async {
         
//         let postHeaders: HTTPHeaders = ["Content-Type": "application/json"]
        print(apiUrl)
        AF.request(apiUrl, encoding: JSONEncoding.default).responseJSON { response in
            print(response)
            switch response.result{
            case .success:
                let jsonArray =  response.value as! NSArray
                let JSON = jsonArray
                completion(JSON,response.response,response.error)
            case .failure:
                completion(nil,response.response,response.error)
            }
         
         }
     }
 }
}
