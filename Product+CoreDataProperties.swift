//
//  Product+CoreDataProperties.swift
//  P2PSelected
//
//  Created by frank on 15/11/5.
//  Copyright © 2015年 frank. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var author: String?
    @NSManaged var content: NSData?
    @NSManaged var detail: NSData?
    @NSManaged var head: NSData?
    @NSManaged var icon: NSData?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var title: String?

}
