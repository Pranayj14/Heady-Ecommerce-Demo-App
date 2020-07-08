//
//  CoreDataModel.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 08/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataModel{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Save data in particular attribute of an entity of every object.
    func addDataForEntityAttributes(dict: NSDictionary,dict2: NSDictionary, entityName: String) {
        let context = self.appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        if(entityName == "Product"){
            entity.setValue(dict["id"] as? Int32 ?? 0, forKey: "id")
            entity.setValue(dict2["id"] as? Int32 ?? 0, forKey: "productId")
            entity.setValue(dict2["name"] as? String ?? "", forKey: "productName")
            entity.setValue(dict["name"] as? String ?? "", forKey: "name")
            entity.setValue(dict2["date_added"] as? String ?? "", forKey: "date")
            do {
                let context = self.appDelegate.persistentContainer.viewContext
                try context.save()
            } catch let error {
                print(error)
            }
            
        }else if(entityName == "SubCategory"){
            entity.setValue(dict["id"] as? Int32 ?? 0, forKey: "id")
            entity.setValue(dict["name"] as? String ?? "", forKey: "name")
            entity.setValue(dict["child_categories"] as? [AnyObject] ?? [], forKey: "childCategory")
            do {
                let context = self.appDelegate.persistentContainer.viewContext
                try context.save()
            } catch let error {
                print(error)
            }
        }else if(entityName == "Category") {
            entity.setValue(dict["id"] as? Int32 ?? 0, forKey: "id")
            entity.setValue(dict["name"] as? String ?? "", forKey: "name")
            entity.setValue(dict["child_categories"] as? [AnyObject] ?? [], forKey: "childCategory")
            do {
                let context = self.appDelegate.persistentContainer.viewContext
                try context.save()
            } catch let error {
                print(error)
            }
        }else{
            let rankingName = dict["ranking"] as? String ?? ""
            entity.setValue(dict["ranking"] as? String ?? "", forKey: "productRanking")
            entity.setValue(dict2["id"] as? Int32 ?? 0, forKey: "id")
            if rankingName == "Most Viewed Products" {
                entity.setValue(dict2["view_count"] as? Int32 ?? 0, forKey: "count")
            }else if rankingName == "Most OrdeRed Products" {
                entity.setValue(dict2["order_count"] as? Int32 ?? 0, forKey: "count")
            }else {
                entity.setValue(dict2["shares"] as? Int32 ?? 0, forKey: "count")
            }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
            request.predicate = NSPredicate(format: "productId = %d", dict2["id"] as? Int ?? 0)
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    entity.setValue((results[0] as AnyObject).value(forKey: "productName")! as? String ?? "", forKey: "productName")
                    do {
                        try context.save()
                    } catch let error {
                        print(error)
                    }
                }
            }catch {
                print("Couldn't fetch results")
            }
        }
    }
    
    // MARK: - Clear the data of the entity.
        func clearData(entityName:String) {
            let context = self.appDelegate.persistentContainer.viewContext
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                do {
                    let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                    _ = objects.map{$0.map{context.delete($0)}}
                    try context.save()
                } catch let error {
                    print("ERROR DELETING : \(error)")
                }
            }
        }
    }
    



