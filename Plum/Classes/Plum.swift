//
//  Plum.swift
//  wiencheck
//
//  Created by Adam Wienconek on 31.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AVFoundation
import AVKit
import UserNotifications
import NotificationCenter

enum PlaybackMode {
    case shuffled
    case normal
}

public class Plum: NSObject, AVAudioPlayerDelegate{
    static let shared = Plum()
    let infoCC = MPNowPlayingInfoCenter.default()
    var shouldPost = false
    var shouldPlay = true
    var lyricsPosted = false
    var initialized = false
    var session = false
    var delegated = false
    var albumLock: Bool!
    var skip: Bool!
    var repeating: Bool!
    var player: AVAudioPlayer!
    @objc var currentItem: MPMediaItem?
    var wasLoaded: Bool!
    var defQueue = [MPMediaItem]()
    var defIndex = 0
    var isUsrQueue: Bool!
    var usrQueue = [MPMediaItem]()
    var userQueueIndex: Int!
    var usrIndex: Int!
    var usrCount = 0
    var usrStartIndex = 0
    var usrEndIndex: Int {
        get{
            return usrStartIndex + usrCount
        }
    }
    var isShuffle: Bool!
    var isRepeat: Bool!
    var shufQueue = [MPMediaItem]()
    var shufIndex: Int!
    var defIsAnyAfter: Bool!{
        if(defIndex + 1 == defQueue.count){
            return false
        }else{
            return true
        }
    }
    var defIsAnyBefore: Bool!{
        if(defIndex == 0){
            return false
        }else{
            return true
        }
    }
    var usrIsAnyAfter: Bool!{
        if(usrIndex + 1 == usrQueue.count){
            return false
        }else{
            return true
        }
    }
    var usrIsAnyBefore: Bool!{
        if(usrIndex == 0){
            return false
        }else{
            return true
        }
    }
    var shufIsAnyAfter: Bool!{
        if(shufIndex + 1 == shufQueue.count){
            return false
        }else{
            return true
        }
    }
    var shufIsAnyBefore: Bool!{
        if(shufIndex == 0){
            return false
        }else{
            return true
        }
    }
    var isAnyAfter: Bool!{
        if(defIsAnyAfter && usrIsAnyAfter && shufIsAnyAfter){
            return true
        }else{
            return false
        }
    }
    var isAnyBefore: Bool!{
        if(defIsAnyBefore && usrIsAnyBefore && shufIsAnyBefore){
            return true
        }else{
            return false
        }
    }
    static let previousTrackNotification = Notification.Name("previousTrackNotification")
    static let nextTrackNotification = Notification.Name("nextTrackNotification")
    static let playBackStateChanged = Notification.Name("playBackStateChanged")
    var shouldResumeAfterInterruption = false
    var timeObserverToken: Any?
    var timer: Timer!
    
    enum AVItemLoadedStatus {
        case success
        case failure
    }
    enum playbackState{
        case initial, playing, paused, interrupted
    }
    @objc dynamic var percentProgress: Float = 0
    @objc dynamic var playbackPosition: Float = 0
    @objc dynamic var duration: Float = 0
    var elMin: String!
    var elSec: String!
    var remMin: String!
    var remSec: String!
    var observed = false
    
    var state: Plum.playbackState = .initial

    private override init(){
        super.init()
        initPlayer()
        wasLoaded = false
        defIndex = 0
        isUsrQueue = false
        usrIndex = 0
        isShuffle = false
        shufIndex = 0
        isRepeat = false
        NotificationCenter.default.addObserver(self, selector: #selector(Plum.handleAudioSessionInterruption(notification:)), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        if observed{
            player.addObserver(self, forKeyPath: #keyPath(AVAudioPlayer.data), options: [.new, .initial], context: nil)
            player.addObserver(self, forKeyPath: #keyPath(AVAudioPlayer.rate), options: [.new], context: nil)
            observed = true
        }
        addTodayObservers()
        let widget = NCWidgetController.widgetController()
        widget.setHasContent(true, forWidgetWithBundleIdentifier: "com.wiencheck.plum.upnext")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        UIApplication.shared.endReceivingRemoteControlEvents()
        timer.invalidate()
        removeTodayObservers()
    }
    
    func initSession(){
        NotificationCenter.default.addObserver(forName: Notification.Name.AVAudioSessionInterruption, object: nil, queue: nil, using: audioSessionInterrupted(_:))
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            let _ = try AVAudioSession.sharedInstance().setActive(true)
        }catch let error{
            print("Blad przy initSession: \(error)")
        }
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count != 0{
            for description in currentRoute.outputs{
                if description.portType == AVAudioSessionPortHeadphones{
                    print("Headphone plugged in")
                }else{
                    print("Headphone pulled out")
                }
            }
        }else{
            print("requires connection to device")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(Plum.audioRouteChangeListener(notification:)), name: .AVAudioSessionRouteChange, object: nil)
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    func playFromDefQueue(index: Int, new: Bool){
        defIndex = index
        if new{
            let item = defQueue[index]
            if(loadWithMediaItem(item: item) != AVItemLoadedStatus.success){
                playFromDefQueue(index: index+1, new: true)
            }
        }
    }
    
    func playFromUsrQueue(index: Int){
        usrIndex = index
        let item = usrQueue[index]
        if(loadWithMediaItem(item: item) != AVItemLoadedStatus.success){
            playFromUsrQueue(index: index+1)
        }
    }
    
    func playFromShufQueue(index: Int, new: Bool){
        shufIndex = index
        if new{
            let item = shufQueue[index]
            if(loadWithMediaItem(item: item) != AVItemLoadedStatus.success){
                playFromShufQueue(index: index+1, new: true)
            }
        }
    }
    
    func createDefQueue(items: [MPMediaItem]){
        clearQueue()
        defQueue.removeAll()
        for i in 0 ..< items.count{
            items[i].index = i
            defQueue.append(items[i])
        }
        postQueueChanged()
    }
    
    func createShufQueue(items: [MPMediaItem]){
        clearQueue()
        defQueue.removeAll()
        for i in 0 ..< items.count{
            items[i].index = i
            defQueue.append(items[i])
        }
        shuffleCurrent()
        postQueueChanged()
    }
    
    func addNext(item: MPMediaItem){
        if(!isUsrQueue){
            isUsrQueue = true
            usrQueue.append(currentItem!)
            usrQueue.append(item)
        }else{
            usrQueue.insert(item, at: usrIndex + 1)
        }
        writeQueue()
        postQueueChanged()
    }
    
    func addNextB(item: MPMediaItem){
        isUsrQueue = true
        if isShuffle {
            shufQueue.insert(item, at: shufIndex + 1)
        }else{
            defQueue.insert(item, at: defIndex + 1)
        }
        usrCount += 1
        writeQueue()
        postQueueChanged()
    }
    
    func addLast(item: MPMediaItem){
        if(!isUsrQueue){
            isUsrQueue = true
            usrQueue.append(currentItem!)
            usrQueue.append(item)
        }else{
            usrQueue.append(item)
        }
        writeQueue()
        postQueueChanged()
    }
    
    func addLastB(item: MPMediaItem){
        if isShuffle {
            shufQueue.append(item)
        }else{
            defQueue.append(item)
        }
        isUsrQueue = true
        writeQueue()
        postQueueChanged()
    }
    
    func next(){
        timer.invalidate()
        if(!isUsrQueue){
            if(!isShuffle){
                if(defIsAnyAfter){
                    playFromDefQueue(index: defIndex + 1, new: true)
                }else{
                    playFromDefQueue(index: 0, new: true)
                    shouldPlay = false
                }
            }else{
                if(shufIsAnyAfter){
                    playFromShufQueue(index: shufIndex + 1, new: true)
                }else{
                    playFromShufQueue(index: 0, new: true)
                    shouldPlay = false
                }
            }
        }else{
            if(usrIsAnyAfter){
                playFromUsrQueue(index: usrIndex + 1)
            }else{
                    if(!isShuffle){
                        if(defIsAnyAfter){
                            playFromDefQueue(index: defIndex + 1, new: true)
                        }else{
                            playFromDefQueue(index: 0, new: true)
                            shouldPlay = false
                        }
                    }else{
                        if(shufIsAnyAfter){
                            playFromShufQueue(index: shufIndex + 1, new: true)
                        }else{
                            playFromShufQueue(index: 0, new: true)
                            shouldPlay = false
                        }
                    }
                clearQueue()
                }
            }
        //postPlaybackStateChanged()
        //postTrackChanged()
    }
    
    func nextB() {
        timer.invalidate()
        if isShuffle {
            if shufIsAnyAfter {
                playFromShufQueue(index: shufIndex+1, new: true)
            }else{
                playFromShufQueue(index: 0, new: true)
            }
            if shufIndex > usrEndIndex {
                
            }
        }else{
            if defIsAnyAfter {
                playFromDefQueue(index: defIndex+1, new: true)
            }else{
                playFromDefQueue(index: 0, new: true)
            }
        }
    }
    
    func prev(){
        timer.invalidate()
        if(player.currentTime < 3){
            if(!isUsrQueue){
                if(!isShuffle){
                    if(defIsAnyBefore){
                        playFromDefQueue(index: defIndex - 1, new: true)
                    }else{
                        playFromDefQueue(index: defQueue.count - 1, new: true)
                    }
                }else{
                    if(shufIsAnyBefore){
                        playFromShufQueue(index: shufIndex - 1, new: true)
                    }else{
                        playFromShufQueue(index: shufQueue.count - 1, new: true)
                    }
                }
            }else{
                    if(usrIsAnyBefore){
                        playFromUsrQueue(index: usrIndex - 1)
                    }else{
                        playFromDefQueue(index: defIndex - 1, new: true)
                        clearQueue()
                    }
                }
            //postPlaybackStateChanged()
            //postTrackChanged()
        }
        else{
            player.currentTime = 0.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
        }
    }
    
    func prevB() {
        timer.invalidate()
        if player.currentTime < 3.0 {
            if isShuffle {
                if shufIsAnyBefore {
                    playFromShufQueue(index: shufIndex-1, new: true)
                }else{
                    playFromShufQueue(index: shufQueue.count-1, new: true)
                }
            }else{
                if defIsAnyBefore {
                    playFromDefQueue(index: defIndex-1, new: true)
                }else{
                    playFromDefQueue(index: defQueue.count-1, new: true)
                }
            }
        }else{
            player.currentTime = 0.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
        }
    }
    
    func play(){
        shouldPlay = true
        if !shouldResumeAfterInterruption{
            shouldResumeAfterInterruption = true
        }
        if state == .interrupted {
            state = .playing
        }
        if !session{
            initSession()
            session = true
        }
        if(currentItem != nil){
            if(!player.isPlaying){
                player.play()
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                }catch let error {
                    print(error)
                }
                player.rate = 1.0
                postPlaybackStateChanged()
            }else{
                print("player is already playing")
            }
        }
        if #available(iOS 10.0, *) {
            if shouldPost && GlobalSettings.lyrics { postLyrics() }
        }
    }
    
    func pause(){
        if state == .interrupted{
            shouldResumeAfterInterruption = false
        }
        if(player.isPlaying){
            player.pause()
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            }catch let error {
                print(error)
            }
            player.rate = 0.0
            postPlaybackStateChanged()
            state = .paused
        }else{
            print("player is currently not playing")
        }
    }
    
    func togglePlayPause(){
        if(isPlayin()){
            pause()
        }else{
            play()
        }
    }
    
    func stop(){
        player.pause()
        player.currentTime = 0.0
    }
    
    func seekTo(_ position: TimeInterval){
        player.currentTime = position
    }
    
    func clearQueue(){
        usrQueue.removeAll()
        usrIndex = 0
        isUsrQueue = false
        postQueueChanged()
    }
    
    func shuffleCurrent(){
        if(isShuffle){
            shufQueue.removeAll()
        }
        isShuffle = true
        shufIndex = 0
        shufQueue = defQueue
        if(defIndex != 0){
            (shufQueue[0], shufQueue[defIndex]) = (shufQueue[defIndex], shufQueue[0])
        }
        shufQueue.shuffle()
        postQueueChanged()
        writeQueue()
    }
    
    func shuffleCurrentB() {
        var userQueue = [MPMediaItem]()
        shufQueue.removeAll()
        shufQueue = defQueue
        if usrCount > 0 {
            for i in defIndex+1 ..< defIndex+usrCount {
                userQueue.append(defQueue[i])
            }
            for _ in defIndex+1 ..< defIndex+usrCount { shufQueue.remove(at: defIndex+1) }
        }
        /* Removing user songs from shuffle Queue because we want them to stay untouched, so we will place them in the same position after shuffling */
        if defIndex != 0 {
            (shufQueue[0], shufQueue[defIndex]) = (shufQueue[defIndex], shufQueue[0])
        }
        shufQueue.shuffle()
        shufIndex = 0
        for i in (0 ..< usrCount).reversed() {
            shufQueue.insert(userQueue[i], at: shufIndex+1)
        }
        isShuffle = true
        postQueueChanged()
        writeQueue()
    }

    func disableShuffle(){
        isShuffle = false
        shufIndex = 0
        defIndex = (currentItem?.index)!
        shufQueue.removeAll()
        writeQueue()
    }
    
    func isPlayin() -> Bool{
        if(wasLoaded){
            return player.isPlaying
        }else{
            return false
        }
    }
    
    func labelString(type: String) -> String{
        switch type {
        case "title":
            return currentItem?.title ?? "Unkown title"
        case "detail":
            return "\(currentItem?.artist ?? "Unknown artist") - \(currentItem?.albumTitle ?? "Unknown album")"
        case "out of":
            if(!isShuffle){
                if(!isUsrQueue){
                    return "\(defIndex + 1) of \(defQueue.count)"
                }else{
                    return "\(usrIndex! + 1) of \(usrQueue.count)"
                }
            }else{
                if(!isUsrQueue){
                return "\(shufIndex + 1) of \(shufQueue.count)"
            }else{
                return "\(usrIndex! + 1) of \(usrQueue.count)"
                }
            }
            
        default:
            return "Zly typ, typie"
        }
    }
    
    var currentIndex: Int {
        get {
            var index = 0
            if isShuffle { index = shufIndex }
            else { index = defIndex }
            if isUsrQueue { index += usrIndex }
            return index
        }
    }
    
    func repeatMode(_ enable: Bool) {
        isRepeat = enable
        shouldPlay = enable
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer.invalidate()
        currentItem?.setValue((currentItem?.playCount)! + 1, forKey: MPMediaItemPropertyPlayCount)
        if isRepeat {
            player.currentTime = 0.0
        }else{
            next()
        }
        if shouldPlay { play() }
    }
    
    func initPlayer(){
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "initPlum", ofType: "m4a")!)
        do{
            try player = AVAudioPlayer(contentsOf: url)
            player.delegate = self
        }catch let error{
            print("Nie udalo sie zainicjalizowac \(error)")
        }
    }
    
    func updateGeneralMetadata() {
        guard player.url != nil, let _ = player.url else {
            infoCC.nowPlayingInfo = nil
            return
        }
        infoCC.nowPlayingInfo = nil
        var rating = ""
        let item = currentItem
        for _ in 0 ..< (item?.rating)!{
            rating.append("*")
        }
        var nowPlayingInfo = infoCC.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = item?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = item?.albumArtist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = item?.albumTitle
        nowPlayingInfo[MPMediaItemPropertyArtwork] = item?.artwork
        infoCC.nowPlayingInfo = nowPlayingInfo
    }
    
    @objc func updatePlaybackRateData(){
        guard currentItem?.assetURL != nil else {
            duration = 0
            infoCC.nowPlayingInfo = nil
            return
        }
        var nowPlayingInfo = infoCC.nowPlayingInfo ?? [String: Any]()
        duration = Float(player.duration)
        let item = currentItem
        if GlobalSettings.rating{
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = currentItem?.labelFromRating()
        }else{
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = ""
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPMediaItemPropertyTitle] = item?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = item?.albumArtist
        nowPlayingInfo[MPMediaItemPropertyArtwork] = item?.artwork
        infoCC.nowPlayingInfo = nowPlayingInfo
        if player.rate == 0.0{
         state = .paused
         }else{
         state = .playing
         }
    }
    
    func loadWithMediaItem(item: MPMediaItem) -> AVItemLoadedStatus{
        if(item.assetURL != nil){
            do{
                print("Trying to load \((item.title)!)...")
                player = try AVAudioPlayer(contentsOf: item.assetURL!)
                player.delegate = self
                player.prepareToPlay()
                currentItem = item
                wasLoaded = true
                initialized = true
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(Plum.updatePlaybackRateData), userInfo: nil, repeats: true)
                timer.fire()
                writeQueue()
                postTrackChanged()
                postPlaybackStateChanged()
                //updateGeneralMetadata()
            }catch let error{
                print("Failed to initialize with URL\n\(error)")
                return AVItemLoadedStatus.failure
            }
            return AVItemLoadedStatus.success
        }else{
            print("iCloud item, please download it in music app and come back")
            return AVItemLoadedStatus.failure
        }
    }
    
    func rateItem(rating: Int){
        currentItem?.setValue(rating, forKey: MPMediaItemPropertyRating)
    }
    
    func calculateFromTimeInterval(_ interval: TimeInterval) ->(minute:String, second:String){
        let minute_ = abs(Int((interval/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(interval.truncatingRemainder(dividingBy: 60)))
        
        let minute = minute_ > 9 ? "\(minute_)" : "\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    
    func landInAlbum(_ item: MPMediaItem, new: Bool){
        var index: Int!
        let album = musicQuery.shared.albumBy(item: item).items
        for i in 0 ..< album.count{
            album[i].index = i
            if album[i].persistentID == item.persistentID{
                index = i
            }
        }
        defIndex = index
        createDefQueue(items: album)
        if isShuffle{
            shuffleCurrent()
            self.playFromShufQueue(index: 0, new: new)
        }else{
            self.playFromDefQueue(index: index, new: new)
        }
        writeQueue()
    }
    
    func landInArtist(_ item: MPMediaItem, new: Bool){
        var index = 0
        let artist = musicQuery.shared.songsByArtistID(artist: item.albumArtistPersistentID)
        for i in 0 ..< artist.count{
            artist[i].index = i
            if artist[i].persistentID == item.persistentID{
                index = i
                break
            }
        }
        defIndex = index
        self.createDefQueue(items: artist)
        if isShuffle{
            shuffleCurrent()
            self.playFromShufQueue(index: 0, new: new)
        }else{
            self.playFromDefQueue(index: index, new: new)
        }
        writeQueue()
    }
    
    func landInPlaylist(list: Playlist, shuffle: Bool) {
        var index = 0
        var new = true
        for i in 0 ..< list.songsIn {
            list.items[i].index = i
            if list.items[i].persistentID == currentItem?.persistentID {
                index = i
                new = false
                //break
            }
        }
        defIndex = index
        createDefQueue(items: list.items)
        if shuffle{
            shuffleCurrent()
            playFromShufQueue(index: 0, new: new)
        }else{
            playFromDefQueue(index: index, new: new)
        }
        writeQueue()
    }
    
    func landInSongs(_ item: MPMediaItem, new: Bool) {
        var index: Int!
        let songs = musicQuery.shared.allSongs()
        for i in 0 ..< (songs.count) {
            songs[i].index = i
            if songs[i].persistentID == item.persistentID {
                index = i
                break
            }
        }
        defIndex = index
        createDefQueue(items: songs)
        if isShuffle{
            shuffleCurrent()
            self.playFromShufQueue(index: 0, new: new)
        }else{
            self.playFromDefQueue(index: index, new: new)
        }
        writeQueue()
    }
    
    @available(iOS 10.0, *) func registerforDeviceLockNotification() {
        //Screen lock notifications
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),     //center
            Unmanaged.passUnretained(self).toOpaque(),     // observer
            displayStatusChangedCallback,     // callback
            "com.apple.springboard.lockcomplete" as CFString,     // event name
            nil,     // object
            .deliverImmediately)
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),     //center
            Unmanaged.passUnretained(self).toOpaque(),     // observer
            displayStatusChangedCallback,     // callback
            "com.apple.springboard.lockstate" as CFString,    // event name
            nil,     // object
            .deliverImmediately)
    }
    
    @available(iOS 10.0, *) func unRegisterLockNotification() {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetLocalCenter(),
                                           Unmanaged.passUnretained(self).toOpaque(),
                                           nil,
                                           nil)
    }
    
    private let displayStatusChangedCallback: CFNotificationCallback = { _, cfObserver, cfName, _, _ in
        guard let lockState = cfName?.rawValue as String? else {
            return
        }
        
        let catcher = Unmanaged<Plum>.fromOpaque(UnsafeRawPointer(OpaquePointer(cfObserver)!)).takeUnretainedValue()
        if #available(iOS 10.0, *) {
            catcher.displayStatusChanged(lockState)
        }
    }
    
    @available(iOS 10.0, *) private func displayStatusChanged(_ lockState: String) {
        if (lockState == "com.apple.springboard.lockcomplete") {
            if GlobalSettings.lyrics {
                shouldPost = true
                postLyrics()
            }
        }else{
            //shouldPost = false
        }
    }
    
    func postPlaybackStateChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .playbackChanged, object: nil)
        }
    }
    
    func postTrackChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .trackChanged, object: nil)
        }
    }
    
    func postQueueChanged() {
        NotificationCenter.default.post(name: .queueChanged, object: nil)
    }
    
    @available(iOS 10.0, *) func postLyrics() {
        if currentItem != nil && shouldPost && player.isPlaying {
            let content = UNMutableNotificationContent()
            let ass = AVAsset(url: (currentItem?.assetURL)!)
            if let lyr = ass.lyrics {
                if !lyr.isEmpty {
                    content.title = currentItem?.title ?? "Unknown title"
                    content.subtitle = currentItem?.artist ?? "Unknown artist"
                    content.body = "\n" + lyr
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                    let request = UNNotificationRequest(identifier: "lyricsOnLS", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error != nil {
                            print("Blad przy pokazywaniu tekstu")
                        }else{
                            self.lyricsPosted = true
                        }
                    })
                }else{
                    removeLyrics()
                }
            }else{
                removeLyrics()
            }
        }
    }
    
    @available(iOS 10.0, *) func removeLyrics() {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["lyricsOnLS"])
        lyricsPosted = false
    }
    
    func getCurrentQueue() -> [MPMediaItem] {
        var queue = [MPMediaItem]()
        if isShuffle {
            queue.append(contentsOf: shufQueue)
        }else{
            queue.append(contentsOf: defQueue)
        }
        if isUsrQueue {
            for i in 1 ..< usrQueue.count {
                queue.insert(usrQueue[i], at: defIndex+i)
            }
        }
        return queue
    }
    
    func writeQueue() {
        var queue = [MPMediaItem]()
        var start = 0
        var meta = 0
        if isUsrQueue {
            start = usrIndex
            if usrIndex > usrQueue.count - 6 {
                meta = usrQueue.count
                for i in start ..< meta {
                    queue.append(usrQueue[i])
                }
            }else{
                meta = usrIndex + 6
                for i in start ..< meta {
                    queue.append(usrQueue[i])
                }
            }
            if isShuffle && shufIsAnyAfter {
                start = shufIndex + 1
                if shufIndex > shufQueue.count - 6 {
                    meta = shufQueue.count
                    for i in start ..< meta {
                        queue.append(shufQueue[i])
                    }
                }else{
                    meta = shufIndex + 6
                    for i in start ..< meta {
                        queue.append(shufQueue[i])
                    }
                }
            }else if !isShuffle && defIsAnyAfter {
                start = defIndex + 1
                if defIndex > defQueue.count - 6 {
                    meta = defQueue.count
                    for i in start ..< meta {
                        queue.append(defQueue[i])
                    }
                }else{
                    meta = defIndex + 6
                    for i in start ..< meta {
                        queue.append(defQueue[i])
                    }
                }
            }
        }else if isShuffle && shufIsAnyAfter{
            start = shufIndex
            if shufIndex > shufQueue.count - 6 {
                meta = shufQueue.count
                for i in start ..< meta {
                    queue.append(shufQueue[i])
                }
            }else{
                meta = shufIndex + 6
                for i in start ..< meta {
                    queue.append(shufQueue[i])
                }
            }
        }else if !isShuffle && defIsAnyAfter{
            start = defIndex
            if defIndex > defQueue.count - 6 {
                meta = defQueue.count
                for i in start ..< meta {
                    queue.append(defQueue[i])
                }
            }else{
                meta = defIndex + 6
                for i in start ..< meta {
                    queue.append(defQueue[i])
                }
            }
        }
        if queue.count < 7 {
            for _ in queue.count ..< 7 {
                queue.append(MPMediaItem())
            }
        }
        if let c = currentItem {
            queue[0] = c
        }
        if let defaults = UserDefaults.init(suiteName: "group.adw.Plum") {
            var arr = [[String]]()
            for i in 0 ..< 6 {
                if queue[i].assetURL != nil {
                    arr.append([queue[i].title ?? "Unknown title", queue[i].albumArtist ?? "Unknown artist"])
                    defaults.set(arr[i], forKey: "queue\(i)")
                }else{
                    defaults.set("", forKey: "queue\(i)")
                }
            }
            defaults.set(queue[0].rating, forKey: "currentRating")
            defaults.set(queue[0].albumTitle ?? "Unknown album", forKey: "currentAlbum")
            if let yearNumber: NSNumber = queue[0].value(forProperty: "year") as? NSNumber {
                var year = ""
                if (yearNumber.isKind(of: NSNumber.self)) {
                    let _year = yearNumber.intValue
                    if (_year != 0) {
                        year = "\(_year)"
                    }
                }
                defaults.set(year, forKey: "currentYear")
            }
//            if let d = defaults.value(forKey: "widgetActive") as? Bool {
//                if !d {
//                    defaults.set(true, forKey: "widgetActive")
//                    NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "com.wiencheck.plum.upnext")
//                }
//            }else{
//                defaults.set(true, forKey: "widgetActive")
//                NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "com.wiencheck.plum.upnext")
//            }
            defaults.synchronize()
        }
    }
    
    func addTodayObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTodayRatingNotification(_:)), name: Notification.Name(rawValue: "ratingToday"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTodayQueueNotification(_:)), name: Notification.Name(rawValue: "queueToday"), object: nil)
    }
    
    @objc func handleTodayRatingNotification(_ notification: Notification) {
        if let rat = notification.userInfo?["rating"] as? Int {
            rateItem(rating: rat)
        }
    }
    
    func removeTodayObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "ratingToday"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "queueToday"), object: nil)
    }
    
    @objc func handleTodayQueueNotification(_ notification: Notification) {
        if let skip = notification.userInfo?["skip"] as? Int {
            print("Skipping \(skip) items")
        }
        print("skipperino")
        pause()
    }
}

extension Plum {    //Interruptions
    
    func audioSessionInterrupted(_ notification: Notification){
        print("Interruption received: \(notification)")
    }
    
    @objc dynamic private func audioRouteChangeListener(notification:NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            print("headphone plugged in")
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            print("Route changed")
            pause()
        case AVAudioSessionRouteChangeReason.routeConfigurationChange.rawValue:
            print("Route configuration Change")
        case AVAudioSessionRouteChangeReason.categoryChange.rawValue:
            print("Category change")
        case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory.rawValue:
            print("No suitable Route For Category")
        default:
            print("Default reason")
        }
    }
    
    @objc func handleAudioSessionInterruption(notification: Notification){
        guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt, let interruptionType = AVAudioSessionInterruptionType(rawValue: typeInt) else {return}
        
        switch interruptionType{
        case .began:
            state = .interrupted
            pause()
        case .ended:
            do{
                try AVAudioSession.sharedInstance().setActive(true)
//                if (shouldResumeAfterInterruption){
//                    play()
//                }
                guard let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}
                let interruptionOptions = AVAudioSessionInterruptionOptions(rawValue: optionsInt)
                if (interruptionOptions.contains(.shouldResume)){
                    print("Should resume")
                    play()
                }else{
                    print("Will not resume")
                }
            }
            catch{
                print("Blad przy powrocie z przerwania")
            }
        }
    }
    
}
