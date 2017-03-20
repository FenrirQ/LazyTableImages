//
//  DataServices.swift
//  LazyTableImages
//
//  Created by Trương Thắng on 3/20/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//

import Foundation

class DataServices {
    static let shared : DataServices = DataServices()
    
    private var _entries : [AppRecord] = []
    var entries : [AppRecord] {
        get {
            if _entries.count == 0 {
                updateEntries()
            }
            return _entries
        }
        set {
            _entries = newValue
        }
    }
    
    func updateEntries() {
        _entries = [
            AppRecord(),
            AppRecord(),
            AppRecord(),
            AppRecord(),
        ]
        NotificationCenter.default.post(name: NotificationKey.didUpdateEntries, object: nil)
        
    }
}

struct NotificationKey {
    static let didUpdateEntries = NSNotification.Name(rawValue:"did up date entries")
}
