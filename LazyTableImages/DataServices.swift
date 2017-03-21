//
//  DataServices.swift
//  LazyTableImages
//
//  Created by Trương Thắng on 3/20/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//

import UIKit

class DataServices {
    static let shared : DataServices = DataServices()
    var parseOperator : ParseOperation?
    
    // create the queue to run our ParseOperation
    var queue : OperationQueue? = OperationQueue()
    let topPaidAppsFeed = "http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml"
    
    private var _entries : [AppRecord] = [] {
        didSet {
            NotificationCenter.default.post(name: NotificationKey.didUpdateEntries, object: nil)
        }
    }
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
        guard let url = URL(string: topPaidAppsFeed) else {return}
        let request = URLRequest(url: url)
        let downloadTask = URLSession.shared.dataTask(with: request){[unowned self] (data, response, error) in
            guard  error == nil else {
                self.handleError(error!)
                return
            }
            // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
            guard data != nil else { return }
            self.parseOperator = ParseOperation(data: data!)
            self.parseOperator?.errorHandler = {[unowned self](error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.handleError(error)
            }
            self.parseOperator?.completionBlock = {[unowned self] in
                // The completion block may execute on any thread.  Because operations
                // involving the UI are about to be performed, make sure they execute on the main thread.
                //
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard let appRecordList = self.parseOperator?.appRecordList else {
                    return
                }
                self._entries = appRecordList

                // we are finished with the queue and our ParseOperation
                self.queue = nil
            }
            
            // this will start the "ParseOperation"
            self.queue?.addOperation(self.parseOperator!)
        }
        downloadTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func handleError(_ error: Error) {
        
    }
    
    
}

struct NotificationKey {
    static let didUpdateEntries = NSNotification.Name(rawValue:"did up date entries")
}
