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
    var cutTimes = [Double]()
    var videoTime : Double = 0.0
    var totalFrames : Int = 0
    var frameRate : Double = 0.0
    var version = "0.1-alpha"
    var CutlistAsString : String?
    var videoFileName : String?
    var frameOffset : Int = 1
    var fileSize : Int = 0
    //let playerLayer : AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tell the table view that its data source and delegate will be the view controller.
        tableView.delegate = self
        tableView.dataSource = self
        
        // hanlde double click
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func loadCutlistCallback(_ sender: NSButton) {
        let file = loadFile()
        let fileURL = "file:///" + file
        let url = URL(string:fileURL)
        do{
            let fileStr = try String(contentsOf: url!, encoding: .utf8)
            print(fileStr)
            let startTimes = fileStr.matchingStrings(regex: "Start=(\\d+\\.?\\d+)")
            let durations = fileStr.matchingStrings(regex: "Duration=(\\d+\\.?\\d+)")
            if (startTimes.count == durations.count){
                for i in 0..<startTimes.count {
                    cutTimes.append(Double(startTimes[i])!)
                    cutTimes.append(Double(startTimes[i])!+Double(durations[i])!)
                    tableView.reloadData()
                }
            }
            print(startTimes)
        }
        catch{
            print("Something went wrong")
        }
    }
    @IBAction func saveCutlistCallback(_ sender: NSButton) {
        let cutListFile = "file:///" + videoFileName! + ".cutlist"
        print("FILE:")
        print(cutListFile)
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
        // Save in User DOcuments directory:
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
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var cutNumberView: NSTableColumn!
    @IBOutlet weak var table: NSScrollView!
    @IBOutlet weak var playerView: AVPlayerView!
    
    //Buton callbacks
    @IBAction func buttonCallback(_ sender: NSButton) {
        
        //https://developer.apple.com/documentation/avfoundation/avplayeritem/1387968-stepbycount?language=objc
        // Seems to need an AVPlayer Item Object
        print(playerView.player?.currentItem?.duration.seconds)
        print(videoTime)
        print(playerView.player?.currentItem?.status.rawValue)
        print(playerView.player?.currentItem?.currentTime().seconds)
        cutTimes.append((playerView.player?.currentItem!.currentTime().seconds)!)
        tableView.reloadData()
    }
    
    @IBAction func loadFileCallback(_ sender: NSButton) {
        let file = loadFile()
        videoFileName = file
        let fileURL = "file:///" + file
        let url = URL(string:fileURL)
        // Create a new AVPlayer and associate it with the player view
        let player = AVPlayer(url: url!)
        playerView.player = player
        playerView.player?.rate = 1.0
        playerView.player?.play()
        
        print("Status:")
        // TODO: Implement key-value observation and check for AVplayer status ready:
        // https://stackoverflow.com/questions/23874574/avplayer-item-get-a-nan-duration
        /*while (true){
            if(playerView.player?.currentItem?.status.rawValue == 1){
                print("DONE")
                break
            sleep(1)
            // do nothing
            }
        }*/
        print(playerView.player?.currentItem?.status.rawValue)
        
        //FFPROBE
        let infos = getVideoInfos(file:file)
        var matches = infos.joined().matchingStrings(regex: "r_frame_rate=(\\d+\\/?\\d+)")
        let isIndexValid = matches.indices.contains(1)
        if(isIndexValid){
            let matchesNew = matches[1].components(separatedBy: "/")
            if (matchesNew.count == 2){
                frameRate = Double(matchesNew[0])!/Double(matchesNew[1])!
            }
        }
        fileSize = Int(infos.joined().matchingStrings(regex: "size=(\\d+)")[1])!
        
        // Duration
        //print(playerView.player?.currentItem?.duration)
        print(playerView.player?.currentItem?.duration.seconds)
        print(player.currentItem?.duration.seconds)
        print(playerView.player?.currentItem?.duration.timescale)
        videoTime = (playerView.player?.currentItem?.duration.seconds)!
        
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
    
    func tableViewDoubleClick(_ sender:AnyObject) {
        
        if (tableView.selectedRow >= 0){
            let item = cutTimes[tableView.selectedRow]
            print(item)
            playerView.player?.seek(to:CMTimeMakeWithSeconds(item,1000))
        }
        else {
            return
        }
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
            text = String(cutTimes[row])
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

func loadFile() -> String {
    
    // OPEN DIALOG

     let dialog = NSOpenPanel();
     
     dialog.title                   = "Choose a .mp4 file";
     dialog.showsResizeIndicator    = true;
     dialog.showsHiddenFiles        = false;
     dialog.canChooseDirectories    = true;
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

func matches(for regex: String, in text: String) -> [String] {
    // https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    // TODO Update to Swift 4
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

extension String {
    func matchingStrings(regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        
        var collectMatches: Array<String> = []
        for match in results {
            // range at index 0: full match
            // range at index 1: first capture group
            let substring = nsString.substring(with: match.rangeAt(1))
            collectMatches.append(substring)
        }
        return collectMatches
    }
}


//   let asset = AVAsset(URL: NSBundle.mainBundle().URLForResource("SampleVideo", withExtension: "mp4")!)
//let playerItem = AVPlayerItem(asset: asset)
//let player = AVPlayer(playerItem: playerItem)
//let playerLayer = AVPlayerLayer(player: player)
//playerLayer.frame = self.view.bounds
//self.view.layer.addSublayer(playerLayer)
//player.play()
//player.rate = 0.5

//https://www.hackingwithswift.com/example-code/media/how-to-play-videos-using-avplayerviewcontroller
// Seems not available in Xcode 8
//playerView.player?.currentItem?.duration.seconds
//let vc = AVPlayerViewController()
//vc.player = player
//vc.present(animated: true) {
//    vc.player?.play()
//}


//guard let path = Bundle.main.path(forResource: "\(name)", ofType:"\(type)") else {
//    debugPrint("video not found")
//    return
//}

// https://stackoverflow.com/questions/14272996/play-video-frame-by-frame

//https://stackoverflow.com/questions/25348877/how-to-play-a-local-video-with-swift

//https://stackoverflow.com/questions/24608812/playing-fullscreen-video-on-os-x-with-avplayer
