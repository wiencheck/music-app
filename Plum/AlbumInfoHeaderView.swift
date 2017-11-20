//
//  AlbumInfoHeaderView.swift
//  Plum
//
//  Created by Adam Wienconek on 11.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumInfoHeaderView: UIView {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var songsLabel:UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var shufBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var backgroundView: UIImageView!
    var songs: [MPMediaItem]!
    var album: AlbumB!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: "AlbumInfoHeader", bundle: nil).instantiate(withOwner: self, options: nil)
        view.frame = self.bounds
        self.addSubview(view)
        backgroundView.frame = view.bounds
        view.addSubview(backgroundView)
    }
    
    func setup(album: AlbumB, play: Bool){
        self.album = album
        playBtn.isHidden = !play
        songs = album.items
        titleLabel.text = album.name
        yearLabel.text = album.year
        artwork.image = album.artwork?.image(at: artwork.bounds.size) ?? #imageLiteral(resourceName: "no_music")
        artwork.layer.cornerRadius = 6.0
        songsLabel.text = "\(album.songsIn) songs, \(calcDuration(items: songs)) minutes"
        self.layer.borderWidth = 0.5
        self.backgroundView.image = #imageLiteral(resourceName: "background_se")
    }
    
    func calcDuration(items: [MPMediaItem]) -> String{
        var duration: TimeInterval = 0
        for i in 0...items.count-1{
            duration = duration + items[i].playbackDuration
        }
        return duration.calculateFromTimeInterval().minute
    }
    
    @IBAction func playBtnPressed(_ sender: UIButton){
        Plum.shared.disableShuffle()
        Plum.shared.createDefQueue(items: songs)
        if Plum.shared.currentItem?.albumTitle == album.name{
            var i = 0
            for song in songs{
                if Plum.shared.currentItem?.persistentID == song.persistentID{
                    Plum.shared.playFromDefQueue(index: i, new: false)
                    break
                }
                i += 1
            }
        }else{
            Plum.shared.playFromDefQueue(index: 0, new: true)
        }
        Plum.shared.play()
    }
    
    @IBAction func shufBtnPressed(_ sender: UIButton){
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.defIndex = 0
        if Plum.shared.currentItem?.albumTitle == album.name{
            var i = 0
            for song in songs{
                if Plum.shared.currentItem?.persistentID == song.persistentID{
                    Plum.shared.defIndex = i
                    Plum.shared.shuffleCurrent()
                    Plum.shared.playFromShufQueue(index: 0, new: false)
                    break
                }
                i += 1
            }
        }else{
            Plum.shared.defIndex = 0
            Plum.shared.shuffleCurrent()
            Plum.shared.playFromShufQueue(index: 0, new: true)
        }
        Plum.shared.play()
    }

}
