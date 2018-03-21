//
//  ArtistCell.swift
//  wiencheck
//
//  Created by Adam Wienconek on 03.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistCell: UITableViewCell {
        
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func setup(artist: Artist){
        let albumsCount = artist.albumsIn
        let songsCount = artist.songsIn
        self.artistLabel.text = artist.name
        artistLabel.textColor = UIColor.mainLabel
        detailLabel.textColor = UIColor.mainLabel
        let alCSt = "\(albumsCount)"
        let sonCSt = "\(songsCount)"
        var alSt = " albums, "
        if albumsCount == 1 {
            alSt = " album, "
        }
        var sonSt = " songs"
        if songsCount == 1 {
            sonSt = " song"
        }
        let attAlbums = NSMutableAttributedString(string: alCSt)
        let attAlbumsR = NSRange(location: 0, length: attAlbums.length)
        attAlbums.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: attAlbumsR)
        let attSongs = NSMutableAttributedString(string: sonCSt)
        let attSongsR = NSRange(location: 0, length: attSongs.length)
        attSongs.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: attSongsR)
        let albums = NSMutableAttributedString(string: alSt)
        let songs = NSMutableAttributedString(string: sonSt)
        attAlbums.append(albums)
        attAlbums.append(attSongs)
        attAlbums.append(songs)
        detailLabel.attributedText = attAlbums
        artistImage.image = artist.artwork
    }
    
    func setup(list: Playlist) {
        let albumsCount = list.albumsIn
        let songsCount = list.songsIn
        self.artistLabel.text = list.name
        artistLabel.textColor = UIColor.mainLabel
        detailLabel.textColor = UIColor.mainLabel
        let alCSt = "\(albumsCount)"
        let sonCSt = "\(songsCount)"
        var alSt = " albums, "
        if albumsCount == 1 {
            alSt = " album, "
        }
        var sonSt = " songs"
        if songsCount == 1 {
            sonSt = " song"
        }
        let attAlbums = NSMutableAttributedString(string: alCSt)
        let attAlbumsR = NSRange(location: 0, length: attAlbums.length)
        attAlbums.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: attAlbumsR)
        let attSongs = NSMutableAttributedString(string: sonCSt)
        let attSongsR = NSRange(location: 0, length: attSongs.length)
        attSongs.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: attSongsR)
        let albums = NSMutableAttributedString(string: alSt)
        let songs = NSMutableAttributedString(string: sonSt)
        attAlbums.append(albums)
        attAlbums.append(attSongs)
        attAlbums.append(songs)
        detailLabel.attributedText = attAlbums
        if list.isFolder {
            artistImage.image = #imageLiteral(resourceName: "folder")
        }else{
            artistImage.image = list.image
        }
    }
}
