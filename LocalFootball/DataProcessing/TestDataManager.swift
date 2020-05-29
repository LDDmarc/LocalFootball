//
//  TestDataManager.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation

class TestDataManager: DataManagerProtocol {
    
    var baseURL: String = "fullRequest11"
    
    var pastMatchesURL: String = "matches1"
    var futureMatchesURL: String = "matches2"
    
    func getAllData(completion: @escaping (Data?, DataManagerError?) -> ()) {
        guard let url = Bundle.main.url(forResource: baseURL, withExtension: "json") else {
            completion(nil, DataManagerError.wrongURL)
            return
        }
        do {
            let data = try Data(contentsOf: url)
            completion(data, nil)
        } catch {
            completion(nil, DataManagerError.wrongDataFormat)
        }
    }
    
    func getMatchesData(matchesStatus: MatchesStatus, from date: Date?, completion: @escaping (Data?, DataManagerError?) -> ()) {
        
        guard let date = date else {
            completion(nil, DataManagerError.wrongDateFormat)
            return
        }
        
        var urlString: String
        switch matchesStatus {
        case .past:
            urlString = pastMatchesURL
            print("matches?order=asc&after=\(date)")
        case .future:
            urlString = futureMatchesURL
            print("matches?order=dsc&before=\(date)")
        }
        
        guard let url = Bundle.main.url(forResource: urlString, withExtension: "json") else {
            completion(nil, DataManagerError.wrongURL)
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            completion(data, nil)
        } catch {
            completion(nil, DataManagerError.wrongDataFormat)
        }
    }
}
