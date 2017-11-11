//
//  AlbumVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 18.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumVC: UITableViewController {
    
    var rating: Bool!
    var bigAssQuery = musicQuery.shared
    var songs = [MPMediaItem]()
    var album: AlbumB!
    var received: AlbumB!
    var receivedID: MPMediaEntityPersistentID!
    var indexes = [Int]()
    @IBOutlet weak var upperBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        readSettings()
        if receivedID != nil{
            album = musicQuery.shared.albumID(album: receivedID)
        }else{
            album = received
        }
        songs = album.items
        for i in 0..<songs.count{
            songs[i].index = i
        }
        upperBar.title = album.name

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //songs = bigAssQuery.albumID(album: receivedID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if album.manyArtists{
            let cell = tableView.dequeueReusableCell(withIdentifier: "extendedSongCell", for: indexPath) as! SongInAlbumCell
            cell.setupA(item: songs[indexPath.row])
            cell.backgroundColor = .clear
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "songInAlbumCell", for: indexPath) as! SongInAlbumCell
            cell.setup(item: songs[indexPath.row])
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! AlbumInfoCell
        header.setup(album: album, play: true)
        header.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        header.layer.borderWidth = 0.7
        header.layer.borderColor = tableView.separatorColor?.cgColor
        return header
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 1))
        v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
        return v
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("songs = \(songs.count)")
            if(Plum.shared.isShuffle){
                Plum.shared.disableShuffle()
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.defIndex = indexPath.row
                Plum.shared.shuffleCurrent()
            }else{
                Plum.shared.createDefQueue(items: songs)
            }
            Plum.shared.playFromDefQueue(index: indexPath.row, new: true)
            Plum.shared.play()
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if album.manyArtists{
            return 54
        }else{
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 112
    }
    
    @IBAction func NPBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToNP", sender: nil)
    }
    @IBAction func shufBtnPressed(_ sender: Any) {
        Plum.shared.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.shuffleCurrent()
        Plum.shared.playFromShufQueue(index: 0, new: true)
        Plum.shared.play()
    }
    
    func readSettings(){
        rating = GlobalSettings.ratingMode
    }
}
