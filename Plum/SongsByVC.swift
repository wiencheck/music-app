//
//  SongsByArtistVC.swift
//  myPlayer
//
//  Created by Adam Wienconek on 31.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SongsByVC: UITableViewController, UIGestureRecognizerDelegate, QueueCellDelegate, MoreActionsCellDelegate {
    var cellTypes = [Int: [Int]]()
    var cellTypesAl = [Int]()
    var songs = [MPMediaItem]()
    var songsByAlbums = [MPMediaItem]()
    var receivedID: MPMediaEntityPersistentID!
    var pickedID: MPMediaEntityPersistentID!
    var previousIndex = 0
    var absoluteIndex = 0
    var activeIndexRow = 0
    var activeIndexSection = 0
    @IBOutlet weak var upperBar: UINavigationItem!
    @IBOutlet weak var sortBtn: UIButton!
    var albums = [AlbumB]()
    var result = [String: [AlbumB]]()
    var indexes = [String]()
    var alphabeticalSort: Bool = false
    var chosenItem: MPMediaItem!
    var headers = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        alphabeticalSort = GlobalSettings.alphabeticalSort
        albums = musicQuery.shared.artistAlbumsID(artist: receivedID)
        songs = musicQuery.shared.songsByArtistID(artist: receivedID)
        for album in albums{
            songsByAlbums.append(contentsOf: album.items)
        }
        upperBar.title = "\(songs.count) Songs"
        var iterator = 0
        for album in 0 ..< albums.count{
            cellTypes[iterator] = []
            cellTypes[iterator] = Array<Int>(repeating: 0, count: albums[album].songsIn)
            let header = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! AlbumInfoCell
            header.setup(album: albums[album], play: false)
            header.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
            let v = UIView()
            v.addSubview(header)
            v.layer.borderWidth = 0.5
            v.layer.borderColor = tableView.separatorColor?.cgColor
            headers.append(v)
            iterator += 1
        }
        iterator += 1
        cellTypes[iterator] = []
        cellTypesAl = Array<Int>(repeating: 0, count: songs.count)
        let backround = #imageLiteral(resourceName: "background_se")
        self.tableView.backgroundView = UIImageView(image: backround)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if alphabeticalSort{
            if cellTypesAl[indexPath.row] != 0{
                return nil
            }else{
                return indexPath
            }
        }else{
            if cellTypes[indexPath.section]?[indexPath.row] != 0{
                return nil
            }else{
                return indexPath
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if !alphabeticalSort{
            return albums.count
        }else{
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !alphabeticalSort{
            return albums[section].songsIn
        }else{
            return songs.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !alphabeticalSort{
//            let header = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! AlbumInfoCell
//            header.setup(album: albums[section], play: false)
//            header.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
//            header.layer.borderWidth = 0.7
//            header.layer.borderColor = tableView.separatorColor?.cgColor
//            return header
            return headers[section]
        }else{
            /*let header = tableView.dequeueReusableCell(withIdentifier: "letterCell")
            header?.textLabel?.text = indexes[section]
            header?.backgroundColor = .blue
            return header*/
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if alphabeticalSort{
            return 0
        }else{
            return 112
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        absoluteIndex = indexPath.absoluteRow(tableView)
        if !alphabeticalSort{
            if(cellTypes[indexPath.section]?[indexPath.row] == 0){
                if albums[indexPath.section].manyArtists{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "extendedSongCell", for: indexPath) as? SongInAlbumCell
                    let item = songsByAlbums[absoluteIndex]
                    if(item != Plum.shared.currentItem){
                        cell?.setupA(item: item)
                    }else{
                        cell?.setupA(item: item)
                    }
                    cell?.backgroundColor = .clear
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "albumSongCell", for: indexPath) as? SongInAlbumCell
                    let item = songsByAlbums[absoluteIndex]
                    if(item != Plum.shared.currentItem){
                        cell?.setup(item: item)
                    }else{
                        cell?.setup(item: item)
                    }
                    cell?.backgroundColor = .clear
                    return cell!
                }
            }else if cellTypes[indexPath.section]?[indexPath.row] == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
                cell?.delegate = self
                cell?.backgroundColor = .clear
                return cell!
            }else{
                return UITableViewCell()
            }
        }else{
            if(cellTypesAl[absoluteIndex] == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
                let item = songs[indexPath.row]
                if(item != Plum.shared.currentItem){
                    cell?.setup(item: item)
                }else{
                    cell?.setup(item: item)
                }
                cell?.backgroundColor = .clear
                return cell!
            }else if cellTypesAl[absoluteIndex] == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
                cell?.delegate = self
                cell?.backgroundColor = .clear
                return cell!
            }else{
                return UITableViewCell()
            }

        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //42 52
        if !alphabeticalSort{
            if albums[indexPath.section].manyArtists{
                return 54
            }else{
                return 50
            }
        }else{
            return 62
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !alphabeticalSort{
            if(cellTypes[activeIndexSection]?[activeIndexRow] == 1){
                cellTypes[activeIndexSection]?[activeIndexRow] = 0
                tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
            }
            activeIndexSection = indexPath.section
            absoluteIndex = indexPath.absoluteRow(tableView)
            activeIndexRow = indexPath.row
            if(cellTypes[indexPath.section]?[indexPath.row] == 0){
                if(Plum.shared.isPlayin()){
                    pickedID = songsByAlbums[absoluteIndex].albumPersistentID
                    cellTypes[indexPath.section]?[indexPath.row] = 1
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }else{
                    if(Plum.shared.isShuffle){
                        Plum.shared.disableShuffle()
                        Plum.shared.createDefQueue(items: songsByAlbums)
                        Plum.shared.defIndex = absoluteIndex
                        Plum.shared.shuffleCurrent()
                        Plum.shared.playFromShufQueue(index: 0, new: true)
                    }else{
                        Plum.shared.createDefQueue(items: songsByAlbums)
                        Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
                    }
                    Plum.shared.play()
                }
            }else{
                cellTypes[indexPath.section]?[indexPath.row] = 0
                tableView.reloadRows(at: [indexPath], with: .right)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }else{
            if(cellTypesAl[activeIndexRow] == 1){
                cellTypesAl[activeIndexRow] = 0
                tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: 0)], with: .fade)
            }
            activeIndexRow = indexPath.row
            activeIndexSection = 0
            absoluteIndex = indexPath.absoluteRow(tableView)
            
            if(cellTypesAl[activeIndexRow] == 0){
                if(Plum.shared.isPlayin()){
                    pickedID = songsByAlbums[absoluteIndex].albumPersistentID
                    cellTypesAl[activeIndexRow] = 1
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }else{
                    if(Plum.shared.isShuffle){
                        Plum.shared.disableShuffle()
                        Plum.shared.createDefQueue(items: songs)
                        Plum.shared.defIndex = activeIndexRow
                        Plum.shared.shuffleCurrent()
                        Plum.shared.playFromShufQueue(index: 0, new: true)
                    }else{
                        Plum.shared.createDefQueue(items: songs)
                        Plum.shared.playFromDefQueue(index: activeIndexRow, new: true)
                    }
                    Plum.shared.play()
                }
            }else{
                cellTypes[indexPath.section]?[indexPath.row] = 0
                tableView.reloadRows(at: [indexPath], with: .right)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func NPBtnPressed(_ sender: Any) {
    }
    
    @IBAction func sortBtnPressed(_ sender: Any){
        activeIndexRow = 0
        activeIndexSection = 0
        absoluteIndex = 0
        if alphabeticalSort{
            alphabeticalSort = false
        }else{
            alphabeticalSort = true
        }
        GlobalSettings.changeAlphabeticalSort(alphabeticalSort)
        UserDefaults.standard.set(alphabeticalSort, forKey: "alphabeticalSort")
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedID
        }
    }
    
    func playNextBtn() {
        if !alphabeticalSort{
            Plum.shared.addNext(item: songsByAlbums[absoluteIndex])
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
        }else{
            Plum.shared.addNext(item: songs[absoluteIndex])
            cellTypesAl[activeIndexRow] = 0
        }
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func playLastBtn() {
        if !alphabeticalSort{
            Plum.shared.addLast(item: songsByAlbums[absoluteIndex])
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
        }else{
            Plum.shared.addLast(item: songs[absoluteIndex])
            cellTypesAl[activeIndexRow] = 0
        }
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func playNowBtn() {
        if(Plum.shared.isUsrQueue){
            Plum.shared.clearQueue()
        }
        if(Plum.shared.isShuffle){
            Plum.shared.disableShuffle()
            Plum.shared.defIndex = absoluteIndex
            if alphabeticalSort{
                Plum.shared.createDefQueue(items: songs)
                cellTypesAl[activeIndexRow] = 0
            }else{
                Plum.shared.createDefQueue(items: songsByAlbums)
                cellTypes[activeIndexSection]?[activeIndexRow] = 0
            }
            Plum.shared.shuffleCurrent()
            Plum.shared.playFromShufQueue(index: 0, new: true)
        }else{
            if alphabeticalSort{
                Plum.shared.createDefQueue(items: songs)
                cellTypesAl[activeIndexRow] = 0
            }else{
                Plum.shared.createDefQueue(items: songsByAlbums)
                cellTypes[activeIndexSection]?[activeIndexRow] = 0
            }
            Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
        }
        Plum.shared.play()
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == tableView.numberOfSections - 1 {
            let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.1))
            v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.3)
            return v
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 0.1
        }else{
            return 0
        }
    }

    func albumBtn(){
        if alphabeticalSort{
            cellTypesAl[activeIndexRow] = 0
        }else{
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
        }
        self.tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .none)
        performSegue(withIdentifier: "album", sender: nil)
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
    
    func cell(_ cell: MoreActionsCell, action: MoreActions){
        albumBtn()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !alphabeticalSort{
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
        }else{
            cellTypesAl[activeIndexRow] = 0
        }
        let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func longPress(_ longPress: UIGestureRecognizer){
        if(cellTypes[activeIndexSection]?[activeIndexRow] == 1){
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .left)
        }
        if longPress.state == .recognized{
            let touchPoint = longPress.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint){
                activeIndexSection = indexPath.section
                activeIndexRow = indexPath.row
                self.cellTypes[activeIndexSection]?[activeIndexRow] = 2
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
}
