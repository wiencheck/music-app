//
//  RemoteCommandManager.swift
//  CCMusic
//
//  Created by Adam Wienconek on 25.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

class RemoteCommandManager: NSObject{
    
    static let shared = RemoteCommandManager()
    public let remoteCommandCenter = MPRemoteCommandCenter.shared()
    var player = Plum.shared
    
    override init(){
        super.init()
        toggleNextTrackCommand(true)
        togglePreviousTrackCommand(true)
        toggleChangePlaybackPositionCommand(true)
        activatePlaybackCommands(true)
    }
    
    deinit {
        activatePlaybackCommands(false)
        toggleNextTrackCommand(false)
        togglePreviousTrackCommand(false)
        toggleChangePlaybackPositionCommand(false)
        switchRatingCommands(false)
    }
    
    func switchRatingCommands(_ enable: Bool){
        if enable {
            switch GlobalSettings.ratings.count {
            case 1:
                toggleLikeCommand(true)
            case 2:
                toggleLikeCommand(true)
                toggleDislikeCommand(true)
            case 3:
                toggleLikeCommand(true)
                toggleDislikeCommand(true)
                toggleBookmarkCommand(true)
            default:
                print("Chyba nie ma nic w tablicy ratingow")
            }
        }else{
            toggleLikeCommand(false)
            toggleDislikeCommand(false)
            toggleBookmarkCommand(false)
        }
    }
    
    func switchLyricsCommand(_ enable: Bool){
        toggleLyricsCommand(enable)
        toggleStopLyricsCommand(enable)
    }
    
    func activatePlaybackCommands(_ enable: Bool){
        if enable {
            remoteCommandCenter.playCommand.addTarget(self, action: #selector(RemoteCommandManager.handlePlayCommandEvent(_:)))
            remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(RemoteCommandManager.handlePauseCommandEvent(_:)))
            remoteCommandCenter.stopCommand.addTarget(self, action: #selector(RemoteCommandManager.handleStopCommandEvent(_:)))
            remoteCommandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(RemoteCommandManager.handleTogglePlayPauseCommandEvent(_:)))
            
        }
        else {
            remoteCommandCenter.playCommand.removeTarget(self, action: #selector(RemoteCommandManager.handlePlayCommandEvent(_:)))
            remoteCommandCenter.pauseCommand.removeTarget(self, action: #selector(RemoteCommandManager.handlePauseCommandEvent(_:)))
            remoteCommandCenter.stopCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleStopCommandEvent(_:)))
            remoteCommandCenter.togglePlayPauseCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleTogglePlayPauseCommandEvent(_:)))
        }
        
//        remoteCommandCenter.playCommand.isEnabled = enable
//        remoteCommandCenter.pauseCommand.isEnabled = enable
//        remoteCommandCenter.stopCommand.isEnabled = enable
//        remoteCommandCenter.togglePlayPauseCommand.isEnabled = enable
    }
    
    func toggleNextTrackCommand(_ enable: Bool) {
        if enable {
            remoteCommandCenter.nextTrackCommand.addTarget(self, action: #selector(RemoteCommandManager.handleNextTrackCommandEvent(_:)))
        }
        else {
            remoteCommandCenter.nextTrackCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleNextTrackCommandEvent(_:)))
        }
        
        //remoteCommandCenter.nextTrackCommand.isEnabled = enable
    }
    
    func togglePreviousTrackCommand(_ enable: Bool) {
        if enable {
            remoteCommandCenter.previousTrackCommand.addTarget(self, action: #selector(RemoteCommandManager.handlePreviousTrackCommandEvent(event:)))
        }
        else {
            remoteCommandCenter.previousTrackCommand.removeTarget(self, action: #selector(RemoteCommandManager.handlePreviousTrackCommandEvent(event:)))
        }
        
        //remoteCommandCenter.previousTrackCommand.isEnabled = enable
    }

    func toggleChangePlaybackPositionCommand(_ enable: Bool) {
        if enable {
            remoteCommandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(RemoteCommandManager.handleChangePlaybackPositionCommandEvent(event:)))
        }
        else {
            remoteCommandCenter.changePlaybackPositionCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleChangePlaybackPositionCommandEvent(event:)))
        }
        
        
        remoteCommandCenter.changePlaybackPositionCommand.isEnabled = enable
    }
    
    func toggleLikeCommand(_ enable: Bool) {
        if enable {
            remoteCommandCenter.likeCommand.localizedTitle = GlobalSettings.ratings[0].rawValue
            remoteCommandCenter.likeCommand.localizedShortTitle = GlobalSettings.ratings[0].rawValue
            remoteCommandCenter.likeCommand.addTarget(self, action: #selector(RemoteCommandManager.handleLikeCommandEvent(event:)))
        }
        else {
            remoteCommandCenter.likeCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleLikeCommandEvent(event:)))
        }
        
        remoteCommandCenter.likeCommand.isEnabled = enable
    }
    
    func toggleLyricsCommand(_ enable: Bool){
        if enable{
            remoteCommandCenter.bookmarkCommand.localizedTitle = "Show lyrics"
            remoteCommandCenter.bookmarkCommand.localizedShortTitle = "Show lyrics"
            remoteCommandCenter.bookmarkCommand.addTarget(self, action: #selector(RemoteCommandManager.handleLyricsCommandEvent(event:)))
        }else{
            remoteCommandCenter.bookmarkCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleLyricsCommandEvent(event:)))
        }
        remoteCommandCenter.bookmarkCommand.isEnabled = enable
    }
    
    func toggleStopLyricsCommand(_ enable: Bool) {
        if enable {
            remoteCommandCenter.dislikeCommand.localizedTitle = "Stop posting lyrics"
            remoteCommandCenter.dislikeCommand.localizedShortTitle = "Stop posting lyrics"
            remoteCommandCenter.dislikeCommand.addTarget(self, action: #selector(RemoteCommandManager.handleStopLyricsCommandEvent(event:)))
        }else{
            remoteCommandCenter.dislikeCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleStopLyricsCommandEvent(event:)))
        }
        remoteCommandCenter.dislikeCommand.isEnabled = enable
    }
    
    func toggleDislikeCommand(_ enable: Bool) {
        //dislikeValue = feedbacks["Dislike"]?.stars
        if enable {
            remoteCommandCenter.dislikeCommand.localizedTitle = GlobalSettings.ratings[1].rawValue
            remoteCommandCenter.dislikeCommand.localizedShortTitle = GlobalSettings.ratings[1].rawValue
            remoteCommandCenter.dislikeCommand.addTarget(self, action: #selector(RemoteCommandManager.handleDislikeCommandEvent(event:)))
        }
        else {
            remoteCommandCenter.dislikeCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleDislikeCommandEvent(event:)))
        }
        remoteCommandCenter.dislikeCommand.isEnabled = enable
    }
    
    func toggleBookmarkCommand(_ enable: Bool){
        if enable{
            remoteCommandCenter.bookmarkCommand.localizedTitle = GlobalSettings.ratings[2].rawValue
            remoteCommandCenter.bookmarkCommand.localizedShortTitle = GlobalSettings.ratings[2].rawValue
            remoteCommandCenter.bookmarkCommand.addTarget(self, action: #selector(RemoteCommandManager.handleBookmarkCommandEvent(event:)))
        }else{
            remoteCommandCenter.bookmarkCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleBookmarkCommandEvent(event:)))
        }
        remoteCommandCenter.bookmarkCommand.isEnabled = enable
    }

    @objc func handlePauseCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.pause()
        
        return .success
    }
    
    @objc func handlePlayCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.play()
        
        return .success
    }
    
    @objc func handleStopCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.stop()
        
        return .success
    }
    
    @objc func handleTogglePlayPauseCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.togglePlayPause()
        
        return .success
    }
    
    @objc func handleNextTrackCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.next()
        if((player.currentItem?.assetURL) != nil){
            player.play()
        }
        return .success
    }
    
    @objc func handlePreviousTrackCommandEvent(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.prev()
        if((player.currentItem?.assetURL) != nil){
            player.play()
        }
        return .success
    }

    @objc func handleChangePlaybackPositionCommandEvent(event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.seekTo(event.positionTime)
        return .success
    }
    
    @objc func handleLikeCommandEvent(event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch GlobalSettings.ratings[0] {
        case .one:
            player.rateItem(rating: 1)
        case .two:
            player.rateItem(rating: 2)
        case .three:
            player.rateItem(rating: 3)
        case .four:
            player.rateItem(rating: 4)
        case .five:
            player.rateItem(rating: 5)
        default:
            handleStopRatingCommandEvent()
        }
        print(GlobalSettings.ratings[0].rawValue)
        return .success
    }
    
    @objc func handleDislikeCommandEvent(event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch GlobalSettings.ratings[1] {
        case .one:
            player.rateItem(rating: 1)
        case .two:
            player.rateItem(rating: 2)
        case .three:
            player.rateItem(rating: 3)
        case .four:
            player.rateItem(rating: 4)
        case .five:
            player.rateItem(rating: 5)
        default:
            handleStopRatingCommandEvent()
        }
        print(GlobalSettings.ratings[1].rawValue)
        return .success
    }
    
    @objc func handleBookmarkCommandEvent(event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch GlobalSettings.ratings[2] {
        case .one:
            player.rateItem(rating: 1)
        case .two:
            player.rateItem(rating: 2)
        case .three:
            player.rateItem(rating: 3)
        case .four:
            player.rateItem(rating: 4)
        case .five:
            player.rateItem(rating: 5)
        default:
            handleStopRatingCommandEvent()
        }
        print(GlobalSettings.ratings[0].rawValue)
        return .success
    }
    
    @objc func handleStopRatingCommandEvent(){
        GlobalSettings.changeRating(false, full: GlobalSettings.full)
    }
    
    @objc func handleLyricsCommandEvent(event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.shouldPost = true
        player.postLyrics()
        return .success
    }
    
    @objc func handleStopLyricsCommandEvent(event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.shouldPost = false
        GlobalSettings.changeLyrics(false)
        player.removeLyrics()
        return .success
    }
}
