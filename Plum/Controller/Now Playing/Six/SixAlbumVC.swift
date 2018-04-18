//
//  SixAlbumVC.swift
//  Plum
//
//  Created by Adam Wienconek on 12.04.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SixAlbumVC: UITableViewController, UIGestureRecognizerDelegate{
    
    var cellTypes = [Int]()
    var songs = [MPMediaItem]()
    var index: Int = 0
    var previousIndex = 0
    var receivedID: MPMediaEntityPersistentID!
    var lightTheme: Bool!
    var fxView: UIVisualEffectView!
    var statusBarStyle: UIStatusBarStyle!
    var toScroll = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        tableView.tableFooterView = UIView(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .trackChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        instruct("deploy", message: "Tap on now playing song to to immediately set current playing queue to the album", completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "playBackStateChanged"), object: nil)
    }
    
    func setup(){
        let item = Plum.shared.currentItem
        songs = musicQuery.shared.songsByAlbumID(album: item!.albumPersistentID)
        cellTypes = Array<Int>(repeating: 0, count: songs.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusBarStyle = UIApplication.shared.statusBarStyle
        setup()
        findCurrent()
        tableView.reloadData()
        tableView.scrollToRow(at: toScroll, at: .top, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = statusBarStyle
    }
    
    func findCurrent(){
        var i = 0
        for song in songs{
            if song.persistentID == Plum.shared.currentItem?.persistentID{
                toScroll = IndexPath(row: i, section: 0)
                break
            }
            i += 1
        }
    }
    
}

extension SixAlbumVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(cellTypes[indexPath.row] == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongInAlbumCell
            cell.setup(item: songs[indexPath.row])
            if indexPath == toScroll{
                cell.backgroundColor = GlobalSettings.tint.color
                cell.titleLabel.textColor = GlobalSettings.tint.bar
                cell.trackNumberLabel.textColor = GlobalSettings.tint.bar
                cell.durationLabel.textColor = GlobalSettings.tint.bar
            }else{
                if indexPath.row % 2 == 0 {
                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                } else {
                    cell.backgroundColor = .clear
                }
                cell.titleLabel.textColor = .white
                cell.trackNumberLabel.textColor = .white
                cell.durationLabel.textColor = .white
            }
            return cell
        }else if cellTypes[indexPath.row] == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.alpha = 0.5
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(cellTypes[previousIndex] == 1){
            cellTypes[previousIndex] = 0
            tableView.reloadRows(at: [IndexPath(row: previousIndex, section: 0)], with: .fade)
        }
        var rows = 0
        if indexPath.section > 0{
            for section in 0 ..< indexPath.section{
                rows += tableView.numberOfRows(inSection: section)
            }
            index = rows + indexPath.row
        }else{
            index = indexPath.row
        }
        previousIndex = index
        if(cellTypes[indexPath.row] == 0){
            let item = songs[indexPath.row]
            if(Plum.shared.isPlayin() && item.assetURL != Plum.shared.currentItem?.assetURL){
                cellTypes[indexPath.row] = 1
                tableView.reloadRows(at: [indexPath], with: .fade)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    if(self.cellTypes[indexPath.row] == 1){
                        self.cellTypes[indexPath.row] = 0
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                })
            }else{
                if item.assetURL == Plum.shared.currentItem?.assetURL{
                    Plum.shared.landInAlbum(item, new: false)
                }else{
                    Plum.shared.landInAlbum(item, new: true)
                }
                Plum.shared.play()
            }
        }else{
            cellTypes[indexPath.row] = 0
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if cellTypes[index] == 1 {
            cellTypes[index] = 0
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    func shuffleAlbum(){
        Plum.shared.landInAlbum(Plum.shared.currentItem!, new: false)
        Plum.shared.shuffleCurrent()
        Plum.shared.playFromShufQueue(index: 0, new: false)
    }
    
    @IBAction func playNextBtn(_ sender: Any) {
        Plum.shared.addNext(item: songs[index])
        cellTypes[index] = 0
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .right)
    }
    @IBAction func playLastBtn(_ sender: Any) {
        Plum.shared.addLast(item: songs[index])
        cellTypes[index] = 0
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .right)
    }
    @IBAction func playNowBtn(_ sender: Any) {
        if(Plum.shared.isUsrQueue){
            Plum.shared.clearQueue()
        }
        if(Plum.shared.isShuffle){
            Plum.shared.disableShuffle()
            Plum.shared.defIndex = index
            Plum.shared.createDefQueue(items: songs)
            Plum.shared.shuffleCurrent()
            Plum.shared.playFromShufQueue(index: 0, new: true)
        }else{
            Plum.shared.createDefQueue(items: songs)
            Plum.shared.playFromDefQueue(index: index, new: true)
        }
        Plum.shared.play()
        cellTypes[index] = 0
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .right)
    }
    
    @objc func reload(){
        index = 0
        setup()
        findCurrent()
        self.tableView.reloadData()
        //tableView.scrollToRow(at: toScroll, at: .top, animated: false)
    }
}
