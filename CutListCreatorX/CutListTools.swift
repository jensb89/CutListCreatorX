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

// Write General Informations
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
    
    func saveCutList(videoFileName:String, version:String, frameRate:Double, fileSize:Int, frameOffset:Int) {
        let cutListFile = "file:///" + videoFileName + ".cutlist"
        var text = writeCutlistGeneralInfos(ver:version, fps:frameRate)
        if cutTimes.count % 2 == 0{
            text += "NoOfCuts=" + String(cutTimes.count/2) + "\n"
        }
        else{
            print("Odd number of cuts!!!")
            text += "NoOfCuts=" + String((cutTimes.count+1)/2) + "\n"
        }
        text += "ApplyToFile=" + "\n" //TODO
        text += "OriginalFileSizeBytes=" + String(fileSize) + "\n" //TODO
        text += "\n"
        
        var cutNo:Int = 0
        for i in 0..<(cutTimes.count-1) {
            if i % 2 == 0 {
                text += "[Cut" + String(cutNo) + "]\n"
                text += "Start=" + String(cutTimes[i]) + "\n"
                if(frameRate > 0){
                    text += "StartFrame" + String(Int(cutTimes[i]*frameRate) + frameOffset) + "\n"
                }
                text += "Duration=" + String(cutTimes[i+1]-cutTimes[i]) + "\n"
                if(frameRate > 0){
                    text += "DurationFrames=" + String(Int((cutTimes[i+1]-cutTimes[i])*frameRate) + frameOffset) + "\n"
                }
                text += "\n"
                cutNo += 1
            }
        }
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
        do{
            try text.write(to:URL(string:cutListFile)!, atomically: false, encoding: .utf8)
        }
        catch { /* error handling */ }
    }

}
