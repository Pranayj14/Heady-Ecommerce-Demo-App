//
//  Ranking+CoreDataProperties.swift
//  Heady Ecommerce Demo App
//
//  Created by Saumya Verma on 08/07/20.
//  Copyright © 2020 Saumya Verma. All rights reserved.
//
//

import Foundation
import CoreData


extension Ranking {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ranking> {
        return NSFetchRequest<Ranking>(entityName: "Ranking")
    }

    @NSManaged public var count: Int32
    @NSManaged public var id: Int32
    @NSManaged public var productRanking: String?
    @NSManaged public var productName: String?

}
