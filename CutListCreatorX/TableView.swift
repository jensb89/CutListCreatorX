//
//  TableView.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 23.12.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Cocoa


extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cutList.cutTimes.count
    }
}

extension ViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let CutCell = "cutNumberCellID"
        static let TimeCell = "timeCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        //var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        
        
        // Error check
        //guard let item = items[row] else {
        //    return nil
        //}
        
        // Set the cell identifier and text based on the column
        if tableColumn == tableView.tableColumns[0] {
            //image = item.icon
            text = String(row)
            print(text)
            cellIdentifier = CellIdentifiers.CutCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(cutList.cutTimes[row])
            cellIdentifier = CellIdentifiers.TimeCell
        }
        
        // Creates or reuses a cell with a given identifier and fill it with data
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            //cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }
    
}
