//
//  NetworkManager.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 19.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation

class NetworkManager: DataManagerProtocol {

    var baseURL: String = "https://bmstu-ios.herokuapp.com/"

    func getAllData(completion: @escaping (Data?, DataManagerError?) -> Void) {
        guard let url = URL(string: baseURL + "main_info") else {
            completion(nil, DataManagerError.wrongURL)
            return
        }

        URLSession.shared.dataTask(with: url) {(data, _, error) in
            if error != nil {
                completion(nil, DataManagerError.networkUnavailable)
                return
            }
            completion(data, nil)
        }.resume()
    }

    func getMatchesData(matchesStatus: MatchesStatus, from date: Date?, completion: @escaping (Data?, DataManagerError?) -> Void) {
        guard let date = date else {
            completion(nil, DataManagerError.wrongDateFormat)
            return
        }

        let dateFormatter = DateFormatter()
        DateFormatter().dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let formatDate = dateFormatter.string(from: date)

        var urlString: String
        switch matchesStatus {
        case .past:
            urlString = baseURL + "matches?order=asc&before=\(formatDate)"
        case .future:
            urlString = baseURL + "matches?order=dsc&after=\(formatDate)"
        }

        guard let url = URL(string: urlString) else {
            completion(nil, DataManagerError.wrongURL)
            return
        }

        URLSession.shared.dataTask(with: url) {(data, _, error) in
            if error != nil {
                completion(nil, DataManagerError.networkUnavailable)
                return
            }
            completion(data, nil)
        }.resume()
    }
}
