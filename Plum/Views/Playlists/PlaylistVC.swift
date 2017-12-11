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
    @IBOutlet weak var upperBar: UINavigationItem!
    @IBOutlet weak var tableIndexView: TableIndexView!
    var filteredSongs = [MPMediaItem]()
    var shouldShowResults = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        upperBar.title = receivedList.name
        setTable()
        configureSearchController()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func setTable(){
        self.tableView.backgroundView = UIImageView.init(image: #imageLiteral(resourceName: "background_se"))
        self.tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
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
            tableIndexView.setup()
            view.addSubview(tableIndexView)
        }
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    }

}

extension PlaylistVC: UITableViewDelegate, UITableViewDataSource, QueueCellDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowResults {
            return 1
        }else{
            return indexesInt.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredSongs.count
        }else{
            if section == 0 {
                return 1
            }else{
                return (result[indexes[section-1]]?.count)!
            }
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
                cell.setup(item: item)
                cell.backgroundColor = .clear
                return cell
            }
        }else{
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell", for: indexPath)
                cell.textLabel?.text = "Shuffle"
                cell.backgroundColor = .clear
                return cell
            }else{
                if(cellTypes[indexPath.section-1]?[indexPath.row] == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
                    let item = result[indexes[indexPath.section-1]]?[indexPath.row]
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
                activeIndexSection = indexPath.section - 1
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
    
    @IBAction func NPBtnPressed(_ sender: Any) {
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        Plum.shared.shuffleCurrent()
        Plum.shared.playFromShufQueue(index: 0, new: true)
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
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection+1)], with: .right)
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
    func albumBtn(){
        cellTypes[activeIndexSection]?[activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection + 1)], with: .fade)
        performSegue(withIdentifier: "album", sender: nil)
    }
    func artistBtn(){
        cellTypes[activeIndexSection]?[activeIndexRow] = 0
        self.tableView.reloadRows(at: [IndexPath(row: self.activeIndexRow, section: activeIndexSection+1)], with: .fade)
        if musicQuery.shared.artistAlbumsID(artist: (result[indexes[activeIndexSection]]?[activeIndexRow].albumArtistPersistentID)!).count == 1 {
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
            let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection+1)
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
        searchController.searchBar.placeholder = "Search in list"
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
            self.tableView.separatorStyle = .singleLine
            tableIndexView.isHidden = true
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
        
        filteredSongs = (songs?.filter { finalCompoundPredicate.evaluate(with: $0) })!
        cellTypesSearch = Array<Int>(repeating: 0, count: filteredSongs.count)
        self.tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -104 {
            searchController.searchBar.becomeFirstResponder()
        }else if scrollView.contentOffset.y > 2 {
            searchController.searchBar.resignFirstResponder()
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
