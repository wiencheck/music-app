//
//  AlbumVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 18.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumVC: UITableViewController, QueueCellDelegate, UIGestureRecognizerDelegate, InfoCellDelegate {
    
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
    var color = false
    var backgroundColor: UIColor!
    var mainLabel: UIColor!
    var detailLabel: UIColor!
    @IBOutlet weak var themeBtn: UIBarButtonItem!
    //@IBOutlet var ratingBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
        tableView.delaysContentTouches = false
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
        title = album.artist
        tableView.tableFooterView = UIView(frame: .zero)
        updateTheme()
    }
    
//    @IBAction func ratingPressed() {
//        GlobalSettings.changeRating(!GlobalSettings.rating)
//        if GlobalSettings.rating {
//            ratingBtn.image = #imageLiteral(resourceName: "star")
//        }else{
//            ratingBtn.image = #imageLiteral(resourceName: "no_star")
//        }
//        tableView.reloadData()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if !GlobalSettings.ratingsIn {
//            ratingBtn.image = nil
//            ratingBtn.title = ""
//            ratingBtn.isEnabled = false
//        }else{
//            ratingBtn.isEnabled = true
//            if GlobalSettings.rating {
//                ratingBtn.image = #imageLiteral(resourceName: "star")
//            }else{
//                ratingBtn.image = #imageLiteral(resourceName: "no_star")
//            }
//        }
        tableView.reloadData()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell", for: indexPath) as! ShuffleCell
            cell.setup(style: .light)
            cell.label.textColor = UIColor.mainLabel
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
                    return cell!
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
                    cell?.delegate = self
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
                    return cell!
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
                    cell?.delegate = self
                    return cell!
                }
            }
        }
    }
    
    func playPressed() {
        print("Should play")
        Plum.shared.isShuffle = false
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! AlbumInfoCell
        header.setup(album: album, play: true)
        header.delegate = self
        header.backgroundColor = UIColor.background
        for current in header.subviews {
            if current .isKind(of: UIScrollView.self) {
                (current as! UIScrollView).delaysContentTouches = false
            }
        }
        let v = header.contentView
        //v.addBottomBorderWithColor(color: UIColor.separator, width: 0.5, x: 14)
        return v
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellTypes[activeIndexRow] != 0 {
            cellTypes[activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow+1, section: 0)], with: .fade)
        }
        
        if indexPath.row == 0 {
            shuffleAll()
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
        performSegue(withIdentifier: "artist", sender: nil)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cellTypes[activeIndexRow] = 0
        let indexPath = IndexPath(row: activeIndexRow+1, section: 0)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func shuffleAll() {
        player.createDefQueue(items: songs)
        player.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        player.shuffleCurrent()
        player.playFromShufQueue(index: 0, new: true)
        player.play()
    }
    
    @IBAction func themeBtnPressed(_ sender: UIBarButtonItem) {
        if GlobalSettings.theme == .dark {
            GlobalSettings.changeTheme(.light)
        }else{
            GlobalSettings.changeTheme(.dark)
        }
    }
    
    @objc func updateTheme() {
        if color {
            guard let art = songs.first!.artwork?.image(at: CGSize(width: 300, height: 300)) else { return }
            let _ = art.getColors()
            
        }else{
            if GlobalSettings.theme == .dark {
                navigationController?.navigationBar.barStyle = .blackTranslucent
                themeBtn.image = #imageLiteral(resourceName: "dark_bar")
                navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            }else{
                navigationController?.navigationBar.barStyle = .default
                themeBtn.image = #imageLiteral(resourceName: "light_bar")
                navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            }
            tableView.backgroundColor = UIColor.background
            tableView.separatorColor = UIColor.separator
            //ratingBtn.tintColor = GlobalSettings.tint.color
        }
        tableView.reloadData()
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
