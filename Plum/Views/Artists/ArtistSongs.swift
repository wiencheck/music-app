//
//  ArtistSongs.swift
//  Plum
//
//  Created by Adam Wienconek on 09.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistSongs: UIViewController {
    
    let player = Plum.shared
    var searchController: UISearchController!
    let defaults = UserDefaults.standard
    
    var typesSongs = [[Int]]()
    var typesAlbums = [[Int]]()
    var songs: [MPMediaItem]!
    var songsByAlbums: [MPMediaItem]!
    var albums: [AlbumB]!
    var sort: Sort!
    var receivedID: MPMediaEntityPersistentID!
    var sections: Int!
    var headers = [UIView]()
    var result = [String: [MPMediaItem]]()
    var indexes = [String]()
    var indexesInt = [Int]()
    
    var previousIndex = 0
    var absoluteIndex = 0
    var activeIndexRow = 0
    var activeIndexSection = 0
    
    @IBOutlet weak var upperBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alpIndexView: TableIndexView!
    @IBOutlet weak var albIndexView: TableIndexView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        sort = GlobalSettings.artistSort
        setup()
        
//        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
//        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        instruct("artistslider", message: "Slider on the right edge of the screen works even here!", completion: nil)
    }
    
    @IBAction func sortBtnPressed() {
        activeIndexRow = 0
        activeIndexSection = 0
        absoluteIndex = 0
        if sort == .album {
            sort = .alphabetically
            alpIndexView.isHidden = false
            albIndexView.isHidden = true
        }else{
            sort = .album
            alpIndexView.isHidden = true
            albIndexView.isHidden = false
        }
        GlobalSettings.changeArtistSort(sort)
        setup()
        tableView.reloadData()
    }
    
    @IBAction func shufBtnPressed() {
        
    }
    
    @IBAction func playBtnPressed() {
        
    }

}

extension ArtistSongs: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if sort == .alphabetically{
            return (result[indexes[section-1]]?.count)!
        }else{
            return (result[indexes[section]]?.count)! + 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sort == .album {
            if section == 0 {
                return UIView()
            }else{
                return headers[section-1]
            }
        }else{
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            if sort == .album {
                return 112
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }else{
            if sort == .album {
                if albums[indexPath.section-1].manyArtists {
                    return 54
                }else{
                    return 44
                }
            }else{
                return 62
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell", for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }else{
            if sort == .alphabetically {
                if typesSongs[indexPath.section-1][indexPath.row] == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
                    let item = result[indexes[indexPath.section-1]]?[indexPath.row]
                    cell.setup(item: item!)
                    cell.backgroundColor = .clear
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as! QueueActionsCell
                    cell.delegate = self
                    cell.backgroundColor = .clear
                    return cell
                }
            }else{
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell", for: indexPath)
                    cell.backgroundColor = .clear
                    return cell
                }else{
                    if typesAlbums[indexPath.section][indexPath.row-1] == 0 {
                        if albums[indexPath.section-1].manyArtists {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "extendedSongCell", for: indexPath) as! SongInAlbumCell
                            let item = result[indexes[indexPath.section]]?[indexPath.row-1]
                            cell.setupA(item: item!)
                            cell.backgroundColor = .clear
                            return cell
                        }else{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "albumSongCell", for: indexPath) as! SongInAlbumCell
                            let item = result[indexes[indexPath.section]]?[indexPath.row-1]
                            cell.setup(item: item!)
                            cell.backgroundColor = .clear
                            return cell
                        }
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as! QueueActionsCell
                        cell.delegate = self
                        cell.backgroundColor = .clear
                        return cell
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            shuffleAll()
        }else{
            if sort == .album {
                if typesAlbums[activeIndexSection][activeIndexRow] != 0 {
                    typesAlbums[activeIndexSection][activeIndexRow] = 0
                    tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
                }
                if indexPath.row == 0 {
                    let items = albums[indexPath.section-1].items
                    player.createDefQueue(items: items)
                    player.defIndex = Int(arc4random_uniform(UInt32(items.count)))
                    player.shuffleCurrent()
                    player.playFromShufQueue(index: 0, new: true)
                    player.play()
                }else{
                    activeIndexSection = indexPath.section
                    activeIndexRow = indexPath.row - 1
                    absoluteIndex = indexPath.absoluteRow(tableView) - indexPath.section - 1
                    if typesAlbums[activeIndexSection][activeIndexRow] == 0 {
                        if player.isPlayin() {
                            typesAlbums[activeIndexSection][activeIndexRow] = 1
                            tableView.reloadRows(at: [indexPath], with: .fade)
                        }else{
                            if player.isShuffle {
                                player.disableShuffle()
                                player.createDefQueue(items: songsByAlbums)
                                player.defIndex = absoluteIndex
                                player.shuffleCurrent()
                                player.playFromShufQueue(index: 0, new: true)
                            }else{
                                player.createDefQueue(items: songsByAlbums)
                                player.playFromDefQueue(index: absoluteIndex, new: true)
                            }
                            player.play()
                        }
                    }
                }
            }else{
                if typesSongs[activeIndexSection][activeIndexRow] != 0 {
                    typesSongs[activeIndexSection][activeIndexRow] = 0
                    tableView.reloadRows(at: [IndexPath(row: activeIndexRow,section: activeIndexSection)], with: .fade)
                }
                activeIndexRow = indexPath.row
                activeIndexSection = indexPath.section - 1
                absoluteIndex = indexPath.absoluteRow(tableView) - 1
                if typesSongs[activeIndexSection][activeIndexRow] == 0 {
                    if player.isPlayin() {
                        typesSongs[activeIndexSection][activeIndexRow] = 1
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }else{
                        if player.isShuffle {
                            player.disableShuffle()
                            player.createDefQueue(items: songs)
                            player.defIndex = activeIndexRow
                            player.shuffleCurrent()
                            player.playFromShufQueue(index: 0, new: true)
                        }else{
                            player.createDefQueue(items: songs)
                            player.playFromDefQueue(index: absoluteIndex, new: true)
                        }
                        player.play()
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ArtistSongs: UIGestureRecognizerDelegate, QueueCellDelegate {
    
    func cell(_ cell: QueueActionsCell, action: SongAction) {
        switch action {
        case .playNow:
            playNowBtn()
        case .playNext:
            playNextBtn()
        case.playLast:
            playLastBtn()
        }
        if sort == .album {
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow+1, section: activeIndexSection)], with: .right)
        }else{
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection+1)], with: .right)
        }
    }
    
    func playNextBtn() {
        if sort == .album{
            Plum.shared.addNext(item: songsByAlbums[absoluteIndex])
            typesAlbums[activeIndexSection][activeIndexRow] = 0
        }else{
            Plum.shared.addNext(item: songs[absoluteIndex])
            typesSongs[activeIndexSection][activeIndexRow] = 0
        }
    }
    func playLastBtn() {
        if sort == .album{
            Plum.shared.addLast(item: songsByAlbums[absoluteIndex])
            typesAlbums[activeIndexSection][activeIndexRow] = 0
        }else{
            Plum.shared.addLast(item: songs[absoluteIndex])
            typesSongs[activeIndexSection][activeIndexRow] = 0
        }
    }
    func playNowBtn() {
        if(Plum.shared.isUsrQueue){
            Plum.shared.clearQueue()
        }
        if(Plum.shared.isShuffle){
            Plum.shared.disableShuffle()
            Plum.shared.defIndex = absoluteIndex
            if sort == .alphabetically{
                Plum.shared.createDefQueue(items: songs)
                typesSongs[activeIndexSection][activeIndexRow] = 0
            }else{
                Plum.shared.createDefQueue(items: songsByAlbums)
                typesAlbums[activeIndexSection][activeIndexRow] = 0
            }
            Plum.shared.shuffleCurrent()
            Plum.shared.playFromShufQueue(index: 0, new: true)
        }else{
            if sort == .alphabetically{
                Plum.shared.createDefQueue(items: songs)
                typesSongs[activeIndexSection][activeIndexRow] = 0
            }else{
                Plum.shared.createDefQueue(items: songsByAlbums)
                typesAlbums[activeIndexSection][activeIndexRow] = 0
            }
            Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
        }
        Plum.shared.play()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if sort == .album{
            if typesAlbums[activeIndexSection][activeIndexRow] != 0 {
                typesAlbums[activeIndexSection][activeIndexRow] = 0
                let indexPath = IndexPath(row: activeIndexRow+1, section: activeIndexSection)
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }else{
            if typesSongs[activeIndexSection][activeIndexRow] != 0 {
                typesSongs[activeIndexSection][activeIndexRow] = 0
                let indexPath = IndexPath(row: activeIndexRow, section: 1)
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
}

extension ArtistSongs {
    
    func setup() {
        if sort == .alphabetically {
            result = [String: [MPMediaItem]]()
            songs = musicQuery.shared.songsByArtistID(artist: receivedID)
            upperBar.title = songs[0].albumArtist
            setupDict()
            typesSongs = [[Int]]()
            for index in indexes {
                typesSongs.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
            }
            sections = indexesInt.count
            alpIndexView.indexes = self.indexes
            alpIndexView.tableView = self.tableView
            alpIndexView.setup()
            albIndexView.isHidden = true
            alpIndexView.isHidden = false
        }else if sort == .album {
            result = [String: [MPMediaItem]]()
            albums = musicQuery.shared.artistAlbumsID(artist: receivedID)
            byAlbum()
            indexes.insert("Shuffle", at: 0)
            result["Shuffle"] = [MPMediaItem()]
            for index in indexes {
                typesAlbums.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
            }
            sections = albums.count
            songsByAlbums = [MPMediaItem]()
            for album in albums {
                songsByAlbums.append(contentsOf: album.items)
                let header = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! AlbumInfoCell
                header.setup(album: album, play: false)
//                let imv = UIImageView(frame: header.frame)
//                imv.contentMode = .scaleToFill
//                imv.image = #imageLiteral(resourceName: "background_se")
//                header.backgroundView = imv
//                let v = UIView()
//                v.addSubview(header)
//                v.layer.borderWidth = 0.5
//                v.layer.borderColor = tableView.separatorColor?.cgColor
                headers.append(header.contentView)
            }
            songs = songsByAlbums
            upperBar.title = songsByAlbums[0].albumArtist
            albIndexView.indexes = self.indexes
            albIndexView.tableView = self.tableView
            albIndexView.setup()
            albIndexView.isHidden = false
            alpIndexView.isHidden = true
        }
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        tableView.backgroundColor = UIColor(red: 0.968627450980392, green: 0.968627450980392, blue: 0.968627450980392, alpha: 1.0)
        //tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
        //tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func alphabetically() {
        let bcount = songs.count
        indexes = [String]()
        indexesInt = [Int]()
        if bcount > 11 {
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
        }else{
            indexesInt.append(0)
            indexes.append("A")
            result["A"] = []
            result["A"]?.append(contentsOf: songs)
        }
        
    }
    
    func setupDict() {
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        indexes = [String]()
        for song in songs {
            let objStr = song.title!
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = objStr.components(separatedBy: " ")[1]
                    if result["\(secondStr.first!)"] != nil {
                        result["\(secondStr.first!)"]?.append(song)
                    }else{
                        result["\(secondStr.uppercased().first!)"] = []
                        result["\(secondStr.uppercased().first!)"]?.append(song)
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
    
    func byAlbum() {
        indexes = [String]()
        indexesInt = [Int]()
        for album in albums {
            let name = album.name
            var word = (name?.components(separatedBy: " ").first)!
            if result[word] != nil {
                word += " "
                result[word] = []
                result[word]?.append(contentsOf: album.items)
                indexes.append(word)
                //result[word]?.append(contentsOf: album.items)
            }else{
                result[word] = []
                result[word]?.append(contentsOf: album.items)
                indexes.append(word)
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
    
    func shuffleAll() {
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        Plum.shared.shuffleCurrent()
        Plum.shared.playFromShufQueue(index: 0, new: true)
        Plum.shared.play()
    }
}

extension ArtistSongs: UITabBarControllerDelegate {
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
