//
//  FolderVC.swift
//  Plum
//
//  Created by Adam Wienconek on 14.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class FolderVC: UITableViewController {
    
    let player = Plum.shared
    var receivedID: MPMediaEntityPersistentID!
    var pickedID: MPMediaEntityPersistentID!
    var playlists: [Playlist]!
    var pickedList: Playlist!
    var barTitle: String!
    var currentTheme: Theme!
    @IBOutlet weak var themeBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        currentTheme = GlobalSettings.theme
        title = barTitle
        print(receivedID)
        setup()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
        tableView.tableFooterView = UIView(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
        updateTheme()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    @IBAction func themeBtnPressed() {
        if GlobalSettings.theme == .dark{
            GlobalSettings.changeTheme(.light)
        }else{
            GlobalSettings.changeTheme(.dark)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ArtistCell
        cell.setup(list: playlists[indexPath.row])
        cell.backgroundColor = .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = playlists[indexPath.row]
        pickedID = item.ID
        pickedList = item
        performSegue(withIdentifier: "playlist", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
            self.pickedList = self.playlists[path.row]
            self.playNow()
            self.tableView.setEditing(false, animated: true)
        })
        play.backgroundColor = .red
        let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
            self.pickedList = self.playlists[path.row]
            self.playNext()
            self.tableView.setEditing(false, animated: true)
        })
        next.backgroundColor = .orange
        let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
            self.pickedList = self.playlists[path.row]
            self.shuffle()
            self.tableView.setEditing(false, animated: true)
        })
        shuffle.backgroundColor = .purple
        return [shuffle, next, play]
    }
    
    func playNow() {
        let items = pickedList.items
        if player.isShuffle {
            player.disableShuffle()
        }
        player.createDefQueue(items: items)
        player.playFromDefQueue(index: 0, new: true)
        player.isShuffle = false
        player.play()
    }
    
    func playNext() {
        let items = pickedList.items
        var i = items.count - 1
        while i > -1 {
            player.addNext(item: items[i])
            i -= 1
        }
    }
    
    func shuffle() {
        let items = pickedList.items
        player.createDefQueue(items: items)
        player.defIndex = Int(arc4random_uniform(UInt32(items.count)))
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: true)
        player.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PlaylistVC {
            destination.receivedID = pickedID
            destination.receivedList = pickedList
        }
    }
    
    func setup() {
        playlists = [Playlist]()
        for list in musicQuery.shared.playlists {
            if list.parentID == receivedID {
                playlists.append(list)
            }
        }
    }
    
    @objc func updateTheme() {
        guard let bar = navigationController?.navigationBar else { return }
        switch currentTheme {
        case .light:
            bar.barStyle = .default
            bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            themeBtn.image = #imageLiteral(resourceName: "light_bar")
        case .dark:
            bar.barStyle = .blackTranslucent
            bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            themeBtn.image = #imageLiteral(resourceName: "dark_bar")
        default:
            bar.barStyle = .blackTranslucent
            bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        bar.tintColor = GlobalSettings.tint.color
        tableView.backgroundColor = UIColor.background
        tableView.separatorColor = UIColor.separator
        tableView.reloadData()
    }

}

/* Handle purchase events */
//extension FolderVC {
//
//    func registerTrialObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleUnlockChangedNotification(_:)), name: .unlockChanged, object: nil)
//    }
//
//    func unregisterTrialObserver() {
//        NotificationCenter.default.removeObserver(self, name: .unlockChanged, object: nil)
//    }
//
//    @objc func handleUnlockChangedNotification(_ sender: Notification) {
//        shouldUnlockFeatures(GlobalSettings.unlock)
//    }
//
//    func shouldUnlockFeatures(_ should: Bool) {
//        themeBtn.isEnabled = should
//        updateTheme()
//    }
//}

