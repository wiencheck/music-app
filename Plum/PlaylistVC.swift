//
//  PlaylistVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 02.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistVC: UIViewController, UIGestureRecognizerDelegate {
    
    var indexes = [String]()
    var result = [String: [MPMediaItem]]()
    var songs: [MPMediaItem]!
    var indexesInt = [Int]()
    var cellTypes = [Int: [Int]]()
    var absoluteIndex = 0
    var activeIndexRow = 0
    var activeIndexSection = 0
    
    var receivedID: MPMediaEntityPersistentID!
    var pickedAlbumID: MPMediaEntityPersistentID!
    var pickedArtistID: MPMediaEntityPersistentID!
    var playlist: Playlist!
    var receivedList: Playlist!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upperBar: UINavigationItem!
    @IBOutlet weak var tableIndexView: TableIndexView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        upperBar.title = receivedList.name
        setTable()
    }
    
    func setTable(){
        self.tableView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        self.tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        setup()
        var iterator = 0
        for index in indexes{
            cellTypes[iterator] = []
            for _ in 0 ..< (result[index]?.count)!{
                cellTypes[iterator]?.append(0)
            }
            iterator += 1
        }
        tableIndexView.indexes = self.indexes
        tableIndexView.tableView = self.tableView
        
        tableIndexView.setup()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PlaylistVC.longPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        self.tableView.addGestureRecognizer(longPress)
        self.view.addSubview(tableIndexView)
    }

}

extension PlaylistVC: UITableViewDelegate, UITableViewDataSource, QueueCellDelegate, MoreActionsCellDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexesInt.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        absoluteIndex = indexPath.absoluteRow(tableView)
        if(cellTypes[indexPath.section]?[indexPath.row] == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
            let item = result[indexes[indexPath.section]]?[indexPath.row]
            if(item != Plum.shared.currentItem){
                cell?.setup(item: item!)
            }else{
                cell?.setup(item: item!)
            }
            cell?.backgroundColor = .clear
            return cell!
        }else if cellTypes[indexPath.section]?[indexPath.row] == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as? QueueActionsCell
            cell?.delegate = self
            cell?.backgroundColor = .clear
            return cell!
        }else if cellTypes[indexPath.section]?[indexPath.row] == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath) as? MoreActionsCell
            cell?.delegate = self
            cell?.backgroundColor = .clear
            return cell!
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(cellTypes[activeIndexSection]?[activeIndexRow] == 1 || cellTypes[activeIndexSection]?[activeIndexRow] == 2){
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
        }
        activeIndexRow = indexPath.row
        activeIndexSection = indexPath.section
        absoluteIndex = indexPath.absoluteRow(tableView)
        
        if(cellTypes[indexPath.section]?[indexPath.row] == 0){
            if(Plum.shared.isPlayin()){
                cellTypes[indexPath.section]?[indexPath.row] = 1
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
            cellTypes[indexPath.section]?[indexPath.row] = 0
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
    
    func cell(_ cell: MoreActionsCell, action: MoreActions){
        switch action {
        case .album:
            albumBtn()
        case .artist:
            artistBtn()
        }
    }
    
    func playNextBtn() {
        Plum.shared.addNext(item: songs[absoluteIndex])
        cellTypes[activeIndexSection]?[activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func playLastBtn() {
        Plum.shared.addLast(item: songs[absoluteIndex])
        cellTypes[activeIndexSection]?[activeIndexRow] = 0
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
        cellTypes[activeIndexSection]?[activeIndexRow] = 0
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func albumBtn(){
        cellTypes[activeIndexSection]?[activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
        performSegue(withIdentifier: "album", sender: nil)
    }
    func artistBtn(){
        cellTypes[activeIndexSection]?[activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: self.activeIndexRow, section: activeIndexSection)], with: .fade)
        if musicQuery.shared.artistAlbumsID(artist: (result[indexes[activeIndexSection]]?[activeIndexRow].albumArtistPersistentID)!).count == 1 {
            performSegue(withIdentifier: "album", sender: nil)
        }else{
            performSegue(withIdentifier: "artist", sender: nil)
        }
    }
    @objc func longPress(_ longPress: UIGestureRecognizer){
        if(cellTypes[activeIndexSection]?[activeIndexRow] == 1 || cellTypes[activeIndexSection]?[activeIndexRow] == 2){
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .left)
        }
        if longPress.state == .recognized{
            let touchPoint = longPress.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint){
                activeIndexSection = indexPath.section
                activeIndexRow = indexPath.row
                print("held \(result[indexes[activeIndexSection]]?[activeIndexRow].title)")
                pickedAlbumID = result[indexes[activeIndexSection]]?[activeIndexRow].albumPersistentID
                pickedArtistID = result[indexes[activeIndexSection]]?[activeIndexRow].albumArtistPersistentID
                self.cellTypes[activeIndexSection]?[activeIndexRow] = 2
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cellTypes[activeIndexSection]?[activeIndexRow] = 0
        let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }

    
    func setup(){
        songs = receivedList.items
        let bcount = receivedList.songsIn
        let difference: Int = bcount / 12
        var index = difference
        indexes.append("#1")
        indexesInt.append(1)
        while index < bcount{
            indexes.append("#\(index)")
            indexesInt.append(index)
            index += difference
        }
        var stoppedAt = 0
        for i in 0 ..< indexes.count{
            result[indexes[i]] = []
            for j in stoppedAt ..< bcount{
                if j > indexesInt[i]{
                    stoppedAt = j
                    break
                }
                result[indexes[i]]?.append(songs[j])
            }
        }
    }
}
