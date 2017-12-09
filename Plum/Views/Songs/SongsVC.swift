//
//  SongsVC.swift
//  myPlayer
//
//  Created by Adam Wienconek on 31.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer
import LNPopupController

class SongsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, QueueCellDelegate {
    var cellTypes = [[Int]]()
    var indexes = [String]()
    var songs = [MPMediaItem]()
    var result = [String: [MPMediaItem]]()
    var absoluteIndex = 0
    var activeIndexRow = 0
    var activeIndexSection = 0
    let defaults = UserDefaults.standard
    var pickedAlbumID: MPMediaEntityPersistentID!
    var pickedArtistID: MPMediaEntityPersistentID!
    
    let backround = #imageLiteral(resourceName: "background_se")
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indexView: TableIndexView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        tableView.delegate = self
        tableView.dataSource = self
        setupDict()
        print(songs.count)
        for index in indexes {
            cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
        }
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
        tableView.backgroundView = UIImageView(image: backround)
        //view.addSubview(tableView)
        indexView.indexes = self.indexes
        indexView.tableView = self.tableView
        indexView.setup()
        view.addSubview(indexView)
    }
    
    deinit {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return result.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexes[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if cellTypes[indexPath.section][indexPath.row] != 0{
            return nil
        }else{
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let album = UITableViewRowAction(style: .default, title: "Album", handler: {_,path in
            let item = self.result[self.indexes[path.section]]?[path.row]
            self.pickedAlbumID = item?.albumPersistentID
            self.albumBtn()
        })
        album.backgroundColor = .albumGreen
        let artist = UITableViewRowAction(style: .default, title: "Artist", handler: {_,path in
            let item = self.result[self.indexes[path.section]]?[path.row]
            self.pickedArtistID = item?.albumArtistPersistentID
            self.pickedAlbumID = item?.albumPersistentID
            self.artistBtn()
        })
        artist.backgroundColor = .artistBlue
        return [album, artist]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        absoluteIndex = indexPath.absoluteRow(tableView)
        if(cellTypes[indexPath.section][indexPath.row] == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
                let item = result[indexes[indexPath.section]]?[indexPath.row]
                if(item != Plum.shared.currentItem){
                    cell?.setup(item: item!)
                }else{
                    cell?.setup(item: item!)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellTypes[activeIndexSection][activeIndexRow] != 0 {
            cellTypes[activeIndexSection][activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
        }
        activeIndexRow = indexPath.row
        activeIndexSection = indexPath.section
        absoluteIndex = indexPath.absoluteRow(tableView)
        print("Absolute index = \(absoluteIndex)")
        print(result[indexes[indexPath.section]]![indexPath.row].title)
        if(cellTypes[indexPath.section][indexPath.row] == 0){
            if(Plum.shared.isPlayin()){
                cellTypes[indexPath.section][indexPath.row] = 1
                tableView.reloadRows(at: [indexPath], with: .fade)
            }else{
                if(Plum.shared.isShuffle){
                    Plum.shared.disableShuffle()
                    Plum.shared.createDefQueue(items: songs)
                    Plum.shared.defIndex = absoluteIndex
                    Plum.shared.shuffleCurrent()
                    Plum.shared.playFromShufQueue(index: 0, new: true)
                }else{
                    Plum.shared.createDefQueue(items: songs)
                    Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
                }
                Plum.shared.play()
            }
        }else{
            cellTypes[indexPath.section][indexPath.row] = 0
            tableView.reloadRows(at: [indexPath], with: .right)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func NPBtnPressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedAlbumID
        }else if let destination = segue.destination as? AlbumsByVC{
            destination.receivedID = pickedArtistID
        }else if let destination = segue.destination as? ArtistSongs {
            destination.receivedID = pickedArtistID
        }
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
        Plum.shared.addNext(item: songs[absoluteIndex])
        cellTypes[activeIndexSection][activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func playLastBtn() {
        Plum.shared.addLast(item: songs[absoluteIndex])
        cellTypes[activeIndexSection][activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func playNowBtn() {
        if(Plum.shared.isUsrQueue){
            Plum.shared.clearQueue()
        }
        if(Plum.shared.isShuffle){
            Plum.shared.disableShuffle()
            Plum.shared.defIndex = absoluteIndex
            Plum.shared.createDefQueue(items: songs)
            Plum.shared.shuffleCurrent()
            Plum.shared.playFromShufQueue(index: 0, new: true)
            }else{
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
            }
        Plum.shared.play()
        cellTypes[activeIndexSection][activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func albumBtn(){
        cellTypes[activeIndexSection][activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
        performSegue(withIdentifier: "album", sender: nil)
    }
    func artistBtn(){
        cellTypes[activeIndexSection][activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: self.activeIndexRow, section: activeIndexSection)], with: .fade)
        performSegue(withIdentifier: "artist", sender: nil)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cellTypes[activeIndexSection][activeIndexRow] = 0
        let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension SongsVC {
    
    func setupDict() {
        songs = musicQuery.shared.songs
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for song in songs {
            let objStr = song.title!
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if result["\(secondStr.first!)"] != nil {
                        result["\(secondStr.first!)"]?.append(song)
                    }else{
                        result.updateValue([song], forKey: "\(secondStr.first!)")
                        indexes.append("\(secondStr.uppercased().first!)")
                    }
                }
            }else{
                let prefix = "\(article.first!)".uppercased()
                if Int(prefix) != nil {
                    if result["#"] != nil {
                        result["#"]?.append(song)
                    }else{
                        result.updateValue([song], forKey: "#")
                        anyNumber = true
                    }
                }else if prefix.firstSpecial() {
                    if result["?"] != nil {
                        result["?"]?.append(song)
                    }else{
                        result.updateValue([song], forKey: "?")
                        anySpecial = true
                    }
                }else if result[prefix] != nil {
                    result[prefix]?.append(song)
                }else{
                    result.updateValue([song], forKey: prefix)
                    indexes.append(prefix)
                }
            }
        }
        //indexes = Array(result.keys).sorted(by: <)
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
        //songs = result.flatMap(){ $0.1 }
    }
}

extension String {
    func firstSpecial() -> Bool {
        if prefix(1).rangeOfCharacter(from: NSCharacterSet.alphanumerics.inverted) != nil {
            return true
        }else{
            return false
        }
    }
    
    func firstNumber() -> Bool {
        return Int(prefix(1)) != nil
    }
}

public extension LazyMapCollection  {
    
    func toArray() -> [Element]{
        return Array(self)
    }
}
