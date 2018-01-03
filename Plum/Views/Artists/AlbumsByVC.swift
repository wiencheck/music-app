//
//  ArtistAlbumsVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 18.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumsByVC: UITableViewController {
    
    let player = Plum.shared
    var receivedID: MPMediaEntityPersistentID!
    var als: [AlbumB]!
    var picked: AlbumB!
    var pickedID: MPMediaEntityPersistentID!
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        //tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        tableView.backgroundColor = UIColor.lightBackground
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.separatorColor = UIColor.lightSeparator
        als = musicQuery.shared.artistAlbumsID(artist: receivedID)
        als = als.sorted(by:{ ($0.name! > $1.name!)})
        als.reverse()
        title = als.first?.artist
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return als.count + 1
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }else{
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
            self.picked = self.als[path.row-1]
            self.playNow()
            self.tableView.setEditing(false, animated: true)
        })
        let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
            self.picked = self.als[path.row-1]
            self.playNext()
            self.tableView.setEditing(false, animated: true)
        })
        let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
            self.picked = self.als[path.row-1]
            self.shuffle()
            self.tableView.setEditing(false, animated: true)
        })
        play.backgroundColor = .red
        next.backgroundColor = .orange
        shuffle.backgroundColor = .purple
        return [shuffle, next, play]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "allSongsCell", for: indexPath)
            cell.textLabel?.text = "All songs"
            cell.backgroundColor = .clear
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as? AlbumCell
            cell?.setupArtist(album: als[indexPath.row - 1])
            cell?.backgroundColor = .clear
            return cell!
        }
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.2))
//        v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
//        return v
//    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }else {
            return 94
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            performSegue(withIdentifier: "allSongs", sender: nil)
        }else{
            pickedID = als[indexPath.row - 1].ID
            performSegue(withIdentifier: "album", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedID
        }else if let destination = segue.destination as? ArtistSongs{
            destination.receivedID = receivedID
        }
    }
    
    func playNow() {
        let items = picked.items
        if player.isShuffle {
            player.disableShuffle()
        }
        player.createDefQueue(items: items)
        player.playFromDefQueue(index: 0, new: true)
        player.play()
    }
    
    func playNext() {
        let items = picked.items
        var i = items.count - 1
        while i > -1 {
            player.addNext(item: items[i])
            i -= 1
        }
    }
    
    func shuffle() {
        let items = picked.items
        player.createDefQueue(items: items)
        player.defIndex = Int(arc4random_uniform(UInt32(items.count)))
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: true)
        player.play()
    }

}

extension AlbumsByVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        if (changed) {
            print("New tab order:")
            for i in 0 ..< viewControllers.count {
                defaults.set(viewControllers[i].tabBarItem.tag, forKey: String(i))
                print("\(i): \(viewControllers[i].tabBarItem.title!) (\(viewControllers[i].tabBarItem.tag))")
            }
        }
    }
}
