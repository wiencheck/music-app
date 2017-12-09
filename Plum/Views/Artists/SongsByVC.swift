//
//  SongsByArtistVC.swift
//  myPlayer
//
//  Created by Adam Wienconek on 31.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//
/*
import UIKit
import MediaPlayer

class SongsByVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, QueueCellDelegate, MoreActionsCellDelegate {
    
    var sort: Sort!
    var cellTypes = [[Int]]()
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
    @IBOutlet weak var sortBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indexView: TableIndexView!
    var albums = [AlbumB]()
    var result = [String: [AlbumB]]()
    var resultB = [String: [MPMediaItem]]()
    var indexes = [String]()
    var indexesInt = [Int]()
    var alphabeticalSort: Bool = false
    var chosenItem: MPMediaItem!
    var headers = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        alphabeticalSort = GlobalSettings.alphabeticalSort
        albums = musicQuery.shared.artistAlbumsID(artist: receivedID)
        songs = musicQuery.shared.songsByArtistID(artist: receivedID)
        sort = .alphabetically
        sortAlbums()
        for album in albums{
            songsByAlbums.append(contentsOf: album.items)
        }
        setup()
        upperBar.title = "\(songs.count) Songs"
        var iterator = 0
        for album in 0 ..< albums.count{
            cellTypes.append(Array<Int>(repeating: 0, count: albums[album].songsIn))
            let header = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! AlbumInfoCell
            header.setup(album: albums[album], play: false)
            let imv = UIImageView(frame: header.frame)
            imv.contentMode = .scaleAspectFill
            imv.image = #imageLiteral(resourceName: "background_se")
            header.backgroundView = imv
            let v = UIView()
            v.addSubview(header)
            v.layer.borderWidth = 0.5
            v.layer.borderColor = tableView.separatorColor?.cgColor
            headers.append(v)
            iterator += 1
        }
        iterator += 1
        cellTypes.append(Array<Int>(repeating: 0, count: 1))
        cellTypesAl = Array<Int>(repeating: 0, count: songs.count)
        let backround = #imageLiteral(resourceName: "background_se")
        self.tableView.backgroundView = UIImageView(image: backround)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
     func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if alphabeticalSort{
            if cellTypesAl[indexPath.row] != 0{
                return nil
            }else{
                return indexPath
            }
        }else{
            if cellTypes[indexPath.section][indexPath.row] != 0{
                return nil
            }else{
                return indexPath
            }
        }
    }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

     func numberOfSections(in tableView: UITableView) -> Int {
        if !alphabeticalSort{
            return albums.count
        }else{
            return 1
        }
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !alphabeticalSort{
            return albums[section].songsIn
        }else{
            return songs.count
        }
    }
    
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !alphabeticalSort{
            return headers[section]
        }else{
            return UIView()
        }
    }
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if alphabeticalSort{
            return 0
        }else{
            return 112
        }
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        absoluteIndex = indexPath.absoluteRow(tableView)
        if !alphabeticalSort{
            if(cellTypes[indexPath.section][indexPath.row] == 0){
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
            }else if cellTypes[indexPath.section][indexPath.row] == 1{
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
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !alphabeticalSort{
            if albums[indexPath.section].manyArtists{
                return 54
            }else{
                return 44
            }
        }else{
            return 62
        }
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !alphabeticalSort{
            if(cellTypes[activeIndexSection][activeIndexRow] == 1){
                cellTypes[activeIndexSection][activeIndexRow] = 0
                tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
            }
            activeIndexSection = indexPath.section
            absoluteIndex = indexPath.absoluteRow(tableView)
            activeIndexRow = indexPath.row
            if(cellTypes[indexPath.section][indexPath.row] == 0){
                if(Plum.shared.isPlayin()){
                    pickedID = songsByAlbums[absoluteIndex].albumPersistentID
                    cellTypes[indexPath.section][indexPath.row] = 1
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
                cellTypes[indexPath.section][indexPath.row] = 0
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
                cellTypes[indexPath.section][indexPath.row] = 0
                tableView.reloadRows(at: [indexPath], with: .right)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func NPBtnPressed(_ sender: Any) {
    }
    
    @IBAction func sortBtnPressed(_ sender: Any){
        print("sort")
        activeIndexRow = 0
        activeIndexSection = 0
        absoluteIndex = 0
        alphabeticalSort = !alphabeticalSort
        GlobalSettings.changeAlphabeticalSort(alphabeticalSort)
        UserDefaults.standard.set(alphabeticalSort, forKey: "alphabeticalSort")
        tableView.reloadData()
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.receivedID = pickedID
        }
    }
    
    func playNextBtn() {
        if !alphabeticalSort{
            Plum.shared.addNext(item: songsByAlbums[absoluteIndex])
            cellTypes[activeIndexSection][activeIndexRow] = 0
        }else{
            Plum.shared.addNext(item: songs[absoluteIndex])
            cellTypesAl[activeIndexRow] = 0
        }
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    func playLastBtn() {
        if !alphabeticalSort{
            Plum.shared.addLast(item: songsByAlbums[absoluteIndex])
            cellTypes[activeIndexSection][activeIndexRow] = 0
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
                cellTypes[activeIndexSection][activeIndexRow] = 0
            }
            Plum.shared.shuffleCurrent()
            Plum.shared.playFromShufQueue(index: 0, new: true)
        }else{
            if alphabeticalSort{
                Plum.shared.createDefQueue(items: songs)
                cellTypesAl[activeIndexRow] = 0
            }else{
                Plum.shared.createDefQueue(items: songsByAlbums)
                cellTypes[activeIndexSection][activeIndexRow] = 0
            }
            Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
        }
        Plum.shared.play()
        tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
    }
    
     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == tableView.numberOfSections - 1 {
            let v = UIView(frame: CGRect(x: 5, y: 0, width: 40, height: 0.1))
            v.backgroundColor = tableView.separatorColor?.withAlphaComponent(0.3)
            return v
        }else{
            return nil
        }
    }
    
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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
            cellTypes[activeIndexSection][activeIndexRow] = 0
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
    
     func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !alphabeticalSort{
           if cellTypes[activeIndexSection][activeIndexRow] != 0 {
                cellTypes[activeIndexSection][activeIndexRow] = 0
                let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection)
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }else{
            if cellTypesAl[activeIndexRow] != 0 {
                cellTypesAl[activeIndexRow] = 0
                let indexPath = IndexPath(row: activeIndexRow, section: 0)
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func longPress(_ longPress: UIGestureRecognizer){
        if(cellTypes[activeIndexSection][activeIndexRow] == 1){
            cellTypes[activeIndexSection][activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .left)
        }
        if longPress.state == .recognized{
            let touchPoint = longPress.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint){
                activeIndexSection = indexPath.section
                activeIndexRow = indexPath.row
                self.cellTypes[activeIndexSection][activeIndexRow] = 2
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func sortAlbums() {
        switch sort {
        case .alphabetically:
            albums.sort { $0.name! < $1.name! }
        case .yearAscending:
            albums.sort { Int($0.year)! < Int($1.year)! }
        case .yearDescending:
            albums.sort { Int($0.year)! > Int($1.year)! }
        default:
            print("sortAlbums default")
        }
    }
    
    func setup() {
        let bcount = songs.count
        if bcount > 11 {
            let difference: Int = bcount / 12
            var index = difference
            indexes.append("#1")
            indexesInt.append(1)
            while index < bcount {
                indexes.append("#\(index)")
                indexesInt.append(index)
                index += difference
            }
            indexView.indexes = self.indexes
            indexView.tableView = self.tableView
            indexView.setup()
            //view.addSubview(indexView)
        }
    }
}
 */
