//
//  DataManagerProtocol.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation

enum MatchesStatus {
    case past
    case future
}

enum DataManagerError {
    case networkUnavailable
    case wrongDataFormat
    case noData
    case wrongURL
    case wrongDateFormat
    case coreDataError
    case failedToSaveToCoreData
    case isAlreadyLoading
}

protocol DataManagerProtocol {
    var baseURL: String { get }
    func getAllData(completion: @escaping(_ data: Data?, _ error: DataManagerError?) -> Void)
    func getMatchesData(matchesStatus: MatchesStatus, from date: Date?, completion: @escaping(_ data: Data?, _ error: DataManagerError?) -> Void)
}
