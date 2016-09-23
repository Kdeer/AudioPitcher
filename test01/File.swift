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
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
        
        let entity =  NSEntityDescription.entity(forEntityName: "RecordedAudio", in: context)!
        
        super.init(entity: entity, insertInto: context)
        
        title = dictionary["title"] as! String
    }
}
