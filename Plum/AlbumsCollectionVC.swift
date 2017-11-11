//
//  AlbumsCollectionVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 25.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumsCollectionVC: UIViewController {
    
    var albums: [AlbumB]!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indexView: CollectionIndexView!
    var pickedID: MPMediaEntityPersistentID!
    var indexes = [String]()
    var result = [String: [AlbumB]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.theme
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.setup()
        self.indexView.indexes = self.indexes
        self.indexView.collectionView = self.collectionView
        self.indexView.setup()
    }

    @IBAction func NPBtnPressed(_ sender: Any){
        performSegue(withIdentifier: "nowPlaying", sender: nil)
    }

}

extension AlbumsCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return indexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (result[indexes[section]]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumsCollectionCell
        cell.setup(album: (result[indexes[indexPath.section]]?[indexPath.row])!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = result[indexes[indexPath.section]]?[indexPath.row]
        pickedID = album?.ID
        performSegue(withIdentifier: "album", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC{
            destination.receivedID = self.pickedID
        }
    }
    
    func setup(){
        let letters = Array("aąbcćdeęfghijklmnoópqrsśtuvwxyzżź".characters)
        let numbers = Array("0123456789".characters)
        albums = musicQuery.shared.allAlbums()
        let bcount = albums.count
        result["#"] = []
        result["?"] = []
        var inLetters = 0
        var stoppedAt = 0
        while inLetters < letters.count{
            let smallLetter = letters[inLetters]
            let letter = String(letters[inLetters]).uppercased()
            result[letter] = []
            for i in stoppedAt ..< bcount{
                let curr = albums[i]
                let layLow = curr.name?.lowercased()
                if layLow?.firstLetter() == smallLetter{
                    result[letter]?.append(curr)
                    if !indexes.contains(letter) {indexes.append(letter)}
                }else if numbers.contains((layLow!.firstLetter())){
                    result["#"]?.append(curr)
                    if !indexes.contains("#") {indexes.append("#")}
                }else if layLow?.firstLetter() == "_"{
                    result["?"]?.append(curr)
                    if !indexes.contains("?") {indexes.append("?")}
                }else{
                    //print("stopped at: \(curr.name)")
                    stoppedAt = i
                    break
                }
            }
            inLetters += 1
        }
    }

}
