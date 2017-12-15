//
//  AlbumVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 18.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumVC: UITableViewController, QueueCellDelegate, UIGestureRecognizerDelegate {
    
    let player = Plum.shared
    let defaults = UserDefaults.standard
    var rating: Bool!
    var bigAssQuery = musicQuery.shared
    var songs = [MPMediaItem]()
    var album: AlbumB!
    var received: AlbumB!
    var receivedID: MPMediaEntityPersistentID!
    var pickedArtistID: MPMediaEntityPersistentID!
    var cellTypes = [Int]()
    var absoluteIndex = 0
    var activeIndexRow = 0
    @IBOutlet weak var upperBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        readSettings()
        if receivedID != nil{
            album = musicQuery.shared.albumID(album: receivedID)
        }else{
            album = received
        }
        songs = album.items
        cellTypes = Array<Int>(repeating: 0, count: songs.count)
        for i in 0..<songs.count{
            songs[i].index = i
        }
        upperBar.title = album.artist
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readSettings()
        tableView.reloadData()
        //songs = bigAssQuery.albumID(album: receivedID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell", for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }else{
            if album.manyArtists{
                absoluteIndex = indexPath.absoluteRow(tableView) - 1
                if(cellTypes[absoluteIndex] == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "extendedSongCell", for: indexPath) as? SongInAlbumCell
                    let item = songs[absoluteIndex]
                    if(item != player.currentItem){
                        cell?.setupA(item: item)
                    }else{
                        cell?.setupA(item: item)
                    }
                    cell?.backgroundColor = .clear
                    return cell!
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
                    cell?.delegate = self
                    cell?.backgroundColor = .clear
                    return cell!
                }
            }else{
                absoluteIndex = indexPath.absoluteRow(tableView)-1
                if(cellTypes[absoluteIndex] == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongInAlbumCell
                    let item = songs[absoluteIndex]
                    if(item != player.currentItem){
                        cell?.setup(item: item)
                    }else{
                        cell?.setup(item: item)
                    }
                    cell?.backgroundColor = .clear
                    return cell!
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
                    cell?.delegate = self
                    cell?.backgroundColor = .clear
                    return cell!
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! AlbumInfoCell
        header.setup(album: album, play: true)
        return header.contentView
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.2))
        v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.6)
        return v
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(cellTypes[activeIndexRow] == 1 || cellTypes[activeIndexRow] == 2){
            cellTypes[activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: 0)], with: .fade)
        }
        
        if indexPath.row == 0 {
            let items = songs
            player.createDefQueue(items: items)
            player.defIndex = Int(arc4random_uniform(UInt32(items.count)))
            player.shuffleCurrent()
            player.playFromShufQueue(index: 0, new: true)
            player.play()
        }else{
            activeIndexRow = indexPath.row - 1
            absoluteIndex = indexPath.absoluteRow(tableView) - 1
            if(cellTypes[activeIndexRow] == 0){
                if(player.isPlayin()){
                    cellTypes[activeIndexRow] = 1
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }else{
                    if(player.isShuffle){
                        player.disableShuffle()
                        player.createDefQueue(items: songs)
                        player.defIndex = absoluteIndex
                        player.shuffleCurrent()
                        player.playFromShufQueue(index: 0, new: true)
                    }else{
                        player.createDefQueue(items: songs)
                        player.playFromDefQueue(index: absoluteIndex, new: true)
                    }
                    player.play()
                }
            }else{
                cellTypes[activeIndexRow] = 0
                tableView.reloadRows(at: [indexPath], with: .right)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if album.manyArtists{
            return 54
        }else{
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 112
    }
    
    @IBAction func shufBtnPressed(_ sender: Any) {
        shuffleAll()
    }
    
    func cell(_ cell: QueueActionsCell, action: SongAction) {
        switch action {
        case .playNow:
            playNowBtn()
        case .playNext:
            playNextBtn()
        case.playLast:
            playLastBtn()
        }
    }
    
    func playNextBtn() {
        player.addNext(item: songs[absoluteIndex])
        cellTypes[activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow+1, section: 0)], with: .right)
    }
    func playLastBtn() {
        player.addLast(item: songs[absoluteIndex])
        cellTypes[activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow+1, section: 0)], with: .right)
    }
    func playNowBtn() {
        if(player.isUsrQueue){
            player.clearQueue()
        }
        if(player.isShuffle){
            player.disableShuffle()
            player.defIndex = absoluteIndex
            player.createDefQueue(items: songs)
            player.shuffleCurrent()
            player.playFromShufQueue(index: 0, new: true)
        }else{
            player.createDefQueue(items: songs)
            player.playFromDefQueue(index: absoluteIndex, new: true)
        }
        player.play()
        cellTypes[activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow+1, section: 0)], with: .right)
    }
    
    func artistBtn(){
        cellTypes[activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: self.activeIndexRow+1, section: 0)], with: .fade)
        performSegue(withIdentifier: "artist", sender: nil)
    }
    @objc func longPress(_ longPress: UIGestureRecognizer){
        if(cellTypes[activeIndexRow] == 1 || cellTypes[activeIndexRow] == 2){
            cellTypes[activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow+1, section: 0)], with: .left)
        }
        if longPress.state == .recognized{
            let touchPoint = longPress.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint){
                pickedArtistID = songs[activeIndexRow].albumArtistPersistentID
                self.cellTypes[activeIndexRow] = 2
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cellTypes[activeIndexRow] = 0
        let indexPath = IndexPath(row: activeIndexRow+1, section: 0)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func readSettings(){
        rating = GlobalSettings.rating
    }
    
    func shuffleAll() {
        player.createDefQueue(items: songs)
        player.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: true)
        player.play()
    }
}

extension AlbumVC: UITabBarControllerDelegate {
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
