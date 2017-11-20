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
        toggleLikeCommand(false)
        toggleDislikeCommand(false)
        toggleBookmarkCommand(false)
        toggleRatingCommand(false)
    }
    
    func switchRatingCommands(_ enable: Bool){
        toggleLikeCommand(enable)
        toggleDislikeCommand(enable)
        toggleBookmarkCommand(enable)
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
        
        //remoteCommandCenter.playCommand.isEnabled = enable
        //remoteCommandCenter.pauseCommand.isEnabled = enable
        //remoteCommandCenter.stopCommand.isEnabled = enable
        //remoteCommandCenter.togglePlayPauseCommand.isEnabled = enable
    }
    
    func toggleNextTrackCommand(_ enable: Bool) {
        if enable {
            remoteCommandCenter.nextTrackCommand.addTarget(self, action: #selector(RemoteCommandManager.handleNextTrackCommandEvent(_:)))
        }
        else {
            remoteCommandCenter.nextTrackCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleNextTrackCommandEvent(_:)))
        }
        
        remoteCommandCenter.nextTrackCommand.isEnabled = enable
    }
    
    func togglePreviousTrackCommand(_ enable: Bool) {
        if enable {
            remoteCommandCenter.previousTrackCommand.addTarget(self, action: #selector(RemoteCommandManager.handlePreviousTrackCommandEvent(event:)))
        }
        else {
            remoteCommandCenter.previousTrackCommand.removeTarget(self, action: #selector(RemoteCommandManager.handlePreviousTrackCommandEvent(event:)))
        }
        
        remoteCommandCenter.previousTrackCommand.isEnabled = enable
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
            remoteCommandCenter.likeCommand.localizedTitle = "★★★★☆"
            remoteCommandCenter.likeCommand.localizedShortTitle = "★★★★☆"
            remoteCommandCenter.likeCommand.addTarget(self, action: #selector(RemoteCommandManager.handleLikeCommandEvent(event:)))
        }
        else {
            remoteCommandCenter.likeCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleLikeCommandEvent(event:)))
        }
        
        remoteCommandCenter.likeCommand.isEnabled = enable
    }
    
    func toggleRatingCommand(_ enable: Bool){
        if enable{
            remoteCommandCenter.ratingCommand.minimumRating = 1.0
            remoteCommandCenter.ratingCommand.maximumRating = 2.0
            remoteCommandCenter.ratingCommand.addTarget(self, action: #selector(RemoteCommandManager.handleRatingCommandEvent(event:)))
        }else{
            remoteCommandCenter.ratingCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleRatingCommandEvent(event:)))
        }
        remoteCommandCenter.ratingCommand.isEnabled = enable
    }
    
    func toggleDislikeCommand(_ enable: Bool) {
        if enable {
            remoteCommandCenter.dislikeCommand.localizedTitle = "★☆☆☆☆"
            remoteCommandCenter.dislikeCommand.localizedShortTitle = "★☆☆☆☆"
            remoteCommandCenter.dislikeCommand.addTarget(self, action: #selector(RemoteCommandManager.handleDislikeCommandEvent(event:)))
        }
        else {
            remoteCommandCenter.dislikeCommand.removeTarget(self, action: #selector(RemoteCommandManager.handleDislikeCommandEvent(event:)))
        }
        remoteCommandCenter.dislikeCommand.isEnabled = enable
    }
    
    func toggleBookmarkCommand(_ enable: Bool){
        if enable{
            remoteCommandCenter.bookmarkCommand.localizedTitle = "★★☆☆☆"
            remoteCommandCenter.bookmarkCommand.localizedShortTitle = "★★☆☆☆"
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
        player.rateItem(rating: 4)
        return .success
    }
    
    @objc func handleDislikeCommandEvent(event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.rateItem(rating: 1)
        return .success
    }
    
    @objc func handleBookmarkCommandEvent(event: MPFeedbackCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.rateItem(rating: 3)
        return .success
    }
    
    @objc func handleRatingCommandEvent(event: MPRatingCommandEvent) -> MPRemoteCommandHandlerStatus{
        switch event.rating{
        case 1.0:
            print("1 star")
        case 2.0:
            print("2 stars")
        default:
            print("Default")
        }
        return .success
    }
}
