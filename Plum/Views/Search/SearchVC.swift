//
//  SearchVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 24.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating, QueueCellDelegate {
    
    enum Content {
        case song
        case album
        case artist
    }
    
    let player = Plum.shared
    var titles = ["Artists", "Albums", "Songs", "Playlists"]
    @IBOutlet weak var tableView: UITableView!
    var songs: [MPMediaItem]?
    var filteredSongs: [MPMediaItem]?
    var shouldCompactSongs: Bool!
    var artists: [Artist]?
    var filteredArtists: [Artist]?
    var shouldCompactArtists: Bool!
    var albums: [AlbumB]?
    var filteredAlbums: [AlbumB]?
    var playlists: [Playlist]?
    var shouldCompactAlbums: Bool!
    var searchController: UISearchController!
    var shouldShowResults: Bool!
    var pickedAlbum: AlbumB!
    var pickedArtistID: MPMediaEntityPersistentID!
    var pickedSong: MPMediaItem!
    var searchHistory: [String]!
    var headers = [UIView]()
    var cellTypes = [Int]()
    var activeRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        searchHistory = UserDefaults.standard.array(forKey: "searchHistory") as! [String]
        loadArrays()
        configureSearchController()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        shouldShowResults = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchHistory = UserDefaults.standard.array(forKey: "searchHistory") as! [String]
        searchController.isActive = true
        delay(0.1) {
            self.searchController.searchBar.becomeFirstResponder()
            UIApplication.shared.sendAction(#selector(self.selectAll(_:)), to: nil, from: nil, for: nil)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowResults{
            return 3
        }else{
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            if section == 0 {
                if (filteredArtists?.count)! > 3 && shouldCompactArtists {
                    return 3
                }else{
                    return (filteredArtists?.count)!
                }
            }else if section == 1 {
                if (filteredAlbums?.count)! > 3 && shouldCompactAlbums {
                    return 3
                }else{
                    return (filteredAlbums?.count)!
                }
            }else if section == 2 {
                if (filteredSongs?.count)! > 3 && shouldCompactSongs {
                    return 3
                }else{
                    return (filteredSongs?.count)!
                }
            }else{
                return 0
            }
        }else{
            return searchHistory.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if shouldShowResults {
            if section == 0 && filteredArtists?.count != 0{
                return 26
            }else if section == 1 && filteredAlbums?.count != 0{
                return 26
            }else if section == 2 && filteredSongs?.count != 0{
                return 26
            }else{
                return 0
            }
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldShowResults{
            let header = tableView.dequeueReusableCell(withIdentifier: "header") as! SearchHeader
            if tableView.numberOfRows(inSection: section) == 0{
                return nil
            }
            if section == 0 && filteredArtists?.count != 0{
                header.setup(title: "artists", count: (filteredArtists?.count)!)
            }else if section == 1 && filteredAlbums?.count != 0{
                header.setup(title: "albums", count: (filteredAlbums?.count)!)
            }else if section == 2 && filteredSongs?.count != 0{
                header.setup(title: "songs", count: (filteredSongs?.count)!)
            }else{
                print("viewForHeader else")
                return UIView()
            }
            
            header.callback = { theHeader in
                if section == 0{
                    self.moreArtists()
                    header.moreBtn.isHidden = true
                }else if section == 1{
                    self.moreAlbums()
                    header.moreBtn.isHidden = true
                }else{
                    self.moreSongs()
                    header.moreBtn.isHidden = true
                }
            }
            header.backgroundColor = .white
            return header
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 && filteredSongs?.count != 0 {
            return false
        }else{
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 && filteredArtists?.count != 0 {
            let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
                self.pickedArtistID = self.filteredArtists![path.row].ID
                self.playNow(content: .artist)
                self.tableView.setEditing(false, animated: true)
            })
            let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
                self.pickedArtistID = self.filteredArtists![path.row].ID
                self.playNext(content: .artist)
                self.tableView.setEditing(false, animated: true)
            })
            let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
                self.pickedArtistID = self.filteredArtists![path.row].ID
                self.shuffle(content: .artist)
                self.tableView.setEditing(false, animated: true)
            })
            play.backgroundColor = .red
            next.backgroundColor = .orange
            shuffle.backgroundColor = .purple
            return [shuffle, next, play]
        }else if indexPath.section == 1 && filteredAlbums?.count != 0 {
            let play = UITableViewRowAction(style: .default, title: "Play Now", handler: {_,path in
                self.pickedAlbum = self.filteredAlbums![path.row]
                self.playNow(content: .album)
                self.tableView.setEditing(false, animated: true)
            })
            let next = UITableViewRowAction(style: .default, title: "Play Next", handler: {_,path in
                self.pickedAlbum = self.filteredAlbums![path.row]
                self.playNext(content: .album)
                self.tableView.setEditing(false, animated: true)
            })
            let shuffle = UITableViewRowAction(style: .default, title: "Shuffle", handler: {_,path in
                self.pickedAlbum = self.filteredAlbums![path.row]
                self.shuffle(content: .album)
                self.tableView.setEditing(false, animated: true)
            })
            play.backgroundColor = .red
            next.backgroundColor = .orange
            shuffle.backgroundColor = .purple
            return [shuffle, next, play]
        }else{
            return [UITableViewRowAction]()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SearchCell!
        if shouldShowResults{
            if indexPath.section == 0 && filteredArtists?.count != 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
                cell.setup(artist: filteredArtists![indexPath.row])
                cell.accessoryType = .disclosureIndicator
                cell.backgroundColor = .clear
                return cell
            }else if indexPath.section == 1 && filteredAlbums?.count != 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
                cell.setup(album: filteredAlbums![indexPath.row])
                cell.accessoryType = .disclosureIndicator
                cell.backgroundColor = .clear
                return cell
            }else if indexPath.section == 2 && filteredSongs?.count != 0 {
                if cellTypes[indexPath.row] != 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as! QueueActionsCell
                    cell.delegate = self
                    cell.accessoryType = .none
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
                    cell.setup(song: filteredSongs![indexPath.row])
                    cell.accessoryType = .none
                    cell.backgroundColor = .clear
                    return cell
                }
            }else {
                return UITableViewCell()
            }
        }else{
            return UITableViewCell()
        }
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let artist = filteredArtists?[indexPath.row]
            self.pickedArtistID = artist?.ID
            performSegue(withIdentifier: "artist", sender: nil)
        }else if indexPath.section == 2{
            let song = filteredSongs?[indexPath.row]
            if player.isPlayin() {
                cellTypes[indexPath.row] = 1
                tableView.reloadRows(at: [indexPath], with: .fade)
                pickedSong = song
                activeRow = indexPath.row
            }else{
                switch GlobalSettings.deployIn {
                case .artist:
                    player.landInArtist(song!, new: true)
                case .album:
                    player.landInAlbum(song!, new: true)
                default:
                    print("wyladuje w piosenkach")
                }
                player.play()
            }
        }else{
            let album = filteredAlbums?[indexPath.row]
            self.pickedAlbum = album
            performSegue(withIdentifier: "album", sender: nil)
        }
        searchHistory.insert(searchController.searchBar.text!, at: 0)
        if searchHistory.count > 20{
            searchHistory.dropLast()
            UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumsByVC{
            destination.receivedID = self.pickedArtistID
            //searchController.isActive = false
        }else if let destination = segue.destination as? AlbumVC{
            destination.received = self.pickedAlbum
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let path = IndexPath(row: activeRow, section: 2)
        cellTypes[activeRow] = 0
        tableView.reloadRows(at: [path], with: .fade)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowResults {
            shouldShowResults = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }

    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString == ""{
            shouldCompactArtists = true
            shouldCompactSongs = true
            shouldCompactAlbums = true
            shouldShowResults = false
            self.tableView.separatorStyle = .none
        }else{
            shouldShowResults = true
            self.tableView.separatorStyle = .singleLine
        }
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchString!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        var searchItemsPredicate = [NSPredicate]()
        
        let songsMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            let titleExpression = NSExpression(forKeyPath: "title")
            let searchStringExpression = NSExpression(forConstantValue: searchString)
            
            let titleSearchComparisonPredicate = NSComparisonPredicate(leftExpression: titleExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(titleSearchComparisonPredicate)
            
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: songsMatchPredicates)
        
        searchItemsPredicate = [NSPredicate]()
        
        let restMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            let titleExpression = NSExpression(forKeyPath: "name")
            let searchStringExpression = NSExpression(forConstantValue: searchString)
            
            let titleSearchComparisonPredicate = NSComparisonPredicate(leftExpression: titleExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(titleSearchComparisonPredicate)
            
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        let finalRestCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: restMatchPredicates)
        
        filteredSongs = songs?.filter { finalCompoundPredicate.evaluate(with: $0) }
        filteredArtists = artists?.filter { finalRestCompoundPredicate.evaluate(with: $0) }
        filteredAlbums = albums?.filter { finalRestCompoundPredicate.evaluate(with: $0) }
        cellTypes = Array<Int>(repeating: 0, count: (filteredSongs?.count)!)
        self.tableView.reloadData()
    }
 
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Szukaj"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = GlobalSettings.tint.color
        self.searchController.hidesNavigationBarDuringPresentation = false;
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController?.searchBar
        }
    }
    
    func loadArrays(){
        songs = musicQuery.shared.songs
        artists = musicQuery.shared.artists
        albums = musicQuery.shared.albums
        shouldCompactSongs = true
        shouldCompactAlbums = true
        shouldCompactArtists = true
        filteredSongs = [MPMediaItem]()
        filteredArtists = [Artist]()
        filteredAlbums = [AlbumB]()
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func moreSongs(){
        shouldCompactSongs = false
        tableView.reloadData()
        searchController.searchBar.resignFirstResponder()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 2) , at: .top, animated: true)
    }
    
    func moreArtists(){
        shouldCompactArtists = false
        tableView.reloadData()
        searchController.searchBar.resignFirstResponder()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0) , at: .top, animated: true)
    }
    
    func moreAlbums(){
        shouldCompactAlbums = false
        tableView.reloadData()
        searchController.searchBar.resignFirstResponder()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1) , at: .top, animated: true)
    }
    
    func prepareHeaders() {
        var header: SearchHeader!
        header = tableView.dequeueReusableCell(withIdentifier: "header") as! SearchHeader
        header.setup(title: "artists", count: (filteredArtists?.count)!)
        headers.append(header.contentView)
        header.setup(title: "albums", count: (filteredAlbums?.count)!)
        headers.append(header.contentView)
        header.setup(title: "songs", count: (filteredSongs?.count)!)
        headers.append(header.contentView)
    }
    
    func cell(_ cell: QueueActionsCell, action: SongAction) {
        switch action {
        case .playNow:
            playNow(content: .song)
        case .playNext:
            playNext(content: .song)
        case .playLast:
            playLast()
        }
        if let path = tableView.indexPath(for: cell) {
            cellTypes[path.row] = 0
            tableView.reloadRows(at: [path], with: .right)
        }
    }
    
    func playNow(content: Content) {
        switch content {
        case .song:
            switch GlobalSettings.deployIn {
            case .album:
                player.landInAlbum(pickedSong, new: true)
            case .artist:
                player.landInArtist(pickedSong, new: true)
            case .songs:
                player.landInAlbum(pickedSong, new: true)
            }
            player.play()
        case .artist:
            let songs = musicQuery.shared.songsByArtistID(artist: pickedArtistID)
            if player.isShuffle {
                player.disableShuffle()
            }
            player.createDefQueue(items: songs)
            player.playFromDefQueue(index: 0, new: true)
            player.play()
        case .album:
            let items = pickedAlbum.items
            if player.isShuffle {
                player.disableShuffle()
            }
            player.createDefQueue(items: items)
            player.playFromDefQueue(index: 0, new: true)
            player.play()
        }
    }
    
    func playNext(content: Content) {
        switch content {
        case .song:
            player.addNext(item: pickedSong)
        case .artist:
            let songs = musicQuery.shared.songsByArtistID(artist: pickedArtistID)
            var i = songs.count - 1
            while i > -1 {
                player.addNext(item: songs[i])
                i -= 1
            }
        case .album:
            let items = pickedAlbum.items
            var i = items.count - 1
            while i > -1 {
                player.addNext(item: items[i])
                i -= 1
            }
        }
    }
    
    func shuffle(content: Content) {
        switch content {
        case .artist:
            let songs = musicQuery.shared.songsByArtistID(artist: pickedArtistID)
            player.createDefQueue(items: songs)
            player.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
            player.shuffleCurrent()
            player.playFromShufQueue(index: 0, new: true)
            player.play()
        case .album:
            let items = pickedAlbum.items
            player.createDefQueue(items: items)
            player.defIndex = Int(arc4random_uniform(UInt32(items.count)))
            player.shuffleCurrent()
            player.playFromShufQueue(index: 0, new: true)
            player.play()
        default:
            print("default")
        }
    }
    
    func playLast() {
        player.addLast(item: pickedSong)
    }
}
