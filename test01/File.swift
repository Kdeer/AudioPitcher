//
//  File.swift
//  test01
//
//  Created by Iris on 2015-12-09.
//  Copyright © 2015 Udacity. All rights reserved.
//

import Foundation
import CoreData



class RecordedAudio: NSManagedObject{
    
    @NSManaged var title: String!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
        
        let entity =  NSEntityDescription.entityForName("RecordedAudio", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        title = dictionary["title"] as! String
    }
}
