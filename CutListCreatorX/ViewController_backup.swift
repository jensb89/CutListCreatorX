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
    let items = [1,2,3,4,5,6]
    var cutTimes = [0.0]
    //let playerLayer : AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tell the table view that its data source and delegate will be the view controller.
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        
        // Jens
        guard let url = URL(string: "https://devimages-cdn.apple.com/samplecode/avfoundationMedia/AVFoundationQueuePlayer_HLS2/master.m3u8") else {
            return
        }
        
        // NOTE: LOcal m3u8 don't play: https://stackoverflow.com/questions/41112283/avplayer-not-playing-m3u8-from-local-file
        
        guard let url1 = URL(string: "https://users.wfu.edu/yipcw/atg/vid/katamari-star8-10s-h264.mov") else {
            return
        }
        // works
        
        let url2 = URL(fileURLWithPath:"file:///Users/jens/Websites/pyOTR/test.mov") //doesn't work
        print("url",url)
        
        let url3 = NSURL(fileURLWithPath: "file:///Users/jens/Websites/pyOTR/test.mov") //doesn't work
        
        let url4 = URL(string: "file:///Users/jens/Websites/pyOTR/test.mov") //works
        let url5 = URL(string: "/Users/jens/Websites/pyOTR/test.mov") // doesn't work
        
        var url6 = NSURL(fileURLWithPath: "/Users/jens/Websites/CutListCreatorX/CutListCreatorX/CutListCreatorX/test2.mov") //works (internal app file, left side in Xcode)
        
        let url7 = URL(string: "file:///Users/jens/Websites/pyOTR/tbbt_test.mp4")
        
        //let urlpath     = Bundle.main.path(forResource: "outTest", ofType: "mp4")
        //let fileURL         = NSURL.fileURL(withPath: urlpath!)
        
        print("url2",url2)
        print("url3",url3)
        print("url4",url4!)
        print("url5",url5!)
        //let frames = countFrames(for: url7!) //82277 (takes quite long)  (last time stamp: 2745.3099999999999s*29.97frames/s = 82276.94 \approx 82277  (+- 1frame = 0.03s missing?)
        //print("Frame Number:",frames)
        // Create a new AVPlayer and associate it with the player view
        let player = AVPlayer(url: url7!)
        playerView.player = player
        //let playerLayer = AVPlayerLayer(player: playerView.player)
        //playerView.player?.rate
        
        //playerItem?.loadedTimeRanges()
        playerItem?.step(byCount: 200)
        //
        
        
        //https://www.hackingwithswift.com/example-code/media/how-to-play-videos-using-avplayerviewcontroller
        // Seems not available in Xcode 8
        //playerView.player?.currentItem?.duration.seconds
        //let vc = AVPlayerViewController()
        //vc.player = player
        //vc.present(animated: true) {
        //    vc.player?.play()
        //}
        
        
        
        // OPEN DIALOG
        /*
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .mp4 file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["mp4"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                print(path)
                //filename_field.stringValue = path
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
        */
        
        
        
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var textFieldTest: NSTextField!
    @IBOutlet weak var cutNumberView: NSTableColumn!
    @IBOutlet weak var table: NSScrollView!
    @IBOutlet weak var playerView: AVPlayerView!
    @IBAction func buttonCallback(_ sender: NSButton) {
        // https://stackoverflow.com/questions/14272996/play-video-frame-by-frame
        //AVPlayer *mPlayer = [AVPlayer playerWithURL:url];
        //[mPlayer.currentItem stepByCount:1];
        
        //https://developer.apple.com/documentation/avfoundation/avplayeritem/1387968-stepbycount?language=objc
        // Seems to need an AVPlayer Item Object
        //playerView.player.stepByCount+=1;
        print("Hello World")
        // CURRENT ITEM GIVES AVPlayer Item Object
        playerView.player?.rate = 1.0
        print(playerView.player?.currentItem?.duration)
        print(playerView.player?.currentItem?.duration.seconds)
        playerView.player?.currentItem?.step(byCount: 1)
        print(playerView.player?.currentItem?.asset.commonMetadata.description)
        print(playerView.player?.currentItem?.canPlaySlowForward)
        //https://stackoverflow.com/questions/36378642/avplayeritems-canplayslowforward-property-never-called
        print(playerView.player?.currentItem?.currentTime().seconds)
        //print(playerLayer?.frame)
        //table.add
        //cutNumberView.insertValue(<#T##value: Any##Any#>, inPropertyWithKey: <#T##String#>)
        textFieldTest.stringValue = textFieldTest.stringValue  + "adasd"
        //cutNumberView.insertValue("2", inPropertyWithKey: "Cut Number View") //doesn't work
        //cutNumberView.insertValue(value:2, at: 1, inPropertyWithKey: "")
        cutTimes.append((playerView.player?.currentItem!.currentTime().seconds)!)
        tableView.reloadData()
    }

}


extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cutTimes.count
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
        
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .long
        //dateFormatter.timeStyle = .long
        
        // 1
        //guard let item = items[row] else {
        //    return nil
        //}
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            //image = item.icon
            text = String(row)
            print(text)
            cellIdentifier = CellIdentifiers.CutCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(cutTimes[row])
            cellIdentifier = CellIdentifiers.TimeCell
        }
            
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            //cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }
    
    }

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

//   let asset = AVAsset(URL: NSBundle.mainBundle().URLForResource("SampleVideo", withExtension: "mp4")!)
//let playerItem = AVPlayerItem(asset: asset)
//let player = AVPlayer(playerItem: playerItem)
//let playerLayer = AVPlayerLayer(player: player)
//playerLayer.frame = self.view.bounds
//self.view.layer.addSublayer(playerLayer)
//player.play()
//player.rate = 0.5


//guard let path = Bundle.main.path(forResource: "\(name)", ofType:"\(type)") else {
//    debugPrint("video not found")
//    return
//}


//https://stackoverflow.com/questions/25348877/how-to-play-a-local-video-with-swift

//https://stackoverflow.com/questions/24608812/playing-fullscreen-video-on-os-x-with-avplayer
