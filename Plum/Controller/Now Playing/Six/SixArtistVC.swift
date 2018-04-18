//
//  SixArtistVC.swift
//  Plum
//
//  Created by Adam Wienconek on 12.04.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SixArtistVC: UITableViewController {
    
    let player = Plum.shared
    
    var result = [String: [MPMediaItem]]()
    var indexes = [String]()
    var cellTypes = [[Int]]()
    var songs = [MPMediaItem]()
    var activeRow = 0
    var activeSection = 0
    var absoluteRow = 0
    var receivedID: MPMediaEntityPersistentID!
    var lightTheme = false
    var fxView: UIVisualEffectView!
    var statusBarStyle: UIStatusBarStyle!
    var separatorColor: UIColor!
    var toScroll = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .playbackChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .playbackChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusBarStyle = UIApplication.shared.statusBarStyle
        reload()
        tableView.scrollToRow(at: toScroll, at: .top, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = statusBarStyle
    }
    
    @IBAction func ratingPressed() {
        GlobalSettings.changeRating(!GlobalSettings.rating)
        tableView.reloadData()
    }
    
    func setupDict() {
        result = [String: [MPMediaItem]]()
        cellTypes = [[Int]]()
        songs = [MPMediaItem]()
        indexes = [String]()
        songs = musicQuery.shared.songsByArtistID(artist: (player.currentItem?.albumArtistPersistentID)!)
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for song in songs {
            let objStr = song.title!.trimmingCharacters(in: .whitespaces)
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if result["\(secondStr.first!)"] != nil {
                        result["\(secondStr.first!)"]?.append(song)
                    }else{
                        result["\(secondStr.first!)"] = []
                        result["\(secondStr.first!)"]?.append(song)
                        indexes.append("\(secondStr.uppercased().first!)")
                    }
                }
            }else{
                let prefix = "\(article.first!)".uppercased()
                if Int(prefix) != nil {
                    if result["#"] != nil {
                        result["#"]?.append(song)
                    }else{
                        result["#"] = []
                        result["#"]?.append(song)
                        anyNumber = true
                    }
                }else if prefix.firstSpecial() {
                    if result["?"] != nil {
                        result["?"]?.append(song)
                    }else{
                        result["?"] = []
                        result["?"]?.append(song)
                        anySpecial = true
                    }
                }else if result[prefix] != nil {
                    result[prefix]?.append(song)
                }else{
                    result[prefix] = []
                    result[prefix]?.append(song)
                    indexes.append(prefix)
                }
            }
        }
        if anyNumber {
            indexes.append("#")
        }
        if anySpecial {
            indexes.append("?")
        }
        songs.removeAll()
        for index in indexes {
            songs.append(contentsOf: result[index]!)
        }
    }
    
}

extension SixArtistVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cellTypes[indexPath.section][indexPath.row] == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! ArtistUpCell
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            cell.setup(item: item!)
            if indexPath == toScroll{
                cell.backgroundColor = GlobalSettings.tint.color
                cell.title.textColor = GlobalSettings.tint.bar
                cell.album.textColor = GlobalSettings.tint.bar
                cell.duration.textColor = GlobalSettings.tint.bar
            }else{
                if indexPath.absoluteRow(tableView) % 2 == 0 {
                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                } else {
                    cell.backgroundColor = .clear
                }
                cell.title.textColor = .white
                cell.album.textColor = .white
                cell.duration.textColor = .white
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellTypes[activeSection][activeRow] != 0 {
            cellTypes[activeSection][activeRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeRow, section: activeSection)], with: .fade)
        }
        activeSection = indexPath.section
        activeRow = indexPath.row
        absoluteRow = indexPath.absoluteRow(tableView)
        if cellTypes[activeSection][activeRow] == 0 {
            if player.isPlayin() {
                let item = result[indexes[activeSection]]?[activeRow]
                if item?.persistentID != player.currentItem?.persistentID {
                    cellTypes[activeSection][activeRow] = 1
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }else{
                    player.landInArtist(item!, new: false)
                }
            }else{
                if player.isShuffle {
                    player.disableShuffle()
                    player.createDefQueue(items: songs)
                    player.defIndex = absoluteRow
                    player.shuffleCurrent()
                    player.playFromShufQueue(index: 0, new: true)
                }else{
                    player.createDefQueue(items: songs)
                    player.playFromDefQueue(index: absoluteRow, new: true)
                }
                player.play()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SixArtistVC {
    
    @objc func reload() {
        setupDict()
        cellTypes = [[Int]]()
        for index in indexes {
            cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
        }
        findCurrent()
        tableView.reloadData()
    }
    
    func findCurrent() {
        for section in 0 ..< indexes.count {
            for row in 0 ..< (result[indexes[section]]?.count)! {
                if result[indexes[section]]![row].persistentID == player.currentItem?.persistentID {
                    toScroll = IndexPath(row: row, section: section)
                    break
                }
            }
        }
    }
}

extension SixArtistVC {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if cellTypes[activeSection][activeRow] == 1 {
            cellTypes[activeSection][activeRow] = 0
            let indexPath = IndexPath(row: activeRow, section: activeSection)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    func shuffleArtist(){
        player.landInArtist(player.currentItem!, new: false)
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: false)
    }
    
    @IBAction func playNextBtn(_ sender: Any) {
        player.addNext(item: songs[absoluteRow])
        cellTypes[activeSection][activeRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeRow, section: activeSection)], with: .right)
    }
    @IBAction func playLastBtn(_ sender: Any) {
        player.addLast(item: songs[absoluteRow])
        cellTypes[activeSection][activeRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeRow, section: activeSection)], with: .right)
    }
    @IBAction func playNowBtn(_ sender: Any) {
        if(player.isUsrQueue){
            player.clearQueue()
        }
        if(player.isShuffle){
            player.disableShuffle()
            player.defIndex = absoluteRow
            player.createDefQueue(items: songs)
            player.shuffleCurrent()
            player.playFromShufQueue(index: 0, new: true)
        }else{
            player.createDefQueue(items: songs)
            player.playFromDefQueue(index: absoluteRow, new: true)
        }
        player.play()
        cellTypes[activeSection][activeRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeRow, section: activeSection)], with: .right)
    }
    
}
