//
//  Product+CoreDataProperties.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 08/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var date: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var productId: Int32
    @NSManaged public var productName: String?

}
