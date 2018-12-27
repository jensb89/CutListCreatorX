//
//  CutListTools.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 23.12.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Foundation
import Cocoa

class Cutlist {
    
    var cutTimes = [Double]()
    var author:String = "unknownAuthor"
    var rating:Int = 0
    var userComment:String = ""
    var suggestedFileName:String = ""
    var version = "0.2-alpha"

    // Helper: Write General Informations
    func writeCutlistGeneralInfos(ver:String, fps:Double) -> String {
        // TODO: COnvert to Swift 4: Multiline strings
        let str = "[General]\n"
            + "Application=CutlistCreatorX\n"
            + "Version=" + ver + "\n"
            + "FramesPerSecond=" + String(fps) + "\n"
            + "IntendedCutApplicationName=AVCut\n"
            + "IntendedCutApplication=avcut\n"
            + "VDUseSmartRendering=1\n"
            + "comment1=The following parts of the movie will be kept, the rest will be cut out.\n"
            + "comment2=All values are given in seconds.\n"
        return str
    }
    
    // Helper: Write author and rating informations
    func writeCutlistInfo() -> String {
        let str = "[Info]\n"
        + "Author=" + author + "\n"
        + "RatingByAuthor=" + String(rating) + "\n"
        + "EPGError=0" + "\n"
        + "ActualContent="  + "\n"
        + "MissingBeginning=0" + "\n"
        + "MissingEnding=0" + "\n"
        + "MissingVideo=0" + "\n"
        + "MissingAudio=0" + "\n"
        + "OtherError=0" + "\n"
        + "OtherErrorDescription=" + "\n"
        + "SuggestedMovieName=" + suggestedFileName + "\n"
        + "UserComment=" + userComment + "\n"
        return str
    }
    
    // Load Cutlist from file
    func loadCutlist(url:URL) {
        do{
            let fileStr = try String(contentsOf: url, encoding: .utf8)
            print(fileStr)
            let startTimes = fileStr.matchingStrings(regex: "Start=(\\d+\\.?\\d+)")
            let durations = fileStr.matchingStrings(regex: "Duration=(\\d+\\.?\\d+)")
            if (startTimes.count == durations.count){
                for i in 0..<startTimes.count {
                    cutTimes.append(Double(startTimes[i])!)
                    cutTimes.append(Double(startTimes[i])!+Double(durations[i])!)
                }
            }
            print(startTimes)
        }
        catch{
            print("Something went wrong")
        }
    }
    
    // save Cutlist to file
    func saveCutList(videoFileName:String, frameRate:Double, fileSize:Int, frameOffset:Int) {
        // Filename
        let cutListFile = "file:///" + videoFileName + ".cutlist"
        let url = URL(string: "file:///" + videoFileName)
        let fileName = url?.lastPathComponent
        
        // Write general infos : START
        var text = writeCutlistGeneralInfos(ver:version, fps:frameRate)
        
        // Calculate number of cuts
        if cutTimes.count % 2 == 0{
            text += "NoOfCuts=" + String(cutTimes.count/2) + "\n"
        }
        else{
            print("Odd number of cuts!!!")
            text += "NoOfCuts=" + String((cutTimes.count+1)/2) + "\n" // TODO: Show warn dialog
        }
        // File specifics
        text += "ApplyToFile=" + fileName! + "\n" //TODO
        text += "OriginalFileSizeBytes=" + String(fileSize) + "\n" //TODO
        text += "\n"
        // Write general infos : END
        
        // Write cuts
        var cutNo:Int = 0
        for i in 0..<(cutTimes.count-1) {
            if i % 2 == 0 {
                text += "[Cut" + String(cutNo) + "]\n"
                text += "Start=" + String(cutTimes[i]) + "\n"
                if(frameRate > 0){
                    text += "StartFrame=" + String(Int(cutTimes[i]*frameRate) + frameOffset) + "\n"
                }
                text += "Duration=" + String(cutTimes[i+1]-cutTimes[i]) + "\n"
                if(frameRate > 0){
                    text += "DurationFrames=" + String(Int((cutTimes[i+1]-cutTimes[i])*frameRate) + frameOffset) + "\n"
                }
                text += "\n"
                cutNo += 1
            }
        }
        
        // Write cutlist info: rating, author, errors, suggested filename etc:
        text += writeCutlistInfo()
        
        
        // Optional: Save in User DOcuments directory:
        /*
         if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
         
         let fileURL = dir.appendingPathComponent(file)
         
         //writing
         do {
         try text.write(to: fileURL, atomically: false, encoding: .utf8)
         }
         catch {/* error handling here */}
         }*/
        
        // Save to disk
        do{
            try text.write(to:URL(string:cutListFile)!, atomically: false, encoding: .utf8)
        }
        catch { /* error handling */
            print("Cutlist could not be saved!")
        }
    }

}
