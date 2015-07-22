//
//  MemeModel.swift
//  MemeMe
//
//  Created by Omar Albeik on 22/07/15.
//  Copyright (c) 2015 Omar Albeik. All rights reserved.
//

import Foundation
import CoreData

@objc(MemeModel)

class MemeModel: NSManagedObject {

    @NSManaged var topText: String
    @NSManaged var bottomText: String
    @NSManaged var image: NSData
    @NSManaged var memedImage: NSData
    @NSManaged var date: NSDate

}
