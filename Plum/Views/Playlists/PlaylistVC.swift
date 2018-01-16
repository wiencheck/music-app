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
    
    let defaults = UserDefaults.standard
    var indexes = [String]()
    var result = [String: [MPMediaItem]]()
    var songs: [MPMediaItem]!
    var indexesInt = [Int]()
    var cellTypes = [Int: [Int]]()
    var cellTypesSearch = [Int]()
    var absoluteIndex = 0
    var activeIndexRow = 0
    var searchRow = 0
    var activeIndexSection = 0
    var searchController: UISearchController!
    var receivedID: MPMediaEntityPersistentID!
    var pickedAlbumID: MPMediaEntityPersistentID!
    var pickedArtistID: MPMediaEntityPersistentID!
    var playlist: Playlist!
    var receivedList: Playlist!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableIndexView: TableIndexView!
    @IBOutlet weak var searchView: BlurView!
    var filteredSongs = [MPMediaItem]()
    var shouldShowResults = false
    var heightInset: CGFloat!
    var hideKeyboard = false
    let device = GlobalSettings.device

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        receivedList = musicQuery.shared.playlistForID(playlist: receivedID)
        //tableView.separatorStyle = .none
        navigationItem.title = receivedList.name
        //title = receivedList.name
        setTable()
        tableView.separatorColor = UIColor.lightSeparator
        configureSearchController()
        view.bringSubview(toFront: tableIndexView)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        definesPresentationContext = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        definesPresentationContext = true
    }
    
    @IBAction func ratingPressed() {
        GlobalSettings.changeRating(!GlobalSettings.rating)
        tableView.reloadData()
    }
    
    func setTable(){
        //self.tableView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        self.tableView.backgroundColor = UIColor.lightBackground
        tableView.delegate = self
        tableView.dataSource = self
        songs = receivedList.items
        setup()
        var iterator = 0
        for index in indexes{
            cellTypes[iterator] = []
            for _ in 0 ..< (result[index]?.count)!{
                cellTypes[iterator]?.append(0)
            }
            iterator += 1
        }
        if songs.count > 11 {
            tableIndexView.indexes = self.indexes
            tableIndexView.tableView = self.tableView
            tableIndexView.setup(color: UIColor.white)
        }else{
            tableIndexView.isHidden = true
        }
    }

}

extension PlaylistVC: UITableViewDelegate, UITableViewDataSource, QueueCellDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowResults {
            return 1
        }else{
            return indexes.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredSongs.count
        }else{
            return (result[indexes[section]]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowResults {
            if cellTypesSearch[indexPath.row] != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as! QueueActionsCell
                cell.delegate = self
                cell.backgroundColor = .clear
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
                let item = filteredSongs[indexPath.row]
                if GlobalSettings.theme == .dark {
                    cell.setup(item: item, titColor: .white, artColor: .white, albColor: UIColor.lightText)
                    cell.titleLabel.textColor = .white
                }else{
                    cell.setup(item: item, titColor: .black, artColor: .black, albColor: .black)
                    cell.titleLabel.textColor = .black
                }
                cell.backgroundColor = .clear
                return cell
            }
        }else{
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell", for: indexPath) as! ShuffleCell
                cell.setup(style: .light)
                return cell
            }else{
                if(cellTypes[indexPath.section]?[indexPath.row] == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
                    let item = result[indexes[indexPath.section]]?[indexPath.row]
                    if(item != Plum.shared.currentItem){
                        if GlobalSettings.theme == .dark {
                            cell.setup(item: item!, titColor: .white, artColor: .white, albColor: UIColor.lightText)
                            cell.titleLabel.textColor = .white
                        }else{
                            cell.setup(item: item!, titColor: .black, artColor: .black, albColor: UIColor.gray)
                            cell.titleLabel.textColor = .black
                        }
                    }else{
                        if GlobalSettings.theme == .dark {
                            cell.setup(item: item!, titColor: .white, artColor: .white, albColor: UIColor.lightText)
                            cell.titleLabel.textColor = .white
                        }else{
                            cell.setup(item: item!, titColor: .black, artColor: .black, albColor: .black)
                            cell.titleLabel.textColor = .black
                        }
                    }
                    cell.backgroundColor = .clear
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath) as! QueueActionsCell
                    cell.delegate = self
                    cell.backgroundColor = .clear
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldShowResults {
            return 62
        }else{
            if indexPath.section == 0 {
                return 44
            }else{
                return 62
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowResults {
            if cellTypesSearch[searchRow] != 0 {
                cellTypesSearch[searchRow] = 0
                tableView.reloadRows(at: [IndexPath(row: searchRow, section: 0)], with: .fade)
            }
            searchRow = indexPath.row
            if Plum.shared.isPlayin() {
                cellTypesSearch[searchRow] = 1
                tableView.reloadRows(at: [indexPath], with: .fade)
            }else{
                let item = filteredSongs[indexPath.row]
                let rand = Int(arc4random_uniform(UInt32(songs.count)))
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.defIndex = rand
                Plum.shared.shuffleCurrent()
                for i in 0 ..< Plum.shared.shufQueue.count {
                    if Plum.shared.shufQueue[i] == item {
                        (Plum.shared.shufQueue[i], Plum.shared.shufQueue[0]) = (Plum.shared.shufQueue[0], Plum.shared.shufQueue[i])
                        break
                    }
                }
                Plum.shared.playFromShufQueue(index: 0, new: true)
                Plum.shared.play()
            }
        }else{
            if cellTypes[activeIndexSection]?[activeIndexRow] != 0 {
                cellTypes[activeIndexSection]?[activeIndexRow] = 0
                tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection+1)], with: .fade)
            }
            
            if indexPath.section == 0 {
                shuffleAll()
            }else{
                absoluteIndex = indexPath.absoluteRow(tableView) - 1
                activeIndexRow = indexPath.row
                activeIndexSection = indexPath.section
                if(cellTypes[activeIndexSection]?[activeIndexRow] == 0){
                    if(Plum.shared.isPlayin()){
                        cellTypes[activeIndexSection]?[activeIndexRow] = 1
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
                    cellTypes[activeIndexSection]?[activeIndexRow] = 0
                    tableView.reloadRows(at: [indexPath], with: .right)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
        if shouldShowResults {
            cellTypesSearch[searchRow] = 0
            tableView.reloadRows(at: [IndexPath(row: searchRow, section: 0)], with: .right)
        }else{
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
        }
    }
    
    func playNextBtn() {
        if shouldShowResults {
            Plum.shared.addNext(item: filteredSongs[searchRow])
        }else{
            Plum.shared.addNext(item: songs[absoluteIndex])
        }
    }
    func playLastBtn() {
        if shouldShowResults {
            Plum.shared.addLast(item: filteredSongs[searchRow])
        }else{
            Plum.shared.addLast(item: songs[absoluteIndex])
        }
    }
    func playNowBtn() {
        if shouldShowResults {
            if(Plum.shared.isShuffle){
                let item = filteredSongs[searchRow]
                for i in 0 ..< songs.count {
                    if songs[i] == item {
                        absoluteIndex = i
                        break
                    }
                }
                Plum.shared.disableShuffle()
                Plum.shared.defIndex = absoluteIndex
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.shuffleCurrent()
                Plum.shared.playFromShufQueue(index: 0, new: true)
            }else{
                let item = filteredSongs[searchRow]
                for i in 0 ..< songs.count {
                    if songs[i] == item {
                        absoluteIndex = i
                        break
                    }
                }
                Plum.shared.createDefQueue(items: songs)
                Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
            }
        }else{
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
        }
        Plum.shared.play()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if shouldShowResults {
            return true
        }else{
            if indexPath.section == 0 {
                return false
            }else{
                return true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if shouldShowResults {
            let album = UITableViewRowAction(style: .default, title: "Album", handler: {_,path in
                let item = self.filteredSongs[path.row]
                self.pickedAlbumID = item.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.albumBtn()
            })
            album.backgroundColor = .albumGreen
            let artist = UITableViewRowAction(style: .default, title: "Artist", handler: {_,path in
                let item = self.filteredSongs[path.row]
                self.pickedArtistID = item.albumArtistPersistentID
                self.pickedAlbumID = item.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.artistBtn()
            })
            artist.backgroundColor = .artistBlue
            return [album, artist]
        }else{
            let album = UITableViewRowAction(style: .default, title: "Album", handler: {_,path in
                let item = self.result[self.indexes[path.section]]?[path.row]
                self.pickedAlbumID = item?.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.albumBtn()
            })
            album.backgroundColor = .albumGreen
            let artist = UITableViewRowAction(style: .default, title: "Artist", handler: {_,path in
                let item = self.result[self.indexes[path.section]]?[path.row]
                self.pickedArtistID = item?.albumArtistPersistentID
                self.pickedAlbumID = item?.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.artistBtn()
            })
            artist.backgroundColor = .artistBlue
            return [album, artist]
        }
    }
    
    func albumBtn(){
        performSegue(withIdentifier: "album", sender: nil)
    }
    func artistBtn(){
        if musicQuery.shared.artistAlbumsID(artist: self.pickedArtistID).count == 1 {
            performSegue(withIdentifier: "album", sender: nil)
        }else{
            performSegue(withIdentifier: "artist", sender: nil)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if shouldShowResults {
            cellTypesSearch[activeIndexRow] = 0
            let indexPath = IndexPath(row: activeIndexRow, section: 0)
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }else{
            cellTypes[activeIndexSection]?[activeIndexRow] = 0
            let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection)
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        cellTypes[indexPath.section]?[indexPath.row] = 0
//        tableView.reloadRows(at: [indexPath], with: .fade)
//    }
    
    func setup(){
        let bcount = receivedList.songsIn
        indexes.append(" - ")
        indexesInt.append(0)
        result[" - "] = [MPMediaItem()]
        if bcount > 36 {
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
            for i in 1 ..< indexes.count {
                result[indexes[i]] = []
                while stoppedAt < bcount {
                    result[indexes[i]]?.append(songs[stoppedAt])
                    stoppedAt += 1
                    if stoppedAt == indexesInt[i] + difference { break }
                }
            }
//            for i in 1 ..< indexes.count{
//                result[indexes[i]] = []
//                for j in stoppedAt ..< bcount{
//                    if j > indexesInt[i]{
//                        stoppedAt = j
//                        break
//                    }
//                    result[indexes[i]]?.append(songs[j])
//                }
//            }
        }else{
            indexesInt.append(0)
            indexes.append("#\(bcount)")
            result["#\(bcount)"] = []
            result["#\(bcount)"]?.append(contentsOf: songs)
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

extension PlaylistVC: UISearchBarDelegate, UISearchResultsUpdating {
    
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search in \(receivedList.name)"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = GlobalSettings.tint.color
        self.searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.isTranslucent = true
        searchView.addSubview(searchController.searchBar)
        let attributes: [NSLayoutAttribute] = [.top, .bottom, . left, .right]
        NSLayoutConstraint.activate(attributes.map{NSLayoutConstraint(item: self.searchController.searchBar, attribute: $0, relatedBy: .equal, toItem: self.searchView, attribute: $0, multiplier: 1, constant: 0)})
        if device == "iPhone X" {
            heightInset = 140
        }else{
            heightInset = 112
        }
        let bottomInset = 49 + GlobalSettings.bottomInset
        tableView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -160 {
            searchController.searchBar.becomeFirstResponder()
        }else if scrollView.contentOffset.y > -80 {
            if hideKeyboard {
                searchController.searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        tableView.reloadData()
        tableIndexView.isHidden = false
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
            shouldShowResults = false
            tableIndexView.isHidden = false
        }else{
            shouldShowResults = true
            tableIndexView.isHidden = true
            if filteredSongs.count != 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
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
            
            let artistExpression = NSExpression(forKeyPath: "artist")
            let searchStringExpression2 = NSExpression(forConstantValue: searchString)
            
            let titleSearchComparisonPredicate2 = NSComparisonPredicate(leftExpression: artistExpression, rightExpression: searchStringExpression2, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(titleSearchComparisonPredicate2)
            
            let albumExpression = NSExpression(forKeyPath: "albumTitle")
            let searchStringExpression3 = NSExpression(forConstantValue: searchString)
            
            let titleSearchComparisonPredicate3 = NSComparisonPredicate(leftExpression: albumExpression, rightExpression: searchStringExpression3, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(titleSearchComparisonPredicate3)
            
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: songsMatchPredicates)
        
        filteredSongs = (songs?.filter { finalCompoundPredicate.evaluate(with: $0) })!
        cellTypesSearch = Array<Int>(repeating: 0, count: filteredSongs.count)
        self.tableView.reloadData()
        if filteredSongs.count != 0 {
            hideKeyboard = false
            tableView.contentOffset.y = -heightInset
            hideKeyboard = true
        }
    }
    
}

extension PlaylistVC: UITabBarControllerDelegate {
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
