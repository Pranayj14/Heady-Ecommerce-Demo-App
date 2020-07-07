//
//  SubCategory+CoreDataProperties.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 08/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//
//

import Foundation
import CoreData


extension SubCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubCategory> {
        return NSFetchRequest<SubCategory>(entityName: "SubCategory")
    }

    @NSManaged public var childCategory: NSObject?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?

}
