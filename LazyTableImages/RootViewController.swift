//
//  LazyImagesTableVC.swift
//  LazyTableImages
//
//  Created by Trương Thắng on 3/20/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {
    var imageDownloadsInProgress : Dictionary<Int,IconDownloader> = [:]
    let appIconSize = CGSize(width: 48, height: 48)
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        terminateAllDownload()

    }
    
    func terminateAllDownload() {
        
        // dừng lại tất cả các connection đang pending
        
        let allDownloads = imageDownloadsInProgress.values
        allDownloads.forEach {$0.cancelDownload()}
        imageDownloadsInProgress.removeAll()
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NotificationKey.didUpdateEntries, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        terminateAllDownload()
    }
    
    func handleNotification(_ notification: Notification) {
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataServices.shared.entries.count
    }
    
    struct CellID {
        static var lazyTableCell = "LazyTableCell"
        static var placeholderCellIdentifier = "PlaceholderCell"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.lazyTableCell, for: indexPath)
        
        let appRecord = DataServices.shared.entries[indexPath.row]
        cell.detailTextLabel?.text = appRecord.artist
        cell.textLabel?.text = appRecord.appName
        if (appRecord.appIconData != nil) {
            cell.imageView?.image = UIImage(data: appRecord.appIconData!)?.cropIfNeed(aspectFillToSize: appIconSize)
        } else {
            if (self.tableView.isDragging == false && self.tableView.isDecelerating == false) {
                self.startDownloadIcon(for: appRecord, at: indexPath)
            }
            cell.imageView?.image = UIImage(named: "Placeholder.png")
        }
        
        return cell
    }
    
    func startDownloadIcon(for appRecord: AppRecord, at indexPath: IndexPath) {
        
        // Nếu iconDownloader đã có rồi thì dùng luôn.
        // Chưa có thì khởi tạo cho lần sau dùng lại
        
        var iconDowloader = imageDownloadsInProgress[indexPath.row]
        if iconDowloader == nil {
            iconDowloader = IconDownloader()
            iconDowloader?.appRecord = appRecord
            iconDowloader?.completionHandler = {[unowned self] in
                let cell = self.tableView.cellForRow(at: indexPath)
                guard let appIconData = appRecord.appIconData, let image = UIImage(data: appIconData)?.cropIfNeed(aspectFillToSize: self.appIconSize) else {
                    return
                }
                cell?.imageView?.image = image
            }
            imageDownloadsInProgress[indexPath.row] = iconDowloader
        }
        iconDowloader?.startDownload()
    }
    func loadImagesForOnscreenRows() {
        guard DataServices.shared.entries.count > 0 else {return}
        let visiblePaths = tableView.indexPathsForVisibleRows
        visiblePaths?.forEach {[unowned self] indexPath in
            let appRecord = DataServices.shared.entries[indexPath.row]
            if appRecord.imageURLString != nil {
                self.startDownloadIcon(for: appRecord, at: indexPath)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension RootViewController {
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenRows()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenRows()
    }
}

// MARK: - Crop Image Aspect Fill

extension UIImage {
    func cropIfNeed(aspectFillToSize size: CGSize) -> UIImage? {
        guard self.size != size else {return self}
        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - CGSize compaire

extension CGSize {
    static func != (first: CGSize, second: CGSize) -> Bool {
        return first.width != second.width || first.height != second.height
    }
}



