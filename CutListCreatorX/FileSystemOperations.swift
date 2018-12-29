//
//  FileSystemOperations.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 23.12.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Foundation
import Cocoa


// Load File From Disk
func loadFile() -> String {
    
    // OPEN DIALOG
    let dialog = NSOpenPanel();
    
    dialog.title                   = "Choose a .mp4 file";
    dialog.showsResizeIndicator    = true;
    dialog.showsHiddenFiles        = false;
    dialog.canChooseDirectories    = false;
    dialog.canCreateDirectories    = true;
    dialog.allowsMultipleSelection = false;
    dialog.allowedFileTypes        = ["mp4","cutlist"];
    
    if (dialog.runModal() == NSModalResponseOK) {
        let result = dialog.url // Pathname of the file
        
        if (result != nil) {
            let path = result!.path
            print(path)
            return path
        }
    }
    else {
        // User clicked on "Cancel"
    }
    return String("")
    
}
