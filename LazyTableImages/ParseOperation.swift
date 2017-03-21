//
//  ParseOperation.swift
//  LazyTableImages
//
//  Created by Trương Thắng on 3/20/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//

import Foundation

class ParseOperation: Operation {
    var errorHandler: ((Error) -> Void)?
    var appRecordList: [AppRecord]?
    
    struct ElementName {
        static let kIDStr = "id"
        static let kNameStr = "im:name"
        static let kImageStr = "im:image"
        static let kArtistStr = "im:artist"
        static let kEntryStr = "entry"
    }
    
    
    var dataToParse: Data?
    var elementsToParse: [String] = {
        return [ElementName.kIDStr, ElementName.kNameStr, ElementName.kImageStr, ElementName.kArtistStr, ElementName.kEntryStr]
        
    }()
    
    var workingArray: [AppRecord] = []
    var workingEntry: AppRecord?
    var workingPropertyString: String = ""
    var isStoringCharacterData: Bool = false
    
    init(data: Data) {
        dataToParse = data
    }
    
    override func main() {
        let parse = XMLParser(data: dataToParse!)
        parse.delegate = self
        parse.parse()
        if !isCancelled {
            appRecordList = workingArray
        }
        resetWorkingProperties()
        
    }
    
    func resetWorkingProperties() {
        workingArray = []
        workingPropertyString = ""
        dataToParse = nil
    }
}

extension ParseOperation: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // Kiểm tra xem element name có phải là entry ko?
        // Và khởi tạo một AppRecord nếu đúng
        
        if  elementName == ElementName.kEntryStr  {
            workingEntry = AppRecord()
        }
        
        // Trong rất nhiều thẻ xml, có một số thẻ có giá trị, 
        // và một số thẻ sẽ bị bỏ qua
        // kiểm tra xem thẻ hiện tại có giá trị sử dụng hay không
        
        
        isStoringCharacterData = elementsToParse.contains(elementName)
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        guard workingEntry != nil else {return}
        
        // Nếu thẻ hiện tại có giá trị sử dụng thì mới tiếp tục.
        // Ko thì sẽ được bỏ qua
        
        if isStoringCharacterData {
            let trimmedString = self.workingPropertyString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.workingPropertyString = ""
            switch elementName {
            case ElementName.kIDStr:
                workingEntry?.appURLString = trimmedString
            case ElementName.kNameStr:
                workingEntry?.appName = trimmedString
            case ElementName.kImageStr:
                workingEntry?.imageURLString = trimmedString
            case ElementName.kArtistStr:
                workingEntry?.artist = trimmedString
            default:
                break
            }
        } else if elementName == ElementName.kEntryStr{
            workingArray.append(workingEntry!)
            workingEntry = nil
        }
        
    }
    
    // Trả về các Characters có trong thẻ hiện thời 
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isStoringCharacterData {
            self.workingPropertyString += string
        }

    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.errorHandler?(parseError)
    }
    
    
}
