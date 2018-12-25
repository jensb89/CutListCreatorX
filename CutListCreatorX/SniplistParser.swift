//
//  SniplistParser.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 23.12.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Cocoa

class Sniplist : NSObject {
    // a few constants that identify what element names we're looking for inside the XML

    let recordKey = "cutlist"
    let dictionaryKeys = Set<String>(["downloadcount", "ratingbyauthor", "name", "author", "id"])

    // a few variables to hold the results as we parse the XML

    var results: [[String: String]]?         // the whole array of dictionaries
    var currentDictionary: [String: String]? // the current dictionary
    var currentValue: String?                // the current value for one of the keys in the dictionary

    
    // Load Results
    func loadResults(fileName:String){
        let urlString = "http://www.cutlist.at/getxml.php?name=" + fileName
        let url = URL(string: urlString)
        
        print("Starting request with url:" + (url?.absoluteString)!)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            //print(response)
            //print(String.init(data: data, encoding: String.Encoding.utf8))
            
            //PARSER
            let parser = XMLParser(data: data)
            parser.delegate = self
            if parser.parse() {
                print(self.results ?? "No results")
            }
        }
        task.resume()
    }
    
    
    
    /// UPLOAD
    func uploadCutlist(){
        var cutliststr = ""
        do {
            cutliststr = try String(contentsOf: URL(string: "file:///Users/user/test.cutlist")!, encoding: .utf8)
        }
        catch {/* error handling here */print("ERROR")}
        
        var request : URLRequest?
        do{
            request = try createRequest()
        }
        catch{print("Request could not be created")}
        
        let task = URLSession.shared.dataTask(with: request! as URLRequest) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            //print(response)
            print(String.init(data: data, encoding: String.Encoding.utf8))
        }
        task.resume()
    }
    
    
    
    /// Create request
    ///
    /// - parameter userid:   The userid to be passed to web service
    /// - parameter password: The password to be passed to web service
    /// - parameter email:    The email address to be passed to web service
    ///
    /// - returns:            The `URLRequest` that was created
    
    func createRequest() throws -> URLRequest {
        let parameters = [
            "userid"  : "abc123",
            "version"    : "1",
            "confirm" : "true",
            "type"     : "blank",
            "MAX_FILE_SIZE" : "10000000"]
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: "http://cutlist.at/abc123/index.php?upload=2")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let file = "file:///Users/user/test.cutlist"
        var data = Data()
        do{
            data = try createBody(with: parameters, filePathKey: "file", paths: [file], boundary: boundary)
        }
        catch{print("ERROR2")}
        request.httpBody = data
        
        return request
    }
    
    
    /// Create body of the `multipart/form-data` request
    ///
    /// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
    /// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// - parameter paths:        The optional array of file paths of the files to be uploaded
    /// - parameter boundary:     The `multipart/form-data` boundary
    ///
    /// - returns:                The `Data` of the body of the request
    
    private func createBody(with parameters: [String: String]?, filePathKey: String, paths: [String], boundary: String) throws -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for path in paths {
            let url = URL(string: path)
            let filename = url?.lastPathComponent
            let data = try Data(contentsOf: url!)
            print(data)
            let mimetype = mimeType(for: path as String)
            print(mimetype)
            
            body.append("--\(boundary)\r\n")
            //body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Disposition: form-data; name=\"userfile[]\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires `import MobileCoreServices`.
    ///
    /// - parameter path:         The path of the file for which we are going to determine the mime type.
    ///
    /// - returns:                Returns the mime type if successful. Returns `application/octet-stream` if unable to determine mime type.
    
    private func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}


extension Data {
    
    /// Append string to Data
    ///
    /// This defaults to converting using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `Data`.
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}


extension Sniplist: XMLParserDelegate {
    // Compare https://stackoverflow.com/a/31084545/1635696
    // initialize results structure
    
    func parserDidStartDocument(_ parser: XMLParser) {
        results = []
    }
    
    // start element
    //
    // - If we're starting a "cutlist" create the dictionary that will hold the results
    // - If we're starting one of our dictionary keys, initialize `currentValue` (otherwise leave `nil`)
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == recordKey {
            currentDictionary = [:]
        } else if dictionaryKeys.contains(elementName) {
            currentValue = ""
        }
    }
    
    // found characters
    //
    // - If this is an element we care about, append those characters.
    // - If `currentValue` still `nil`, then do nothing.
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    // end element
    //
    // - If we're at the end of the whole dictionary, then save that dictionary in our array
    // - If we're at the end of an element that belongs in the dictionary, then save that value in the dictionary
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == recordKey {
            results!.append(currentDictionary!)
            currentDictionary = nil
        } else if dictionaryKeys.contains(elementName) {
            currentDictionary![elementName] = currentValue
            currentValue = nil
        }
    }
    
    // Just in case, if there's an error, report it. (We don't want to fly blind here.)
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
        
        currentValue = nil
        currentDictionary = nil
        results = nil
    }
    
}
