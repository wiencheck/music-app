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

class Plum: NSObject, AVAudioPlayerDelegate{
    static let shared = Plum()
    let infoCC = MPNowPlayingInfoCenter.default()
    var initialized = false
    var session = false
    var delegated = false
    var albumLock: Bool!
    var skip: Bool!
    var repeating: Bool!
    var player: AVAudioPlayer!
    var player1: AVAudioPlayer!
    var player2: AVAudioPlayer!
    var playerFlag: UInt8!
    @objc var currentItem: MPMediaItem?
    var previousItem: MPMediaItem?
    var nextItem: MPMediaItem?
    var wasLoaded: Bool!
    var defQueue = [MPMediaItem]()
    var defQ = [Int: MPMediaItem]()
    var defQueueCount: Int!
    var defIndex: Int!
    var isUsrQueue: Bool!
    @objc    var usrQueue = [MPMediaItem]()
    var usrQueueCount: Int!
    var userQueueIndex: Int!
    var isUserQueue: Bool!{
        if usrQueueCount > 0{
            return true
        }else{
            return false
        }
    }
    var usrIndex: Int!
    var isShuffle: Bool!
    var shufQueue = [MPMediaItem]()
    var shufQueueCount: Int!{
        return defQueueCount
    }
    var shufIndex: Int!
    var defIsAnyAfter: Bool!{
        if(defIndex + 1 == defQueueCount){
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
        if(usrIndex + 1 == usrQueueCount){
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
        if(shufIndex + 1 == shufQueueCount){
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
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "change", ofType: "mp3")!)
        do{
            try player1 = AVAudioPlayer(contentsOf: url)
            player = player1
        }catch let error{
            print("chuj nie udalo sie zainicjalizowac \(error)")
        }
        playerFlag = 1
        wasLoaded = false
        defIndex = 0
        defQueueCount = 1
        isUsrQueue = false
        usrQueueCount = 0
        usrIndex = 0
        isShuffle = false
        shufIndex = 0
        NotificationCenter.default.addObserver(self, selector: #selector(Plum.handleAudioSessionInterruption(notification:)), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        if observed{
            player.addObserver(self, forKeyPath: #keyPath(AVAudioPlayer.data), options: [.new, .initial], context: nil)
            player.addObserver(self, forKeyPath: #keyPath(AVAudioPlayer.rate), options: [.new], context: nil)
            observed = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        UIApplication.shared.endReceivingRemoteControlEvents()
        //player.removeObserver(self, forKeyPath: #keyPath(AVAudioPlayer.currentItem), context: nil)
        //player.removeObserver(self, forKeyPath: #keyPath(AVAudioPlayer.rate), context: nil)
        timer.invalidate()

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
        if new{
            let item = defQueue[index]
            if(loadWithMediaItem(item: item) != "succ"){
                playFromDefQueue(index: index+1, new: true)
            }
        }
        defIndex = index
    }
    
    func playFromUsrQueue(index: Int){
        let item = usrQueue[index]
        if(loadWithMediaItem(item: item) != "succ"){
            playFromUsrQueue(index: index+1)
        }
        usrIndex = index
    }
    
    func playFromShufQueue(index: Int, new: Bool){
        if new{
            let item = shufQueue[index]
            if(loadWithMediaItem(item: item) != "succ"){
                playFromShufQueue(index: index+1, new: true)
            }
        }
        shufIndex = index
    }
    
    func createDefQueue(items: [MPMediaItem]){
        clearQueue()
        defQueue.removeAll()
        for i in 0 ..< items.count{
            items[i].index = i
            defQueue.append(items[i])
        }
        //defQueue.append(contentsOf: items)
        defQueueCount = defQueue.count
    }
    
    func addNext(item: MPMediaItem){
        if(!isUsrQueue){
            isUsrQueue = true
            usrQueue.append(currentItem!)
            usrQueue.append(item)
            usrQueueCount = 2
        }else{
            usrQueue.insert(item, at: usrIndex + 1)
            usrQueueCount = usrQueueCount + 1
        }
    }
    
    func addLast(item: MPMediaItem){
        if(!isUsrQueue){
            isUsrQueue = true
            usrQueue.append(currentItem!)
            usrQueue.append(item)
            usrQueueCount = 2
        }else{
            usrQueue.append(item)
            usrQueueCount = usrQueueCount + 1
        }
    }
    
    func next(){
        timer.invalidate()
        if(!isUsrQueue){
            if(!isShuffle){
                if(defIsAnyAfter){
                    playFromDefQueue(index: defIndex + 1, new: true)
                }else{
                    playFromDefQueue(index: 0, new: true)
                }
            }else{
                if(shufIsAnyAfter){
                    playFromShufQueue(index: shufIndex + 1, new: true)
                }else{
                    playFromShufQueue(index: 0, new: true)
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
                        }
                    }else{
                        if(shufIsAnyAfter){
                            playFromShufQueue(index: shufIndex + 1, new: true)
                        }else{
                            playFromShufQueue(index: 0, new: true)
                        }
                    }
                clearQueue()
                }
            }
        NotificationCenter.default.post(name: Plum.playBackStateChanged, object: nil, userInfo: ["Artist": "Title"])
        //print("nextnext")
    }
    
    func prev(){
        timer.invalidate()
        if(player.currentTime < 3){
            if(!isUsrQueue){
                if(!isShuffle){
                    if(defIsAnyBefore){
                        playFromDefQueue(index: defIndex - 1, new: true)
                    }else{
                        playFromDefQueue(index: defQueueCount - 1, new: true)
                    }
                }else{
                    if(shufIsAnyBefore){
                        playFromShufQueue(index: shufIndex - 1, new: true)
                    }else{
                        playFromShufQueue(index: shufQueueCount - 1, new: true)
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
            NotificationCenter.default.post(name: Plum.playBackStateChanged, object: nil, userInfo: ["Artist": "Title"])
        }
        else{
            player.currentTime = 0
        }
    }
    
    func play(){
        if shouldResumeAfterInterruption == false{
            shouldResumeAfterInterruption = true
        }
        if !session{
            initSession()
            session = true
        }
        if(currentItem != nil){
            if(!player.isPlaying){
                player.play()
            }else{
                print("player is already playing")
            }
        }
        NotificationCenter.default.post(name: Plum.playBackStateChanged, object: nil, userInfo: ["Artist": "Title"])
    }
    
    func pause(){
        if state == .interrupted{
            shouldResumeAfterInterruption = false
        }
        if(player.isPlaying){
            player.pause()
        }else{
            print("player is currently not playing")
        }
        NotificationCenter.default.post(name: Plum.playBackStateChanged, object: nil, userInfo: ["Artist": "Title"])
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
        usrQueueCount = 0
        isUsrQueue = false
    }
    
    func shuffleCurrent(){
        if(isShuffle){
            shufQueue.removeAll()
        }
        isShuffle = true
        shufIndex = 0
        shufQueue = defQueue
        print("shufcount = \(shufQueue.count) a defIndex jest = \(defIndex)")
        if(defIndex != 0){
            //swap(&shufQueue[0], &shufQueue[defIndex])
            (shufQueue[0], shufQueue[defIndex]) = (shufQueue[defIndex], shufQueue[0])
        }
        print("shufQueue.count = \(shufQueue.count)")
        shufQueue.shuffle()
    }

    func disableShuffle(){
        print("Kliknales disableShuffle")
        isShuffle = false
        shufIndex = 0
        defIndex = currentItem?.index
        print("defindex = \(defIndex)")
        shufQueue.removeAll()
    }
    
    func nowPlayingItem() -> MPMediaItem{
        print("Now playing: \(currentItem?.value(forProperty: MPMediaItemPropertyTitle))")
        return currentItem!
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
            return currentItem!.value(forProperty: MPMediaItemPropertyTitle) as! String
        case "detail":
            return "\(currentItem!.value(forProperty: MPMediaItemPropertyArtist) as! String) - \(currentItem!.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String)"
        case "out of":
            if(!isShuffle){
                if(!isUsrQueue){
                    return "\(defIndex + 1) of \(defQueueCount!)"
                }else{
                    return "\(usrIndex! + 1) of \(usrQueueCount!)"
                }
            }else{
                if(!isUsrQueue){
                return "\(shufIndex + 1) of \(shufQueueCount!)"
            }else{
                return "\(usrIndex! + 1) of \(usrQueueCount!)"
                }
            }
            
        default:
            return "Zly typ, typie"
        }
    }
    
    func currentIndex() -> Int{
        var index = 0
        if(isShuffle){
            index = shufIndex
        }else if(isUsrQueue){
            index = usrIndex
        }else if(!isShuffle){
            index = defIndex
        }
        return index
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer.invalidate()
        currentItem?.setValue((currentItem?.playCount)! + 1, forKey: MPMediaItemPropertyPlayCount)
        next()
        play()
    }
    
    func audioSessionInterrupted(_ notification: Notification){
        print("Interruption received: \(notification)")
    }
    
    func initAV(){
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "change", ofType: "mp3")!)
        do{
            try player1 = AVAudioPlayer(contentsOf: url)
            player = player1
            playerFlag = 1
        }catch let error{
            print("chuj nie udalo sie zainicjalizowac \(error)")
        }
    }
    
    @objc func handleAudioSessionInterruption(notification: Notification){
        guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt, let interruptionType = AVAudioSessionInterruptionType(rawValue: typeInt) else {return}
        
        switch interruptionType{
        case .began:
            playbackState.interrupted
        case .ended:
            do{
                try AVAudioSession.sharedInstance().setActive(true)
                if (!shouldResumeAfterInterruption){
                    shouldResumeAfterInterruption = true
                    return
                }
                guard let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}
                let interruptionOptions = AVAudioSessionInterruptionOptions(rawValue: optionsInt)
                if (interruptionOptions.contains(.shouldResume)){
                    player.play()
                }
            }
            catch{
                print("Blad przy powrocie z przerwania")
            }
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
        if GlobalSettings.ratingMode{
            var str = ""
            let itrating = item?.rating
            switch itrating{
            case 1?:
                str = "★☆☆☆☆"
            case 2?:
                str = "★★☆☆☆"
            case 3?:
                str = "★★★☆☆"
            case 4?:
                str = "★★★★☆"
            case 5?:
                str = "★★★★★"
            default:
                str = "☆☆☆☆☆"
            }
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = str
        }else{
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = item?.albumTitle ?? "Unknown Album"
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
    
    func loadWithMediaItem(item: MPMediaItem) -> String{
        if(item.assetURL != nil){
            do{
                print("Trying to load \(String (describing:item.value(forProperty: MPMediaItemPropertyTitle)))...")
                player = try AVAudioPlayer(contentsOf: (item.value(forProperty: MPMediaItemPropertyAssetURL))as! URL)
                player.prepareToPlay()
                currentItem = item
                wasLoaded = true
                initialized = true
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(Plum.updatePlaybackRateData), userInfo: nil, repeats: true)
                timer.fire()
                //updateGeneralMetadata()
            }catch{
                print("Failed to initialize with URL")
            }
            player.delegate = self
            return "succ"
        }else{
            print("iCloud item, please download it in music app and come back")
            return "fail"
        }
        if skip{
            if currentItem?.rating == nil{
                next()
            }
        }
    }
    
    func rateItem(rating: Int){
        currentItem?.setValue(rating, forKey: MPMediaItemPropertyRating)
        print("Rated \(rating) for Awesome")
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
    }
    
    func landInArtist(_ item: MPMediaItem, new: Bool){
        var index: Int!
        let artist = musicQuery.shared.songsByArtistID(artist: item.albumArtistPersistentID)
        for i in 0 ..< artist.count{
            artist[i].index = i
            if artist[i].persistentID == item.persistentID{
                index = i
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
    }
    
    @objc dynamic private func audioRouteChangeListener(notification:NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            print("headphone plugged in")
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            print("headphone pulled out")
            self.pause()
        default:
            break
        }
    }
    
    func setNextPrev() -> (prev: MPMediaItem?, next: MPMediaItem?){
        var prev: MPMediaItem?
        var next: MPMediaItem?
        
        if isUsrQueue{
            if usrQueue[usrIndex-1].assetURL != nil{
                prev = usrQueue[usrIndex-1]
            }else{
                if isShuffle{
                    if shufQueue[shufIndex-1].assetURL != nil{
                        prev = shufQueue[shufIndex-1]
                    }else{
                        prev = nil
                    }
                }else{
                    if defQueue[defIndex-1].assetURL != nil{
                        prev = defQueue[defIndex-1]
                    }else{
                        prev = nil
                    }
                }
            }
            if usrQueue[usrIndex+1].assetURL != nil{
                next = usrQueue[usrIndex+1]
            }else{
                if isShuffle{
                    if shufQueue[shufIndex+1].assetURL != nil{
                        next = shufQueue[shufIndex+1]
                    }else{
                        next = nil
                    }
                }else{
                    if defQueue[defIndex+1].assetURL != nil{
                        next = defQueue[defIndex+1]
                    }else{
                        next = nil
                    }
                }
            }
        }else{
            if isShuffle{
                if shufQueue[shufIndex-1].assetURL != nil{
                    prev = shufQueue[shufIndex-1]
                }
                if shufQueue[shufIndex+1].assetURL != nil{
                    next = shufQueue[shufIndex+1]
                }
            }else{
                if defQueue[defIndex-1].assetURL != nil{
                    prev = defQueue[defIndex-1]
                }
                if defQueue[defIndex+1].assetURL != nil{
                    next = defQueue[defIndex+1]
                }
            }
        }
        return (prev, next)
    }
}
