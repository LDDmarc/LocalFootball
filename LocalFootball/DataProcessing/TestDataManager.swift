//
//  TestDataManager.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation

class TestDataManager: DataManagerProtocol {

    var baseURL: String = "fullRequest2"

    var pastMatchesURL: String = "matches1"
    var futureMatchesURL: String = "matches2"

    enum Scenario: Int {
        case networkUnavailable = 1
        case wrongDataFormat
        case noData
        case wrongURL
        case wrongDateFormat
        case coreDataError
        case failedToSaveToCoreData
        case isAlreadyLoading
        case fullRequest2
        case fullRequest3
    }

//    var arrayOfScenario: [Scenario] = [Scenario.networkUnavailable, Scenario.networkUnavailable, Scenario.networkUnavailable, Scenario.networkUnavailable, Scenario.fullRequest2, Scenario.wrongURL, Scenario.wrongDataFormat, Scenario.fullRequest3]
     var arrayOfScenario: [Scenario] = [Scenario.networkUnavailable, Scenario.coreDataError, Scenario.wrongDataFormat]
//    var arrayOfScenario: [Scenario] = []

    func getAllData(completion: @escaping (Data?, DataManagerError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !self.arrayOfScenario.isEmpty {
                let scenario = self.arrayOfScenario.removeFirst()
                switch scenario {
                case .networkUnavailable:
                    completion(nil, DataManagerError.networkUnavailable)
                case .wrongURL:
                    completion(nil, DataManagerError.wrongURL)
                case .wrongDataFormat:
                    completion(nil, DataManagerError.wrongDataFormat)
                case .coreDataError:
                    completion(nil, DataManagerError.coreDataError)
                case .fullRequest2:
                    guard let url = Bundle.main.url(forResource: "fullRequest2", withExtension: "json") else {
                        completion(nil, DataManagerError.wrongURL)
                        return
                    }
                    do {
                        let data = try Data(contentsOf: url)
                        completion(data, nil)
                    } catch {
                        completion(nil, DataManagerError.wrongDataFormat)
                    }
                case .fullRequest3:
                    guard let url = Bundle.main.url(forResource: "fullRequest3", withExtension: "json") else {
                        completion(nil, DataManagerError.wrongURL)
                        return
                    }
                    do {
                        let data = try Data(contentsOf: url)
                        completion(data, nil)
                    } catch {
                        completion(nil, DataManagerError.wrongDataFormat)
                    }
                default:
                    completion(nil, DataManagerError.noData)
                }
            } else {
                guard let url = Bundle.main.url(forResource: "fullRequest3", withExtension: "json") else {
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
    }

    func getMatchesData(matchesStatus: MatchesStatus, from date: Date?, completion: @escaping (Data?, DataManagerError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard date != nil else {
                completion(nil, DataManagerError.wrongDateFormat)
                return
            }

            var urlString: String
            switch matchesStatus {
            case .past:
                urlString = self.pastMatchesURL
            case .future:
                urlString = self.futureMatchesURL
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

            completion(nil, DataManagerError.noData)
        }

    }
}
