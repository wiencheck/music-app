//
//  NineNPVC.swift
//  Plum
//
//  Created by Adam Wienconek on 04.02.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class NineNPVC: UIViewController {
    
    var tab: UITabBarController!    //Controller managing LNPopup
    let player = Plum.shared
    var items = [MPMediaItem]()
    var mediaPicker: MPMediaPickerController!
    var pickedID: MPMediaEntityPersistentID!
    
    //
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lyricsTextView :UITextView!
    
    //Labels
    @IBOutlet weak var titleLabel :UILabel!
    @IBOutlet weak var detailLabel :UILabel!
    
    //Buttons
    @IBOutlet weak var playbackBtn :UIButton!
    @IBOutlet weak var nextBtn :UIButton!
    @IBOutlet weak var prevBtn :UIButton!
    @IBOutlet weak var shufBtn :UIButton!
    @IBOutlet weak var repBtn :UIButton!
    
    var lightStyle: Bool! = false
    var cellSize: CGSize!
    var currentIndex = 0
    var previousIndex = 0
    var usrCurrentIndex = 0
    var currentItem: MPMediaItem! { get { return player.currentItem } }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .queueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .trackChanged, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(scrollToCurrent), name: .playbackChanged, object: nil)
        setupCollection()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .queueChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .trackChanged, object: nil)
        //NotificationCenter.default.removeObserver(self, name: .playbackChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollToCurrent()
    }
    
    func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        let width = view.frame.width
        cellSize = CGSize(width: width, height: width)
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.allowsSelection = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    @objc func refreshData() {
        items = player.getCurrentQueue()
        print("Refresh data")
        collectionView.reloadData()
    }
    
    @objc func scrollToCurrent() {
        print("Scroll to current")
        var row = 0
        if player.isUsrQueue {
            row = player.defIndex + player.usrIndex
        }else{
            row = player.defIndex
        }
        let path = IndexPath(row: row, section: 0)
        collectionView.scrollToItem(at: path, at: .left, animated: true)
        let offset = collectionView.contentOffset.x
        currentIndex = Int(offset / cellSize.width)
        previousIndex = currentIndex
    }
    
    @objc func updateUI() {
        print("Update UI")
        print(currentItem.title)
        refreshLabels()
    }
    
    @objc func refreshLabels() {
        titleLabel.text = currentItem.title
        //detailLabel.text = "\(currentItem.albumArtist) - \(currentItem.albumTitle)"
    }
    
    

}

extension NineNPVC {    //@IBActions
    
    @IBAction func playbackBtn(_ sender: Any) {
        //tab.popupContentView.popupInteractionGestureRecognizer.isEnabled = false
        if(player.isPlayin()){
            playbackBtn.setImage(#imageLiteral(resourceName: "play-butt"), for: .normal)
            player.pause()
        }else{
            playbackBtn.setImage(#imageLiteral(resourceName: "pause-butt"), for: .normal)
            player.play()
        }
    }
    
    @IBAction func next() {
        if currentIndex == items.count-1 {                      //If last
            let path = IndexPath(row: 0, section: 0)
            if items[0].albumTitle == items[currentIndex].albumTitle {
                collectionView.scrollToItem(at: path, at: .left, animated: false)
            }else{
                collectionView.scrollToItem(at: path, at: .left, animated: true)
            }
            currentIndex = 0
        }else{                                                  //Normal
            let path = IndexPath(row: currentIndex+1, section: 0)
            if items[currentIndex+1].albumTitle == items[currentIndex].albumTitle {
                collectionView.scrollToItem(at: path, at: .left, animated: false)
            }else{
                collectionView.scrollToItem(at: path, at: .left, animated: true)
            }
            currentIndex += 1
        }
        refreshLabels()
        //refresh()
        print("current = \(currentIndex)")
        print("previous = \(previousIndex)")
        player.next()
        player.play()
        previousIndex = currentIndex
    }
    
    @IBAction func prev() {
        if currentIndex == 0 {
            let path = IndexPath(row: items.count-1, section: 0)
            if items[items.count-1].albumTitle == items[currentIndex].albumTitle {
                collectionView.scrollToItem(at: path, at: .left, animated: false)
            }else{
                collectionView.scrollToItem(at: path, at: .left, animated: true)
            }
            currentIndex = items.count-1
        }else{
            let path = IndexPath(row: currentIndex-1, section: 0)
            if items[currentIndex-1].albumTitle == items[currentIndex].albumTitle {
                collectionView.scrollToItem(at: path, at: .left, animated: false)
            }else{
                collectionView.scrollToItem(at: path, at: .left, animated: true)
            }
            currentIndex -= 1
        }
        //refreshLabels()
        player.prev()
        player.play()
        previousIndex = currentIndex
    }
    
}

extension NineNPVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NowPlayingCell
        if let art = items[indexPath.row].artwork?.image(at: cellSize) {
            cell.artwork.image = art
        }else{
            cell.artwork.image = #imageLiteral(resourceName: "no_now")
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        currentIndex = Int(offset / cellSize.width)
        print("current = \(currentIndex)")
        print("previous = \(previousIndex)")
        if currentIndex != previousIndex {
            if currentIndex > previousIndex {
                let roznica = currentIndex-previousIndex
                print("roznica = \(roznica)")
                for _ in 0..<roznica {
                    player.next()
                }
            }else{
                let roznica = previousIndex-currentIndex
                print("roznica = \(roznica)")
                for _ in 0..<roznica {
                    player.player.currentTime = 0.0
                    player.prev()
                }
            }
        }
//        if currentIndex != previousIndex {
//            if player.isUsrQueue && player.usrIsAnyAfter {
////                if currentIndex > previousIndex {
////                    usrCurrentIndex += 1
////                }else{
////                    usrCurrentIndex -= 1
////                }
//                usrCurrentIndex = player.usrIndex+1
//                player.playFromUsrQueue(index: currentIndex-player.defIndex)
//                if !player.usrIsAnyAfter { player.clearQueue() }
//            }else{
//                currentIndex -= usrCurrentIndex
//                //usrCurrentIndex = 0
//                if player.isShuffle {
//                    player.playFromShufQueue(index: currentIndex, new: true)
//                }else{
//                    player.playFromDefQueue(index: currentIndex, new: true)
//                }
//            }
//            player.play()
//            refreshLabels()
//        }
        player.play()
        refreshLabels()
        previousIndex = currentIndex
        //Enable drag-down gesture
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Disable drag-down gesture
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
}

extension NineNPVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}

extension NineNPVC: MPMediaPickerControllerDelegate {
    
    @IBAction func pickerBtnPressed() {
        presentPicker()
    }
    
    func presentPicker() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = true
        mediaPicker.showsCloudItems = false
        mediaPicker.prompt = "Add new songs to queue"
        mediaPicker.modalTransitionStyle = .coverVertical
        present(mediaPicker, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for picked in mediaItemCollection.items{
            player.addLast(item: picked)
        }
        mediaPicker.dismiss(animated: true, completion: nil)
        //outOfLabel.text = player.labelString(type: "out of")
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
}

extension NineNPVC: UpNextDelegate {
    
    @IBAction func queueBtnPressed() {
        realPresent()
    }
    
    func realPresent(){
        pickedID = player.currentItem?.albumPersistentID
        let tbvc = storyboard?.instantiateViewController(withIdentifier: "GOGOGO") as! UpNextTabBarController
        tbvc.upDelegate = self
        if let upvc = tbvc.viewControllers?[0] as? QueueVC{
            upvc.lightTheme = lightStyle
        }
        if let alvc = tbvc.viewControllers?[1] as? AlbumUpVC{
            alvc.receivedID = pickedID
            alvc.lightTheme = lightStyle
        }
        if let arvc = tbvc.viewControllers?[2] as? ArtistUpVCB{
            arvc.receivedID = pickedID
            arvc.lightTheme = lightStyle
        }
        tbvc.modalPresentationStyle = .overCurrentContext
        tbvc.modalTransitionStyle = .coverVertical
        present(tbvc, animated: true, completion: nil)
        //presentDetail(tbvc)
    }
    
    func backFromUpNext() {
        //self.outOfLabel.text = player.labelString(type: "out of")
    }
    
}
