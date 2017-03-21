//
//  IconDownloader.swift
//  LazyTableImages
//
//  Created by Trương Thắng on 3/21/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//

import Foundation

class IconDownloader {
    var appRecord: AppRecord?
    var completionHandler: (() -> Void)?
    var downloadTask: URLSessionDataTask?
    
    func startDownload() {
        guard appRecord != nil else {return}
        guard let url = URL(string: appRecord!.imageURLString ?? "") else {return}
        let request = URLRequest(url: url)
        downloadTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            OperationQueue.main.addOperation {[unowned self] in
                self.appRecord?.appIconData = data
                self.completionHandler?()
            }
            
        }
        downloadTask?.resume()
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
    }
}
