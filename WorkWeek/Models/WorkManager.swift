//
//  WorkManager.swift
//  WorkWeek
//
//  Created by John Regner on 1/10/15.
//  Copyright (c) 2015 TRexTech. All rights reserved.
//

import UIKit

class WorkManager: NSObject {

    var arrived = [NSDate]()
    var left = [NSDate]()
    
    func allItems() -> [String] {
        var output:[String] = ["one","two","three","four","five",]
        let arrivedDescriptions: [String] = arrived.map{ "A: " + $0.description}
        output += arrivedDescriptions
        let departureDescriptions: [String] = left.map{ "D: " + $0.description }
        output += departureDescriptions
        return output
    }

    func addArrival(){
        println("Adding arrival")
        arrived += [NSDate()]
    }
    
    func addDeparture(){
        println("Adding departure")
        left += [NSDate()]
    }
    
}
