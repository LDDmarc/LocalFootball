//
//  DataProcessing.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import CoreData

class DataProcessing {
    
    static let shared = DataProcessing()
    private init() { }
    
    func loadData<T: Decodable>(from fileName: String, withExtension: String, into context: NSManagedObjectContext) -> [T] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: withExtension) else {
            fatalError("File \(fileName).\(withExtension) not found.")
        }
        do {
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            
            jsonDecoder.userInfo[CodingUserInfoKey.context!] = context
            do {
                let object = try jsonDecoder.decode([T].self, from: data)
                do {
                    try context.save()
                    return object
                } catch {
                    fatalError("Failed to save")
                }
            } catch  {
                fatalError("Failed to decode")
            }
            
        } catch {
            fatalError("Failed to create data")
        }
    }
    
    func getDataFromCoreData<T: NSManagedObject & Decodable>(with context: NSManagedObjectContext, orFrom fileName: String, withExtension: String) -> [T] {
        
        guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else { return [] }
       // fetchRequest.predicate = NSPredicate(format: "name != nil")
        //let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
       // fetchRequest.sortDescriptors = [nameSortDescriptor]
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                return loadData(from: fileName, withExtension: withExtension, into: context)
            }
            return results
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return []
    }
}
