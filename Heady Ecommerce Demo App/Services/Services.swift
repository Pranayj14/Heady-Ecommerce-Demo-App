//
//  Services.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 03/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//

import Foundation

class Services {
    typealias JSONHandler = (AnyObject?, HTTPURLResponse,Error?) -> Void
    
    //MARK: api call to get post api response
    func getApiResponseGetMethod(apiUrl: String, completion: @escaping JSONHandler){
        DispatchQueue.main.async {
            let url = URL(string:apiUrl)!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { print(error!); return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as AnyObject
                    DispatchQueue.main.async {
                        completion(json,response as! HTTPURLResponse,error)
                    }
                    
                } catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
}
