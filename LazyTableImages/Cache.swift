//
//  Cache.swift
//  LazyTableImages
//
//  Created by Trương Thắng on 4/11/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//

import Foundation

class Cache {
    static var images : NSCache<NSString, AnyObject> = {
        let result = NSCache<NSString, AnyObject>()
        result.countLimit = 30
        result.totalCostLimit = 10 * 1024 * 1024
        return result
    }()
}
