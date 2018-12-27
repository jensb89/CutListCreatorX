//
//  VideoTools.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 23.12.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

// Use FFPROBE to obtain information about the Video
func getVideoInfos(file:String) -> [String] {
    var output : [String] = []
    var error : [String] = []
    
    let task = Process()
    let stringPath = Bundle.main.path(forResource: "ffprobe", ofType: "")
    print(stringPath)
    task.launchPath = stringPath
    //task.arguments = ["-v","quiet","-print_format","json","-show_format","-show_streams",file]
    task.arguments = ["-v","quiet","-show_streams","-show_format",file]
    
    
    let outpipe = Pipe()
    task.standardOutput = outpipe
    let errpipe = Pipe()
    task.standardError = errpipe
    
    task.launch()
    
    let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
    if var string = String(data: outdata, encoding: .utf8) {
        string = string.trimmingCharacters(in: .newlines)
        output = string.components(separatedBy: "\n")
    }
    
    let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
    if var string = String(data: errdata, encoding: .utf8) {
        string = string.trimmingCharacters(in: .newlines)
        error = string.components(separatedBy: "\n")
    }
    
    //TODO: Update Swift4 use JSON Decoder
    task.waitUntilExit()
    let status = task.terminationStatus
    
    //var frameRate = Double(output.matchingStrings("\"r_frame_rate\":(\\d+)"))
    return output
}


// Count Frames in Video (slow)
// https://stackoverflow.com/questions/13645306/get-number-of-frames-in-a-video-via-avfoundation
func countFrames(for videoURL: URL) -> Int {
    let asset = AVAsset(url: videoURL)
    guard let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first else { return 0 }
    
    var assetReader: AVAssetReader?
    do {
        assetReader = try AVAssetReader(asset: asset)
    } catch {
        print(error.localizedDescription)
    }
    
    let assetReaderOutputSettings = [
        kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
    ]
    let assetReaderOutput = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: assetReaderOutputSettings)
    assetReaderOutput.alwaysCopiesSampleData = false
    assetReader?.add(assetReaderOutput)
    assetReader?.startReading()
    
    var frameCount = 0
    var sample: CMSampleBuffer? = assetReaderOutput.copyNextSampleBuffer()
    
    while (sample != nil) {
        frameCount += 1
        sample = assetReaderOutput.copyNextSampleBuffer()
    }
    
    return frameCount
}
