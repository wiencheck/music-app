//
//  SixNowPlayingVC.swift
//  Plum
//
//  Created by Adam Wienconek on 10.04.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class SixNowPlayingVC: NowPlayingViewController {
    
    @IBOutlet weak var artLyrView: UIView!
    @IBOutlet weak var queueView: UIView!
    @IBOutlet weak var ratingsView: UIView!
    
    @IBOutlet weak var volumeView: MPVolumeView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var lyricsView: FadedTextView!
    @IBOutlet weak var lyricsBackgroundView: UIView!
    @IBOutlet weak var queueImageView: UIImageView!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var shuffleImageView: UIImageView!
    @IBOutlet weak var repeatImageView: UIImageView!
    
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var outOfLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var elapsedLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var playbackBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var queueBtn: UIButton!
    
    var queueTabBar: UITabBarController?
    
    var currentItem: MPMediaItem {
        guard let item = player.currentItem else { return MPMediaItem() }
        return item
    }
    var previousItem: MPMediaItem?
    var timer = Timer()
    var statusBarStyle: UIStatusBarStyle = .default
    let lightStyle = false
    var shouldUpdateSlider = true
    var flipped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleNotifications()
        setTimer()
        setSlider()
        customizeVolumeSlider()
        customizeTimeSlider()
        updateTrackInfo()
        setImages()
        addGestures()
        setRatingsPan()
        setRatingsTap()
        queueView.isHidden = true
        lyricsView.alpha = 0
        lyricsBackgroundView.alpha = 0
        ratingsView.alpha = 0
        tab.popupContentView.popupInteractionGestureRecognizer.delegate = self
        volumeView.showsRouteButton = false
        NotificationCenter.default.addObserver(self, selector: #selector(wirelessRouteChanged), name: Notification.Name.MPVolumeViewWirelessRoutesAvailableDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = statusBarStyle
    }
    
    @objc func wirelessRouteChanged() {
        if volumeView.areWirelessRoutesAvailable {
            volumeView.showsRouteButton = true
        } else {
            volumeView.showsRouteButton = false
        }
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func setSlider() {
        timeSlider.minimumValue = 0
    }
    
    func handleNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTrackInfo), name: .trackChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtons), name: .playbackChanged, object: nil)
    }
    
    @objc func updateTrackInfo() {
        //timer.fire()
        titleLabel.text = currentItem.title ?? "Unknown title"
        artistLabel.text = currentItem.artist ?? "Unknown artist"
        albumLabel.text = currentItem.albumTitle ?? "Unknown album"
        if let artwork = currentItem.artwork?.image(at: CGSize(width: 500, height: 500)) {
            artworkView.image = artwork
        } else {
            artworkView.image = #imageLiteral(resourceName: "no_now")
        }
        timeSlider.maximumValue = Float(currentItem.playbackDuration)
        outOfLabel.text = player.labelString(type: "out of")
        if let url = currentItem.assetURL {
            let asset = AVAsset(url: url)
            if let lyrics = asset.lyrics {
                lyricsView.text = lyrics
            } else {
                lyricsView.text = "\n\n\n\nNo lyrics found"
            }
        }
        setImages()
        if let p = previousItem {
            if flipped && p.albumTitle != currentItem.albumTitle {
                if let artwork = currentItem.artwork?.image(at: CGSize(width: 100, height: 100)) {
                    queueImageView.image = artwork
                } else {
                    queueImageView.image = #imageLiteral(resourceName: "no_now")
                }
                UIView.transition(with: queueImageView, duration: 0.6, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            }
        }
        showRating()
        previousItem = currentItem
    }
    
    @objc func updateTime() {
        elapsedLabel.text = "\(player.player.currentTime.calculateFromTimeInterval().minute):\(player.player.currentTime.calculateFromTimeInterval().second)"
        let remainingTime = currentItem.playbackDuration - player.player.currentTime
        remainingLabel.text = "\(remainingTime.calculateFromTimeInterval().minute):\(remainingTime.calculateFromTimeInterval().second)"
        if(!timeSlider.isTracking){
            shouldUpdateSlider = true
        }else{
            shouldUpdateSlider = false
        }
        if shouldUpdateSlider{
            timeSlider.value = Float(player.player.currentTime)
        }
    }
    
    @objc func updateButtons() {
        if player.isPlayin() {
            playbackBtn.setImage(#imageLiteral(resourceName: "pause-butt"), for: .normal)
        } else {
            playbackBtn.setImage(#imageLiteral(resourceName: "play-butt"), for: .normal)
        }
    }
    
    func setImages() {
        let size = CGSize(width: 70, height: 44)
        nextBtn.setImage(#imageLiteral(resourceName: "next-butt").imageScaled(toFit: size).withRenderingMode(.alwaysTemplate), for: .normal)
        prevBtn.setImage(#imageLiteral(resourceName: "prev-butt").imageScaled(toFit: size).withRenderingMode(.alwaysTemplate), for: .normal)
        addImageView.layer.cornerRadius = 8
        queueImageView.layer.cornerRadius = 8
        if player.isPlayin() {
            playbackBtn.setImage(#imageLiteral(resourceName: "pause-butt").withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            playbackBtn.setImage(#imageLiteral(resourceName: "play-butt").withRenderingMode(.alwaysTemplate), for: .normal)
        }
        if player.isShuffle {
            shuffleImageView.image = #imageLiteral(resourceName: "shuffle").withRenderingMode(.alwaysTemplate).tintPictogram(with: .orange)
        } else {
            shuffleImageView.image = #imageLiteral(resourceName: "shuffle").withRenderingMode(.alwaysTemplate).tintPictogram(with: .gray)
        }
        if player.isRepeat {
            repeatImageView.image = #imageLiteral(resourceName: "repeat").withRenderingMode(.alwaysTemplate).tintPictogram(with: .orange)
        } else {
            repeatImageView.image = #imageLiteral(resourceName: "repeat").withRenderingMode(.alwaysTemplate).tintPictogram(with: .gray)
        }
    }
    
    func customizeVolumeSlider() {
        let temp = volumeView.subviews
        for current in temp {
            if current.isKind(of: UISlider.self) {
                let tempSlider = current as! UISlider
                let size = CGSize(width: 160, height: 18)
                let minT = #imageLiteral(resourceName: "six_sliderMin").imageScaled(toFit: size)
                let maxT = #imageLiteral(resourceName: "six_sliderMax").imageScaled(toFit: size)
                tempSlider.setMinimumTrackImage(minT, for: .normal)
                tempSlider.setMaximumTrackImage(maxT, for: .normal)
            }
        }
    }
    
    func customizeTimeSlider() {
        let size = CGSize(width: 160, height: 18)
        let minT = #imageLiteral(resourceName: "six_sliderMin").imageScaled(toFit: size)
        let maxT = #imageLiteral(resourceName: "six_sliderMax").imageScaled(toFit: size)
        timeSlider.setMinimumTrackImage(minT, for: .normal)
        timeSlider.setMaximumTrackImage(maxT, for: .normal)
    }
}

/* Actions and gestures */
extension SixNowPlayingVC: UIGestureRecognizerDelegate {
    
    private func addGestures() {
        let artworkTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapOnArtwork(_:)))
        artworkTap.numberOfTapsRequired = 1
        artworkTap.numberOfTouchesRequired = 1
        artworkView.isUserInteractionEnabled = true
        artworkView.addGestureRecognizer(artworkTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        artworkView.addGestureRecognizer(doubleTap)
        lyricsView.isUserInteractionEnabled = true
        lyricsView.addGestureRecognizer(doubleTap)
        
        let lyricsTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapOnLyrics(_:)))
        lyricsTap.numberOfTapsRequired = 1
        lyricsTap.numberOfTouchesRequired = 1
        lyricsView.addGestureRecognizer(lyricsTap)
        artworkTap.require(toFail: doubleTap)
        lyricsTap.require(toFail: doubleTap)
    }
    
    @objc func handleSingleTapOnArtwork(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView.alpha = 1.0
            self.lyricsBackgroundView.alpha = 1.0
            self.ratingsView.alpha = 1.0
        })
    }
    
    @objc func handleSingleTapOnLyrics(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView.alpha = 0.0
            self.lyricsBackgroundView.alpha = 0.0
            self.ratingsView.alpha = 0.0
        })
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        flipQueue()
    }
    
    @IBAction func scrubAudio(_ sender: UISlider) {
        shouldUpdateSlider = false
        player.player.currentTime = TimeInterval(sender.value)
    }
    
    @IBAction func addBtnPressed() {
        presentPicker()
    }
    
    @IBAction func queueBtnPressed() {
        flipQueue()
    }
    
    func flipQueue() {
        if !flipped {
            if let artwork = currentItem.artwork?.image(at: CGSize(width: 100, height: 100)) {
                queueImageView.image = artwork
            } else {
                queueImageView.image = #imageLiteral(resourceName: "no_now")
            }
            UIView.transition(with: queueImageView, duration: 0.6, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            UIView.transition(with: artLyrView, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                self.artLyrView.isHidden = true
            }, completion: nil)
            UIView.transition(with: queueView, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                self.queueView.isHidden = false
            }, completion: nil)
        } else {
            queueImageView.image = #imageLiteral(resourceName: "six_queueBtn")
            UIView.transition(with: queueImageView, duration: 0.6, options: .transitionFlipFromRight, animations: nil, completion: nil)
            UIView.transition(with: queueView, duration: 0.6, options: .transitionFlipFromRight, animations: {
                self.queueView.isHidden = true
            }, completion: nil)
            UIView.transition(with: artLyrView, duration: 0.6, options: .transitionFlipFromRight, animations: {
                self.artLyrView.isHidden = false
            }, completion: nil)
        }
        flipped = !flipped
    }
    
    @IBAction func playbackBtnPressed() {
        player.togglePlayPause()
        if player.isPlayin() {
            setTimer()
            timer.fire()
        } else {
            timer.invalidate()
        }
    }
    
    @IBAction func prevBtnPressed() {
        if(player.isPlayin()){
            player.prev()
            player.play()
        }else{
            player.prev()
        }
    }
    
    @IBAction func nextBtnPressed() {
        if player.isPlayin() {
            player.next()
            player.play()
        } else {
            player.next()
        }
    }
    
    @IBAction func shufflePressed() {
        if player.isShuffle {
            player.disableShuffle()
            shuffleImageView.image = #imageLiteral(resourceName: "shuffle").withRenderingMode(.alwaysTemplate).tintPictogram(with: .gray)
        }else{
            player.shuffleCurrent()
            shuffleImageView.image = #imageLiteral(resourceName: "shuffle").withRenderingMode(.alwaysTemplate).tintPictogram(with: .orange)
        }
        outOfLabel.text = player.labelString(type: "out of")
    }
    
    @IBAction func repeatPressed() {
        if !player.isRepeat {
            repeatImageView.image = #imageLiteral(resourceName: "repeat").withRenderingMode(.alwaysTemplate).tintPictogram(with: .orange)
            player.repeatMode(true)
        } else {
            repeatImageView.image = #imageLiteral(resourceName: "repeat").withRenderingMode(.alwaysTemplate).tintPictogram(with: .gray)
            player.repeatMode(false)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func setRatingsPan(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panOnRatings(_:)))
        ratingLabel.addGestureRecognizer(pan)
        ratingLabel.isUserInteractionEnabled = true
    }
    
    func setRatingsTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnRatings(_:)))
        ratingLabel.addGestureRecognizer(tap)
        ratingLabel.isUserInteractionEnabled = true
    }
    
    @objc func panOnRatings(_ sender: UIPanGestureRecognizer){
        let location = sender.location(in: ratingLabel)
        let procent = location.x / ratingLabel.bounds.maxX * 100
        if procent <= 0.0{
            rateItem(rating: 0)
        }
        if procent > 0.0 && procent <= 20.0{
            rateItem(rating: 1)
        }
        if procent > 20.0 && procent <= 40.0{
            rateItem(rating: 2)
        }
        if procent > 40.0 && procent <= 60.0{
            rateItem(rating: 3)
        }
        if procent > 60.0 && procent <= 80.0{
            rateItem(rating: 4)
        }
        if procent > 80.0 && procent <= 100.0{
            rateItem(rating: 5)
        }
    }
    
    @objc func tapOnRatings(_ sender: UITapGestureRecognizer){
        let location = sender.location(in: ratingLabel)
        let procent = location.x / ratingLabel.bounds.maxX * 100
        if procent <= 0.0{
            rateItem(rating: 0)
        }
        if procent > 0.0 && procent <= 20.0{
            rateItem(rating: 1)
        }
        if procent > 20.0 && procent <= 40.0{
            rateItem(rating: 2)
        }
        if procent > 40.0 && procent <= 60.0{
            rateItem(rating: 3)
        }
        if procent > 60.0 && procent <= 80.0{
            rateItem(rating: 4)
        }
        if procent > 80.0 && procent <= 100.0{
            rateItem(rating: 5)
        }
    }
    
    func rateItem(rating: Int){
        switch rating {
        case 1:
            ratingLabel.text = "★ ☆ ☆ ☆ ☆"
        case 2:
            ratingLabel.text = "★ ★ ☆ ☆ ☆"
        case 3:
            ratingLabel.text = "★ ★ ★ ☆ ☆"
        case 4:
            ratingLabel.text = "★ ★ ★ ★ ☆"
        case 5:
            ratingLabel.text = "★ ★ ★ ★ ★"
        default:
            ratingLabel.text = "☆ ☆ ☆ ☆ ☆"
        }
        player.rateItem(rating: rating)
    }
    
    func showRating(){
        let rating = player.currentItem?.rating ?? 0
        switch rating {
        case 1:
            ratingLabel.text = "★ ☆ ☆ ☆ ☆"
        case 2:
            ratingLabel.text = "★ ★ ☆ ☆ ☆"
        case 3:
            ratingLabel.text = "★ ★ ★ ☆ ☆"
        case 4:
            ratingLabel.text = "★ ★ ★ ★ ☆"
        case 5:
            ratingLabel.text = "★ ★ ★ ★ ★"
        default:
            ratingLabel.text = "☆ ☆ ☆ ☆ ☆"
        }
    }
}

extension SixNowPlayingVC: MPMediaPickerControllerDelegate {
    
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
        outOfLabel.text = player.labelString(type: "out of")
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let newDestination = destination as? UITabBarController {
            queueTabBar = newDestination
        }
    }
    
}

extension SixNowPlayingVC: UpNextDelegate {
    
    func presentQueue(){
        let pickedID = player.currentItem?.albumPersistentID
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
    }
    
    func backFromUpNext() {
        self.outOfLabel.text = player.labelString(type: "out of")
    }
    
}

/* Queue screen */
extension SixNowPlayingVC {
    
    @IBAction func queueSegmentPressed() {
        queueTabBar?.selectedIndex = 0
    }
    
    @IBAction func albumSegmentPressed() {
        queueTabBar?.selectedIndex = 1
    }
    
    @IBAction func artistSegmentPressed() {
        queueTabBar?.selectedIndex = 2
    }
    
}
