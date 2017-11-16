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
    var shouldCompactAlbums: Bool!
    var searchController: UISearchController!
    var shouldShowResults: Bool!
    var pickedAlbum: AlbumB!
    var pickedArtistID: MPMediaEntityPersistentID!
    var pickedSong: MPMediaItem!
    var searchHistory: [String]!
    var headers = [UIView]()

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
        /*if searchController.searchBar.text != ""{
            //[[UIApplication sharedApplication] sendAction:@selector(selectAll:) to:nil from:nil forEvent:nil]
            searchController.searchBar.becomeFirstResponder()
            UIApplication.shared.sendAction(#selector(selectAll(_:)), to: nil, from: nil, for: nil)
        }*/
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

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SearchCell!
        if shouldShowResults{
            if indexPath.section == 0 && filteredArtists?.count != 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
                cell.setup(artist: filteredArtists![indexPath.row])
                cell.backgroundColor = .clear
                return cell
            }else if indexPath.section == 1 && filteredAlbums?.count != 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
                cell.setup(album: filteredAlbums![indexPath.row])
                cell.backgroundColor = .clear
                return cell
            }else if indexPath.section == 2 && filteredSongs?.count != 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
                cell.setup(song: filteredSongs![indexPath.row])
                cell.backgroundColor = .clear
                return cell
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
            Plum.shared.landInAlbum(song!, new: true)
            Plum.shared.play()
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
        //let words = searchString?.components(separatedBy: " ")
        filteredArtists = artists?.filter{
//            $0.name.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "_", with: "").lowercased().range(of: (searchString?.lowercased())!) != nil
            $0.name.lowercased().range(of: (searchString?.lowercased())!) != nil
        }
        filteredAlbums = albums?.filter{
//            $0.name?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "_", with: "").lowercased().range(of: (searchString?.lowercased())!) != nil
            $0.name?.lowercased().range(of: (searchString?.lowercased())!) != nil
        }
        filteredSongs = songs?.filter{
            $0.title?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "'", with: "").lowercased().range(of: (searchString?.lowercased())!) != nil
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
        headers.append(header)
        header.setup(title: "albums", count: (filteredAlbums?.count)!)
        headers.append(header)
        header.setup(title: "songs", count: (filteredSongs?.count)!)
        headers.append(header)
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
}
