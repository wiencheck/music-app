//
//  NineNPVC.swift
//  Plum
//
//  Created by Adam Wienconek on 04.02.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class NineNPVC: NowPlayingViewController {
    
    let player = Plum.shared
    var items = [MPMediaItem]()
    var mediaPicker: MPMediaPickerController!
    var pickedID: MPMediaEntityPersistentID!
    
    //
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var lyricsTextView :UITextView!
    
    //Labels
    @IBOutlet weak var titleLabel :UILabel!
    @IBOutlet weak var detailLabel :UILabel!
    @IBOutlet weak var elapsedLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    
    //Buttons
    @IBOutlet weak var playbackBtn :UIButton!
    @IBOutlet weak var nextBtn :UIButton!
    @IBOutlet weak var prevBtn :UIButton!
    @IBOutlet weak var shufBtn :UIButton!
    @IBOutlet weak var repBtn :UIButton!
    @IBOutlet weak var addNextBtn: UIButton!
    @IBOutlet weak var upNextBtn: UIButton!
    @IBOutlet weak var lyricsButton: UIButton!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var minVolImg: UIImageView!
    @IBOutlet weak var maxVolImg: UIImageView!
    var timer: Timer!
    var shouldUpdateSlider = true
    var interval: TimeInterval = 0.05
    
    
    var lightStyle: Bool! = false
    var cellSize: CGSize!
    var currentItem: MPMediaItem! { get { return player.currentItem } }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .trackChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaybackBtn), name: .playbackChanged, object: nil)
        setSlider()
        //setImages()
        timer.fire()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .queueChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .trackChanged, object: nil)
        //NotificationCenter.default.removeObserver(self, name: .playbackChanged, object: nil)
    }
    
    @objc func updatePlaybackBtn() {
        if player.isPlayin() {
            playbackBtn.setImage(#imageLiteral(resourceName: "pause-butt"), for: .normal)
        }else{
            playbackBtn.setImage(#imageLiteral(resourceName: "play-butt"), for: .normal)
        }
    }
    
    @objc func updateUI() {
        let artsize = CGSize(width: view.frame.width, height: view.frame.width)
        if let art = currentItem.artwork?.image(at: artsize) {
            artworkView.image = art
        }else{
            artworkView.image = #imageLiteral(resourceName: "no_now")
        }
        refreshLabels()
    }
    
    @objc func refreshLabels() {
        titleLabel.text = currentItem.title
        detailLabel.text = (currentItem.albumArtist ?? "Unknown artist") + " - " + (currentItem.albumTitle ?? "Unknown album")
        //detailLabel.text = "\(currentItem.albumArtist) - \(currentItem.albumTitle)"
    }
    
    @objc func updateTimes(){
        elapsedLabel.text = "\(player.calculateFromTimeInterval(TimeInterval(timeSlider.value)).minute):\(player.calculateFromTimeInterval(TimeInterval(timeSlider.value)).second)"
        remainingLabel.text = "-\(player.calculateFromTimeInterval(TimeInterval(timeSlider.maximumValue - timeSlider.value)).minute):\(player.calculateFromTimeInterval(TimeInterval(timeSlider.maximumValue - timeSlider.value)).second)"
        if(!timeSlider.isTracking){
            shouldUpdateSlider = true
        }else{
            shouldUpdateSlider = false
        }
        if shouldUpdateSlider{
            timeSlider.value = Float(player.player.currentTime)
        }
    }
    
    @objc func scrubAudio(){
        shouldUpdateSlider = false
        player.player.currentTime = TimeInterval(timeSlider.value)
    }
    
    func setImages() {
        prevBtn.setImage(#imageLiteral(resourceName: "prev-butt"), for: .normal)
        nextBtn.setImage(#imageLiteral(resourceName: "next-butt"), for: .normal)
        addNextBtn.setImage(#imageLiteral(resourceName: "add").imageScaled(toFit: CGSize(width: 21, height: 21)).withRenderingMode(.alwaysTemplate), for: .normal)
        // 10 18 18 18
        let min = #imageLiteral(resourceName: "zeroVol").imageScaled(toFit: CGSize(width: 10, height: 18))
        let max = #imageLiteral(resourceName: "maxVol").imageScaled(toFit: CGSize(width: 18, height: 18))
        minVolImg.image = min?.withRenderingMode(.alwaysTemplate)
        maxVolImg.image = max?.withRenderingMode(.alwaysTemplate)
        if player.isPlayin() {
            playbackBtn.setImage(#imageLiteral(resourceName: "pause-butt"), for: .normal)
        }else{
            playbackBtn.setImage(#imageLiteral(resourceName: "play-butt"), for: .normal)
        }
        ratingButton.clipsToBounds = true
        lyricsButton.clipsToBounds = true
        ratingButton.layer.cornerRadius = 3
        lyricsButton.layer.cornerRadius = 3
        upNextBtn.setImage(#imageLiteral(resourceName: "Ulist_icon"), for: .normal)
        upNextBtn.imageView?.contentMode = .scaleAspectFit
    }
    
    func setSlider(){
        timeSlider.addTarget(self, action: #selector(NineNPVC.scrubAudio), for: .valueChanged)
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(NineNPVC.updateTimes), userInfo: nil, repeats: true)
        timeSlider.isContinuous = false
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
        player.next()
        player.play()
    }
    
    @IBAction func prev() {
        //refreshLabels()
        player.prev()
        player.play()
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
