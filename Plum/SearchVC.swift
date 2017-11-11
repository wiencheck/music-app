//
//  SearchVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 24.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    var titles = ["Artists", "Albums", "Songs"]
    @IBOutlet weak var tableView: UITableView!
    var songs: [MPMediaItem]?
    var filteredSongs: [MPMediaItem]?
    var shouldCompactSongs: Bool!
    var artists: [Artist]?
    var filteredArtists: [Artist]?
    var shouldCompactArtists: Bool!
    var albums: [AlbumB]?
    var filteredAlbums: [AlbumB]?
    var shouldCompactAlbums: Bool!
    var searchController: UISearchController!
    var shouldShowResults: Bool!
    var pickedAlbum: AlbumB!
    var pickedArtistID: MPMediaEntityPersistentID!
    var pickedSong: MPMediaItem!
    var searchHistory: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.theme
        searchHistory = UserDefaults.standard.array(forKey: "searchHistory") as! [String]
        loadArrays()
        configureSearchController()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_se"))
        shouldShowResults = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.tabBarController?.tabBar.tintColor = GlobalSettings.theme
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchHistory = UserDefaults.standard.array(forKey: "searchHistory") as! [String]
        searchController.isActive = true
        delay(0.1) { self.searchController.searchBar.becomeFirstResponder() }
        if searchController.searchBar.text != ""{
            searchController.searchBar.text = ""
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
        if shouldShowResults{
            if section == 2{
                if (filteredSongs?.count)! > 3 && shouldCompactSongs{
                    return 3
                }else{
                    return (filteredSongs?.count)!
                }
            }else if section == 0{
                if (filteredArtists?.count)! > 3 && shouldCompactArtists{
                    return 3
                }else{
                    return (filteredArtists?.count)!
                }
            }else{
                if (filteredAlbums?.count)! > 3 && shouldCompactAlbums{
                    return 3
                }else{
                    return (filteredAlbums?.count)!
                }
            }
        }else{
            return searchHistory.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 94
        }else if indexPath.section == 1{
            return 94
        }else{
            return 62
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        /*if shouldShowResults{
            if tableView.numberOfRows(inSection: section) == 0{
                return 26
            }else{
                return 26
            }
        }else{
            return 26
        }*/
        return 26
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldShowResults{
            let header = tableView.dequeueReusableCell(withIdentifier: "header") as! SearchHeader
            if tableView.numberOfRows(inSection: section) == 0{
                return nil
            }
            if section == 0 {
                header.setup(title: "artists", count: (filteredArtists?.count)!)
            }else if section == 1{
                header.setup(title: "albums", count: (filteredAlbums?.count)!)
            }else{
                header.setup(title: "songs", count: (filteredSongs?.count)!)
            }
            header.callback = { theHeader in
                if section == 0{
                    self.moreArtists()
                }else if section == 1{
                    self.moreAlbums()
                }else{
                    self.moreSongs()
                }
            }
            header.backgroundColor = .white
            return header
        }else{
            return nil
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowResults{
            if indexPath.section == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongCell
                cell.setup(item: (filteredSongs?[indexPath.row])!)
                cell.backgroundColor = .clear
                return cell
            }else if indexPath.section == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as! ArtistCell
                cell.setup(artist: (filteredArtists?[indexPath.row])!)
                cell.backgroundColor = .clear
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! AlbumCell
                cell.setup(album: (filteredAlbums?[indexPath.row])!)
                cell.backgroundColor = .clear
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
            cell.textLabel?.text = searchHistory[indexPath.row]
            cell.backgroundColor = .clear
            return cell
        }
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let artist = filteredArtists?[indexPath.row]
            self.pickedArtistID = artist?.ID
            searchHistory.insert((artist?.name)!, at: 0)
            performSegue(withIdentifier: "artist", sender: nil)
        }else if indexPath.section == 2{
            let song = filteredSongs?[indexPath.row]
            searchHistory.insert((song?.title)!, at: 0)
            Plum.shared.landInAlbum(song!, new: true)
            Plum.shared.play()
        }else{
            let album = filteredAlbums?[indexPath.row]
            searchHistory.insert((album?.name)!, at: 0)
            self.pickedAlbum = album
            performSegue(withIdentifier: "album", sender: nil)
        }
        if searchHistory.count > 20{
            //searchHistory.dropLast()
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //shouldShowResults = true
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
        let words = searchString?.components(separatedBy: " ")
        filteredSongs = songs?.filter{
            $0.title?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "_", with: "").lowercased().range(of: (searchString?.lowercased())!) != nil
        }
        filteredArtists = artists?.filter{
            $0.name.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "_", with: "").lowercased().range(of: (searchString?.lowercased())!) != nil
        }
        filteredAlbums = albums?.filter{
            $0.name?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "_", with: "").lowercased().range(of: (searchString?.lowercased())!) != nil
        }
        /*let filteredStrings : [String] = myArr.filter({ (aString) in
            
            let hasChars = findChrs.filter({(bString) in
                return aString.contains(bString)
            })
            
            print(hasChars)
            
            return hasChars.count == findChrs.count
        })*/
        /*filteredSongs = songs?.filter{
            $0.title?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").lowercased().range(of: (words![0].lowercased())) != nil
        }
        if words?.count == 2{
            filteredSongs = songs?.filter{
                $0.title?.lowercased().range(of: (words![1].lowercased())) != nil
            }
        }
        filteredArtists = artists?.filter{
            $0.name.lowercased().range(of: (searchString?.lowercased())!) != nil
        }
        filteredAlbums = albums?.filter{
            $0.name?.lowercased().range(of: (searchString?.lowercased())!) != nil
        }*/
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
        searchController.searchBar.tintColor = GlobalSettings.theme
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
        tableView.reloadSections([2], with: .none)
        searchController.searchBar.resignFirstResponder()
    }
    
    func moreArtists(){
        shouldCompactArtists = false
        tableView.reloadSections([0], with: .none)
        searchController.searchBar.resignFirstResponder()
    }
    
    func moreAlbums(){
        shouldCompactAlbums = false
        tableView.reloadSections([2], with: .none)
        searchController.searchBar.resignFirstResponder()
    }
    
}
