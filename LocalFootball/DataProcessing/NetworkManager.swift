//
//  NetworkManager.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 19.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import CoreData

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }
  
    private let baseURL = URL(string: "https://football-ios2020.herokuapp.com/")
    private let urlSession = URLSession.shared
  
    func getData(urlString: String, completion: @escaping(_ data: Data?, _ error: Error?) -> ()) {
        
        guard let url = baseURL?.appendingPathComponent(urlString) else { return }
        urlSession.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.networkUnavailable.rawValue, userInfo: nil)
                completion(nil, error)
                return
            }
            
            completion(data, nil)
        }.resume()
    }

}
