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
    var searchController: UISearchController!
    var filteredSongs = [MPMediaItem]()
    var shouldShowResults = false
    var cellTypesSearch = [Int]()
    var searchActiveRow = 0
    var headers = [UIView]()
    var heightInset: CGFloat!
    var hideKeyboard = false
    var currentTheme: Theme!
    let device = GlobalSettings.device
    
    var themeBtn: UIBarButtonItem!
    //@IBOutlet weak var ratingBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indexView: TableIndexView!
    var titleButton: UIButton!
    var navView: UIView!
    var searchView: SearchBarContainerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
        tabBarController?.delegate = self
        if musicQuery.shared.songsSet{
            songs = musicQuery.shared.songs
        }else{
            songs = musicQuery.shared.allSongs()
        }
        //songs.append(contentsOf: musicQuery.shared.allPodcasts())
        if !songs.isEmpty {
            tableView.delegate = self
            tableView.dataSource = self
            setupDict()
            for index in indexes {
                cellTypes.append(Array<Int>(repeating: 0, count: (result[index]?.count)!))
            }
            cellTypes[0].append(0)
            indexView.indexes = self.indexes
            indexView.tableView = self.tableView
            indexView.setup()
            view.bringSubview(toFront: indexView)
        }
        tableView.tableFooterView = UIView(frame: .zero)
        configureSearchController()
        setTitleButton()
        setTheme()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        print("Songs loaded")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        instruct("songs", message: "Swipe left on a song to quickly go to corresponding album or artist page", completion: nil)
        instruct("searchNav", message: "Tap on the title in upper bar or scroll behind upper bounds to invoke search bar. Give it a try in different screens as well!", completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        definesPresentationContext = false
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
        definesPresentationContext = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowResults {
            return 1
        }else{
            return indexes.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldShowResults {
            return UIView()
        }else{
            let index = indexes[section]
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 27))
            v.backgroundColor = .clear
            let label = UILabel(frame: CGRect(x: 12, y: 5, width: v.frame.width, height: 21))
            let tool = UIToolbar(frame: v.frame)
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            if currentTheme == .dark {
                label.textColor = .white
                tool.barStyle = .blackTranslucent
            }else{
                label.textColor = UIColor.gray
                tool.barStyle = .default
            }
            v.addSubview(tool)
            label.text = index
            v.addSubview(label)
            v.bringSubview(toFront: label)
            v.clipsToBounds = true
            return v;
        }
    }
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
//        view.backgroundColor = .clear
//        let header = view as! UITableViewHeaderFooterView
//        let tool = UIToolbar(frame: header.bounds)
//        tool.barStyle = .default
//        header.addSubview(tool)
//        header.textLabel?.textColor = UIColor.white
//        header.sendSubview(toBack: tool)
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return indexes[section]
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if shouldShowResults {
            return 0
        }else{
            return 27
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredSongs.count
        }else{
            if section == 0 {
                return (result[indexes[0]]?.count)! + 1
            }else{
                return (result[indexes[section]]?.count)!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if shouldShowResults {
            return true
        }else{
            if indexPath.isFirst() {
                return false
            }else{
                return true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var tmp = 0
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
                if path.section == 0 { tmp = 1 }
                let item = self.result[self.indexes[path.section]]?[path.row-tmp]
                self.pickedAlbumID = item?.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.albumBtn()
            })
            album.backgroundColor = .albumGreen
            let artist = UITableViewRowAction(style: .default, title: "Artist", handler: {_,path in
                if path.section == 0 { tmp = 1 }
                let item = self.result[self.indexes[path.section]]?[path.row-tmp]
                self.pickedArtistID = item?.albumArtistPersistentID
                self.pickedAlbumID = item?.albumPersistentID
                tableView.setEditing(false, animated: true)
                self.artistBtn()
            })
            artist.backgroundColor = .artistBlue
            return [album, artist]
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
                return cell
            }
        }else{
            if indexPath.isFirst() {
                let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell", for: indexPath) as! ShuffleCell
                cell.setup(style: currentTheme)
                return cell
            }else{
                if indexPath.section == 0 {
                    if(cellTypes[indexPath.section][indexPath.row] == 0){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
                        let item = result[indexes[indexPath.section]]?[indexPath.row-1]
                        cell.setup(item: item!)
                        return cell
                    }else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell",  for: indexPath) as! QueueActionsCell
                        cell.delegate = self
                        return cell
                    }
                }else{
                    if(cellTypes[indexPath.section][indexPath.row] == 0){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
                        let item = result[indexes[indexPath.section]]?[indexPath.row]
                        cell.setup(item: item!)
                        return cell
                    }else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell",  for: indexPath) as! QueueActionsCell
                        cell.delegate = self
                        return cell
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldShowResults {
            return 64
        }else{
            if indexPath.isFirst() {
                return 44
            }else{
                return 64
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Active: \(activeIndexSection) \(activeIndexRow) Selected \(indexPath.section) \(indexPath.row)")
        if shouldShowResults {
            if cellTypesSearch[searchActiveRow] != 0 {
                cellTypesSearch[searchActiveRow] = 0
                tableView.reloadRows(at: [IndexPath(row: searchActiveRow, section: 0)], with: .fade)
            }
                searchActiveRow = indexPath.row
                if cellTypesSearch[searchActiveRow] == 0 {
                    if Plum.shared.isPlayin() {
                        cellTypesSearch[searchActiveRow] = 1
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }else{
                        if Plum.shared.isShuffle {
                            Plum.shared.disableShuffle()
                            Plum.shared.createDefQueue(items: songs)
                            let item = filteredSongs[searchActiveRow]
                            for i in 0 ..< songs.count {
                                if item == songs[i] {
                                    absoluteIndex = i
                                    break
                                }
                            }
                            Plum.shared.defIndex = absoluteIndex
                            Plum.shared.shuffleCurrent()
                            Plum.shared.playFromShufQueue(index: 0, new: true)
                        }else{
                            Plum.shared.createDefQueue(items: songs)
                            let item = filteredSongs[searchActiveRow]
                            for i in 0 ..< songs.count {
                                if item == songs[i] {
                                    absoluteIndex = i
                                    break
                                }
                            }
                            Plum.shared.playFromDefQueue(index: absoluteIndex, new: true)
                        }
                        Plum.shared.play()
                    }
                }else{
                    cellTypesSearch[searchActiveRow] = 0
                    tableView.reloadRows(at: [indexPath], with: .right)
                }
        }else{
            if cellTypes[activeIndexSection][activeIndexRow] != 0 {
                cellTypes[activeIndexSection][activeIndexRow] = 0
                tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .fade)
            }
            if indexPath.section == 0 && indexPath.row == 0 {
                shuffleAll()
            }else{
                activeIndexRow = indexPath.row
                absoluteIndex = indexPath.absoluteRow(tableView) - 1
                activeIndexSection = indexPath.section
                if(cellTypes[activeIndexSection][activeIndexRow] == 0){
                    if(Plum.shared.isPlayin()){
                        cellTypes[activeIndexSection][activeIndexRow] = 1
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
                    cellTypes[activeIndexSection][activeIndexRow] = 0
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
        if shouldShowResults {
            cellTypesSearch[searchActiveRow] = 0
            tableView.reloadRows(at: [IndexPath(row: searchActiveRow, section: 0)], with: .right)
        }else{
            cellTypes[activeIndexSection][activeIndexRow] = 0
            tableView.reloadRows(at: [IndexPath(row: activeIndexRow, section: activeIndexSection)], with: .right)
        }
    }
    
    func playNextBtn() {
        if shouldShowResults {
            Plum.shared.addNext(item: filteredSongs[searchActiveRow])
        }else{
            Plum.shared.addNext(item: songs[absoluteIndex])
        }
    }
    func playLastBtn() {
        if shouldShowResults {
            Plum.shared.addLast(item: filteredSongs[searchActiveRow])
        }else{
            Plum.shared.addLast(item: songs[absoluteIndex])
        }
    }
    func playNowBtn() {
        if shouldShowResults {
            if Plum.shared.isUsrQueue {
                Plum.shared.clearQueue()
            }
            if Plum.shared.isShuffle {
                let item = filteredSongs[searchActiveRow]
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
                let item = filteredSongs[searchActiveRow]
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
        }
        Plum.shared.play()
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
            cellTypesSearch[searchActiveRow] = 0
            let indexPath = IndexPath(row: searchActiveRow, section: 0)
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }else{
            cellTypes[activeIndexSection][activeIndexRow] = 0
            //print("section \(activeIndexSection) row \(activeIndexRow)")
            let indexPath = IndexPath(row: activeIndexRow, section: activeIndexSection)
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

extension SongsVC {
    
    func setupDict() {
        let articles = ["The","A","An"]
        var anyNumber = false
        var anySpecial = false
        for song in songs {
            let objStr = song.title!.trimmingCharacters(in: .whitespaces)
            let article = objStr.components(separatedBy: " ").first!
            if articles.contains(article) {
                if objStr.components(separatedBy: " ").count > 1 {
                    let secondStr = String(objStr.components(separatedBy: " ")[1].uppercased().first!)
                    if result["\(secondStr)"] != nil {
                        result["\(secondStr)"]?.append(song)
                    }else{
                        result["\(secondStr)"] = []
                        result["\(secondStr)"]?.append(song)
                        indexes.append("\(secondStr)")
                    }
                }
            }else{
                if let prefi = article.first {
                    let prefix = "\(prefi)".uppercased()
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
        }
//        for i in 0 ..< indexes.count {
//            if indexes[i].rangeOfCharacter(from: .SSet) != nil {
//                let temp = result[indexes[i]]
//                result["S"]?.append(contentsOf: temp!)
//                indexes.remove(at: i)
//            }
//        }
        indexes.sort {
            (s1, s2) -> Bool in return s1.localizedStandardCompare(s2) == .orderedAscending
        }
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
    }
    
    func shuffleAll() {
        Plum.shared.createDefQueue(items: songs)
        Plum.shared.defIndex = Int(arc4random_uniform(UInt32(songs.count)))
        Plum.shared.shuffleCurrent()
        Plum.shared.playFromShufQueue(index: 0, new: true)
        Plum.shared.play()
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

extension SongsVC: UITabBarControllerDelegate {
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

extension SongsVC: UISearchBarDelegate, UISearchResultsUpdating {
    
    func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for songs"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = GlobalSettings.tint.color
        searchController.searchBar.contentMode = .scaleAspectFill
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.clipsToBounds = true
        searchView = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        if device == "iPhone X" {
            heightInset = 88
        }else{
            heightInset = 64
        }
        automaticallyAdjustsScrollViewInsets = false
        let bottomInset = 49 + GlobalSettings.bottomInset
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.contentInset = UIEdgeInsetsMake(heightInset, 0, bottomInset, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y < -heightInset - 104 {
            showSearchBar()
        }
        else if scrollView.contentOffset.y > -heightInset + 24 {
            if hideKeyboard {
                searchController.searchBar.resignFirstResponder()
            }
        }
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
        indexView.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        tableView.reloadData()
        indexView.isHidden = false
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItem = themeBtn
        navigationItem.titleView = titleButton
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString == ""{
            shouldShowResults = false
        }else{
            shouldShowResults = true
            searchActiveRow = 0
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
        
        
        filteredSongs = (songs.filter { finalCompoundPredicate.evaluate(with: $0) })
        cellTypesSearch = Array<Int>(repeating: 0, count: filteredSongs.count)
        tableView.reloadData()
        if filteredSongs.count != 0 {
            hideKeyboard = false
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            hideKeyboard = true
            searchActiveRow = 0
        }
    }
    
    func setTitleButton() {
        titleButton = UIButton(type: .custom)
        titleButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        titleButton.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
        let attributedH = NSAttributedString(string: "Search", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium), NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color])
        titleButton.setAttributedTitle(attributedH, for: .highlighted)
        navigationItem.titleView = titleButton
        themeBtn = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(themeBtnPressed(_:)))
        navigationItem.rightBarButtonItem = themeBtn
    }
    
    @objc func showSearchBar() {
        navigationItem.titleView = searchView
        navigationItem.rightBarButtonItem = nil
        searchController.searchBar.becomeFirstResponder()
    }
    
    func setHeaders() {
        headers.removeAll()
        for index in indexes {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 27))
            v.backgroundColor = .clear
            let label = UILabel(frame: CGRect(x: 12, y: 5, width: v.frame.width, height: 21))
            let tool = UIToolbar(frame: v.frame)
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            if currentTheme == .dark {
                label.textColor = .white
                tool.barStyle = .blackTranslucent
            }else{
                label.textColor = UIColor.gray
                tool.barStyle = .default
            }
            //v.addSubview(gradient)
            v.addSubview(tool)
            label.text = index
            v.addSubview(label)
            v.bringSubview(toFront: label)
            v.clipsToBounds = true
            headers.append(v)
        }
    }
    
    @objc func updateTheme() {
        setTheme()
        setHeaders()
        tableView.reloadData()
    }
    
    @IBAction func themeBtnPressed(_ sender: UIBarButtonItem) {
        if GlobalSettings.theme == .dark {
            GlobalSettings.changeTheme(.light)
        }else{
            GlobalSettings.changeTheme(.dark)
        }
    }
    
    func setTheme() {
        currentTheme = GlobalSettings.theme
        guard let bar = navigationController?.navigationBar else { return }
        let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        let background = UIImageView(frame: tableView.bounds)
        background.contentMode = .scaleToFill
        switch currentTheme {
        case .light:
            themeBtn.image = #imageLiteral(resourceName: "light_bar")
            background.image = #imageLiteral(resourceName: "gradient_background")
            //tool.barStyle = .default
            bar.barStyle = .default
            let attributedN = NSAttributedString(string: "Songs", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.black])
            titleButton.setAttributedTitle(attributedN, for: .normal)
            titleButton.tintColor = .black
            textField?.textColor = .black
        case .dark:
            themeBtn.image = #imageLiteral(resourceName: "dark_bar")
            bar.barStyle = .blackTranslucent
            background.image = #imageLiteral(resourceName: "Dark_gradient")
            let attributedN = NSAttributedString(string: "Songs", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium), NSAttributedStringKey.foregroundColor: UIColor.white])
            titleButton.setAttributedTitle(attributedN, for: .normal)
            titleButton.tintColor = .white
            textField?.textColor = .white
        default:
            bar.barStyle = .blackTranslucent
            titleButton.tintColor = .white
        }
        //tableView.backgroundView = background
        tableView.backgroundColor = UIColor.background
        tableView.separatorColor = UIColor.separator
        indexView.backgroundColor = UIColor.indexBackground
        bar.tintColor = GlobalSettings.tint.color
    }
    
}

extension SongsVC {     //Responding to in-app purchase events
    
    func registerTrialObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUnlockChangedNotification(_:)), name: .unlockChanged, object: nil)
    }
    
    func unregisterTrialObserver() {
        NotificationCenter.default.removeObserver(self, name: .unlockChanged, object: nil)
    }
    
    @objc func handleUnlockChangedNotification(_ notifiaction: Notification) {
        if let state = notifiaction.userInfo!["state"] as? Bool {
            themeBtn.isEnabled = state
            updateTheme()
            titleButton.isEnabled = state
        }
    }
    
}
