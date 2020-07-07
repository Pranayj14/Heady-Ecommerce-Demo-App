//
//  Category+CoreDataProperties.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 08/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var childCategory: NSObject?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?

}
