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
    var sniplist:Sniplist = Sniplist()
    var selectedRadioButton = 0
    var cutlist:Cutlist!
    var fileName:String!
    var fps:Double!
    var fileSize:Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Get Sniplist ID from User Defaults
        let key =  defaults.string(forKey: "sniplistID")
        if key != nil {
            sniplist.ID = key!
        }
        sniplistIDField.stringValue = sniplist.ID
        print(UserCommentField.stringValue)
        
        // Get Author from User Defaults
        let author = defaults.string(forKey: "sniplistAuthor")
        if author != nil {
            AuthorField.stringValue = author!
        }
        
        // FileName
        FileNameField.stringValue = (URL(string: "file://" + fileName)?.lastPathComponent)!
    }
    
    @IBOutlet weak var sniplistIDField: NSTextField!
    
    @IBOutlet weak var AuthorField: NSTextField!
    @IBOutlet weak var FileNameField: NSTextField!
    @IBOutlet weak var SuggestedFileNameField: NSTextField!
    @IBOutlet weak var UserCommentField: NSTextField!
    @IBOutlet weak var statusField: NSTextField!
    
    @IBOutlet weak var r0: NSButton! //Not needed?
    @IBOutlet weak var r1: NSButton! //Not needed?
    @IBOutlet weak var r2: NSButton! //Not needed?
    @IBOutlet weak var r3: NSButton! //Not needed?
    @IBOutlet weak var r4: NSButton! //Not needed?
    @IBOutlet weak var r5: NSButton! //Not needed?

    @IBAction func radioBtnsClb(_ sender: NSButton) {
        selectedRadioButton = sender.tag
        print(selectedRadioButton)
    }
    
    @IBAction func cancelCallback(_ sender: NSButton) {
        self.dismiss(true)
    }
    
    func prepare(){
        // Update User ID
        print(sniplistIDField.stringValue)
        defaults.set(sniplistIDField.stringValue,forKey:"sniplistID")
        sniplist.ID = defaults.string(forKey: "sniplistID")!
        
        // Update Author
        defaults.set(AuthorField.stringValue,forKey:"sniplistAuthor")
        
        // Update Cutlist infos
        cutlist.author = AuthorField.stringValue;
        cutlist.suggestedFileName = SuggestedFileNameField.stringValue
        cutlist.userComment = UserCommentField.stringValue.isEmpty ? "Mit CutlistCreatorX erstellt." : UserCommentField.stringValue
        cutlist.rating = selectedRadioButton
    }
    
    @IBAction func saveCutlistBtn(_ sender: NSButton) {
        prepare()
        cutlist.saveCutList(videoFileName: fileName!, frameRate: fps, fileSize: fileSize, frameOffset: 1)
    }
    @IBAction func uploadCallback(_ sender: NSButton) {
        // Save cutlist to disk
        prepare()
        cutlist.saveCutList(videoFileName: fileName!, frameRate: fps, fileSize: fileSize, frameOffset: 1)
        
        // Upload Cutlist to Sniplist
        sniplist.uploadCutlist(filePath: fileName + ".cutlist"){status in //Completion Handler: set status after async upload call
            self.statusField.stringValue = status
        }
    }
}
