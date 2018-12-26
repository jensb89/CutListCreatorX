//
//  ViewControllerUpload.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 26.12.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Cocoa

class ViewControllerUpload: NSViewController {
    
    let defaults = UserDefaults.standard
    var sniplistID:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Get Sniplist ID from User Defaults
        let key =  defaults.string(forKey: "sniplistID")
        if key != nil {
            sniplistID = key!
        }
        sniplistIDField.stringValue = sniplistID
        
    }
    
    
    @IBOutlet weak var sniplistIDField: NSTextField!
    
    @IBAction func cancelCallback(_ sender: NSButton) {
        self.dismiss(true)
    }
    @IBAction func uploadCallback(_ sender: NSButton) {
        print(sniplistIDField.stringValue)
        defaults.set(sniplistIDField.stringValue,forKey:"sniplistID")
        print("Defaults set")
        print(defaults.string(forKey: "sniplistID"))
    }
}
