//
//  ViewController.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 07.11.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

class ViewController: NSViewController {
    
    var playerItem : AVPlayerItem?
    var videoTime : Double = 0.0
    var totalFrames : Int = 0
    var frameRate : Double = 0.0
    var version = "0.1-alpha"
    var videoFileName : String?
    var frameOffset : Int = 1
    var fileSize : Int = 0
    var cutList : Cutlist = Cutlist()

    // a few constants that identify what element names we're looking for inside the XML
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tell the table view that its data source and delegate will be the view controller.
        tableView.delegate = self
        tableView.dataSource = self
        
        // hanlde double click
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
    }

    @IBAction func loadCutlistCallback(_ sender: NSButton) {
        let file = loadFile()
        let fileURL = "file:///" + file
        let url = URL(string:fileURL)
        cutList.loadCutlist(url:url!)
        tableView.reloadData()
        }
    
    @IBAction func saveCutlistCallback(_ sender: NSButton) {
        cutList.saveCutList(videoFileName: videoFileName!, version: version, frameRate: frameRate, fileSize: fileSize, frameOffset: frameOffset)
    }
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var cutNumberView: NSTableColumn!
    @IBOutlet weak var table: NSScrollView!
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var graphViewCtrl: GraphView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    
    @IBAction func loadCutlistAt(_ sender: NSButton) {
        let sniplist = Sniplist()
        let fileURL = URL(string:videoFileName!)
        sniplist.loadResults(fileName:(fileURL?.lastPathComponent)!)
    }
    
    
    //Buton callbacks
    @IBAction func buttonCallback(_ sender: NSButton) {
        
        //https://developer.apple.com/documentation/avfoundation/avplayeritem/1387968-stepbycount?language=objc
        // Seems to need an AVPlayer Item Object
        print(playerView.player?.currentItem?.duration.seconds)
        print(videoTime)
        print(playerView.player?.currentItem?.status.rawValue)
        print(playerView.player?.currentItem?.currentTime().seconds)
        print("StatusClb:")
        print(playerView.player?.currentItem?.status.rawValue)
        cutList.cutTimes.append((playerView.player?.currentItem!.currentTime().seconds)!)
        // Update tableView
        tableView.reloadData()
        // Update Cut Graphic
        graphViewCtrl.numberOfCuts = cutList.cutTimes.count
        graphViewCtrl.cuts = cutList.cutTimes
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if playerView.player?.currentItem?.status == .readyToPlay {
                print("AVPlayer is ready!")
                print(playerView.player?.currentItem?.duration)
                print(CMTimeGetSeconds((playerView.player?.currentItem?.duration)!))
                // Set the video duration and update the same info in the graphicViewController
                videoTime = (playerView.player?.currentItem?.duration.seconds)!
                graphViewCtrl.duration = videoTime
            }
        }
    }
    
    @IBAction func testClback(_ sender: AnyObject) {
        //let sniplist = Sniplist()
        //sniplist.uploadCutlist()
    }
    
    @IBAction func loadFileCallback(_ sender: NSButton) {
        let file = loadFile()
        if file.isEmpty{
            return
        }
        videoFileName = file
        let fileURL = "file:///" + file
        let url = URL(string:fileURL)
        
        // Create a new AVPlayer and associate it with the player view
        let player = AVPlayer(url: url!)
        
        // Add Periodic Time Observer to update the progress indicator
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            if self.videoTime != 0.0 || !self.videoTime.isNaN {
                self.progressBar.doubleValue = ((self.playerView.player?.currentItem!.currentTime().seconds)!/self.videoTime)*100
            }
        }
        
        //Bind the player to the playerView
        playerView.player = player
        // Add key value observation for the player status. The player is loaded asynchronous and not all values are availabe directly at the beginning (e.g. the video duration)
        // More info: https://stackoverflow.com/questions/23874574/avplayer-item-get-a-nan-duration
        // It seems key-value-binding for the status property only works for the playerItem and not the player object
        playerView.player?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        // Set the rate and start playing
        playerView.player?.rate = 1.0
        playerView.player?.play()
        
        
        //FFPROBE
        let infos = getVideoInfos(file:file)
        print(infos)
        var matches = infos.joined().matchingStrings(regex: "r_frame_rate=(\\d+\\/?\\d+)")
        let isIndexValid = matches.indices.contains(0)
        if(isIndexValid){
            let matchesNew = matches[0].components(separatedBy: "/")
            if (matchesNew.count == 2){
                frameRate = Double(matchesNew[0])!/Double(matchesNew[1])!
                print("FrameRate (FFPROBE):" + String(frameRate))
            }
        }
        fileSize = Int(infos.joined().matchingStrings(regex: "size=(\\d+)").last!)!

        // Extras
        print(playerView.player?.currentItem?.canPlaySlowForward)
        //https://stackoverflow.com/questions/36378642/avplayeritems-canplayslowforward-property-never-called
        
        // Total Frames
        //totalFrames = countFrames(for: url!) //82277 (takes quite long)  (last time stamp: 2745.3099999999999s*29.97frames/s = 82276.94 \approx 82277  (+-1frame = 0.03s missing?)
    }
    
    @IBAction func p20Callback(_ sender: NSButton) {
        playerView.player?.currentItem?.step(byCount: 20)
    }
    @IBAction func p1Callback(_ sender: NSButton) {
        playerView.player?.currentItem?.step(byCount: 1)
    }
    @IBAction func m1Callback(_ sender: NSButton) {
        playerView.player?.currentItem?.step(byCount: -1)
    }
    @IBAction func m20Callback(_ sender: NSButton) {
        playerView.player?.currentItem?.step(byCount: -20)
    }
    
    @IBAction func RemoveEntryCallback(_ sender: NSButton) {
        if cutList.cutTimes.count > 0{
            cutList.cutTimes.removeLast()
            tableView.reloadData()
            graphViewCtrl.numberOfCuts = cutList.cutTimes.count
            graphViewCtrl.cuts = cutList.cutTimes
        }
    }
    
    func tableViewDoubleClick(_ sender:AnyObject) {
        
        if (tableView.selectedRow >= 0){
            let item = cutList.cutTimes[tableView.selectedRow]
            print(item)
            playerView.player?.seek(to:CMTimeMakeWithSeconds(item,1000))
        }
        else {
            return
        }
    }
}
