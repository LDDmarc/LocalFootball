//
//  NetworkManager.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 19.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
  // private let baseURL = URL(string: "https://football-ios2020.herokuapp.com/fullRequest2")
    private let baseURL = URL(string: "https://bmstu-ios.herokuapp.com/main_info")
    private let urlSession = URLSession.shared
    
    func getData(completion: @escaping(_ data: Data?, _ error: Error?) -> ()) {
        guard let url = baseURL else {
            let error = NSError(domain: dataErrorDomain, code: DataErrorCode.networkUnavailable.rawValue, userInfo: nil)
            completion(nil, error)
            return
        }
        // TODO: response
        urlSession.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }.resume()
    }
    
    func getMatchesData(pastMatches: Bool, beginningFrom date: Date?, completion: @escaping(_ data: Data?, _ error: Error?) -> ()) {
        var matchesURLString: String
        if pastMatches {
            if let date = date {
               // matchesURLString = "https://football-ios2020.herokuapp.com/pastMatches?date=\(date)"
                matchesURLString = "https://football-ios2020.herokuapp.com/matches1"
            } else {
                matchesURLString = "https://football-ios2020.herokuapp.com/matches1"
            }
        } else {
            if let date = date {
               // matchesURLString = "https://football-ios2020.herokuapp.com/futureMatches?date=\(date)"
                matchesURLString = "https://football-ios2020.herokuapp.com/matches2"
            } else {
                matchesURLString = "https://football-ios2020.herokuapp.com/matches2"
            }
        }
        guard let url = URL(string: matchesURLString) else {
            let error = NSError(domain: dataErrorDomain, code: DataErrorCode.networkUnavailable.rawValue, userInfo: nil)
            completion(nil, error)
            return
        }
        urlSession.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }.resume()
    }
    
    func testGetData(from fileName: String, completion: @escaping(_ data: Data?, _ error: Error?) -> ()) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("File \(fileName).json not found.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            completion(data, nil)
        } catch let error as NSError{
            completion(nil, error)
        }
    }
    
    func testGetMatchesData(pastMatches: Bool, beginningFrom date: Date?, completion: @escaping(_ data: Data?, _ error: Error?) -> ()) {
        var matchesURLString: String
        var forResourse: String
        if pastMatches {
            if let date = date {
                matchesURLString = "https://football-ios2020.herokuapp.com/pastMatches?date=\(date)"
            } else {
                matchesURLString = "https://football-ios2020.herokuapp.com/pastMatches"
            }
            forResourse = "matches1"
            //    print(matchesURLString)
        } else {
            if let date = date {
                matchesURLString = "https://football-ios2020.herokuapp.com/futureMatches?date=\(date)"
            } else {
                matchesURLString = "https://football-ios2020.herokuapp.com/futureMatches"
            }
            //      print(matchesURLString)
            forResourse = "matches2"
        }
        //        guard let url = URL(string: matchesURLString) else {
        //
        //        }
        guard let url = Bundle.main.url(forResource: forResourse, withExtension: "json") else {
            fatalError("File \(forResourse).json not found.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            completion(data, nil)
        } catch let error as NSError{
            completion(nil, error)
        }
    }
}
