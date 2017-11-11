//
//  ViewController.swift
//  myPlayer
//
//  Created by Adam Wienconek on 26.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class NowPlayingVC: UIViewController, UpNextProtocol, UIGestureRecognizerDelegate{
    
    var scale = 30
    
    let player = Plum.shared
    @IBOutlet weak var volView: UIView!
    var mpVolView: MPVolumeView!
    var passStyle: viewLayout!
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var playbackBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var shufBtn: UIButton!
    @IBOutlet weak var elapsedLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var backgroundImgView: UIImageView!
    @IBOutlet weak var minVolImg: UIImageView!
    @IBOutlet weak var maxVolImg: UIImageView!
    @IBOutlet weak var upperBar: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var upNextBtn: UIButton!
    @IBOutlet weak var outOfLabel: UILabel!
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var shufView: UIView!
    var pickedID: MPMediaEntityPersistentID!
    var doubleTapArt: UITapGestureRecognizer!
    var doubleTapLyr: UITapGestureRecognizer!
    var colors: UIImageColors!

    var lightBar: Bool!
    let pauseB = #imageLiteral(resourceName: "pause-butt")
    var image: UIImage!
    var imageB: UIImage!
    var timer: Timer!
    var shouldUpdateSlider = true
    var interval: TimeInterval = 0.05
    var playImg = [#imageLiteral(resourceName: "prev-butt"), #imageLiteral(resourceName: "play-butt"), #imageLiteral(resourceName: "pause-butt"), #imageLiteral(resourceName: "next-butt"), #imageLiteral(resourceName: "thumb"), #imageLiteral(resourceName: "thumb2"), #imageLiteral(resourceName: "track"), #imageLiteral(resourceName: "blackS"), #imageLiteral(resourceName: "zeroVol"), #imageLiteral(resourceName: "maxVol"), #imageLiteral(resourceName: "list"), #imageLiteral(resourceName: "dot"), #imageLiteral(resourceName: "star"), #imageLiteral(resourceName: "shuf")]
    var templates = [UIImage]()
    
    deinit{
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setTemplates()
        setArtworkDoubleTap()
        setLabelTap()
        setRatingsPan()
        setRatingsTap()
        setArtworkTap()
        setLyricsDoubleTap()
        setLyricsView()
        setVolumeView()
        setSlider()
        prevBtn.setImage(templates[0], for: .normal)
        nextBtn.setImage(templates[3], for: .normal)
        minVolImg.image = templates[8]
        maxVolImg.image = templates[9]
        //shufBtn.setImage(templates[13], for: .normal)
        shufView.layer.cornerRadius = 6.0
        mpVolView.setVolumeThumbImage(templates[4], for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
        timer.fire()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(player.wasLoaded == false){
            nextBtn.isEnabled = false
            prevBtn.isEnabled = false
            playbackBtn.isEnabled = false
        }
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
        timer.invalidate()
        UIApplication.shared.statusBarStyle = .default
    }
    
    @objc func updateUI(){
        if(player.currentItem != nil){
            titleLabel.text = player.labelString(type: "title")
            detailLabel.text = player.labelString(type: "detail")
            image = player.currentItem?.artwork?.image(at: artworkImage.bounds.size) ?? #imageLiteral(resourceName: "no_music")
        }else{
            titleLabel.text = "Choose a song"
            detailLabel.text = "to play"
            image = #imageLiteral(resourceName: "no_music")
        }
        if(player.isPlayin()){
            playbackBtn.setImage(templates[2], for: .normal)
        }else{
            playbackBtn.setImage(templates[1], for: .normal)
        }
        artworkImage.image = image
        magic(albumArt: image)
        outOfLabel.text = player.labelString(type: "out of")
        timeSlider.setValue(0, animated: false)
        timeSlider.maximumValue = Float(player.player.duration)
        showRating()
        if player.currentItem != nil{
            let ass = AVAsset(url: (player.currentItem?.assetURL)!)
            let lyr = ass.lyrics
            if lyr?.characters.count == 0{
                lyricsTextView.text = "\n\n\n\n\n\nNo lyrics available :(\n\nYou can add them in iTunes\non your Mac or PC\n"
            }else{
                lyricsTextView.text = lyr
            }
        }
        lyricsTextView.textColor = .white
        lyricsTextView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    @IBAction func playBackBtn(_ sender: Any) {
        if(player.isPlayin()){
            playbackBtn.setImage(templates[1], for: .normal)
            player.pause()
        }else{
            playbackBtn.setImage(templates[2], for: .normal)
            player.play()
        }
    }
    @IBAction func nextBtn(_ sender: Any) {
        if(player.isPlayin()){
            player.next()
            player.play()
        }else{
            player.next()
        }
    }
    @IBAction func prevBtn(_ sender: Any) {
        if(player.isPlayin()){
            player.prev()
            player.play()
        }else{
            player.prev()
        }
    }
    
    @IBAction func shuffleBtn(_ sender: Any) {
        if(player.isShuffle){
            player.disableShuffle()
        }else{
            player.shuffleCurrent()
        }
        outOfLabel.text = player.labelString(type: "out of")
        magic(albumArt: image)
    }
    
    @IBAction func modalBtn(_ sender: Any) {
    }
    
    @objc func updateTimes(){
        elapsedLabel.text = "\(player.calculateFromTimeInterval(TimeInterval(timeSlider.value)).minute):\(player.calculateFromTimeInterval(TimeInterval(timeSlider.value)).second)"
        remainingLabel.text = "-\(player.calculateFromTimeInterval(TimeInterval(timeSlider.maximumValue - timeSlider.value)).minute):\(player.calculateFromTimeInterval(TimeInterval(timeSlider.maximumValue - timeSlider.value)).second)"
        if(!timeSlider.isTracking){
            shouldUpdateSlider = true
        }else{
            shouldUpdateSlider = false
        }
        if(shouldUpdateSlider == true){
            timeSlider.value = Float(player.player.currentTime)
        }
    }
    
    @objc func scrubAudio(){
        shouldUpdateSlider = false
        player.player.currentTime = TimeInterval(timeSlider.value)
    }
    
    func magic(albumArt: UIImage){
        colors = albumArt.getColors(scaleDownSize: CGSize(width: scale, height: scale))
        self.view.backgroundColor = colors.backgroundColor
        self.titleLabel.textColor = colors.primaryColor
        self.detailLabel.textColor = colors.detailColor
        self.elapsedLabel.textColor = colors.detailColor
        self.remainingLabel.textColor = colors.detailColor
        doneBtn.tintColor = colors.detailColor
        upNextBtn.tintColor = colors.detailColor
        outOfLabel.textColor = colors.primaryColor
        timeSlider.setMinimumTrackImage(#imageLiteral(resourceName: "track"), for: .normal)
        timeSlider.setMaximumTrackImage(#imageLiteral(resourceName: "track"), for: .normal)
        timeSlider.setThumbImage(#imageLiteral(resourceName: "thumb2"), for: .normal)
        ratingLabel.textColor = colors.primaryColor
        if(colors.backgroundColor.isDarkColor){
            UIApplication.shared.statusBarStyle = .lightContent
            lightBar = true
            prevBtn.tintColor = .white
            playbackBtn.tintColor = .white
            nextBtn.tintColor = .white
            minVolImg.tintColor = .white
            maxVolImg.tintColor = .white
            mpVolView.tintColor = colors.primaryColor
            passStyle = viewLayout(prim: colors.primaryColor, sec: colors.detailColor, back: colors.backgroundColor, cell: .white, dark: true)
        }else{
            UIApplication.shared.statusBarStyle = .default
            lightBar = false
            prevBtn.tintColor = colors.primaryColor
            playbackBtn.tintColor = colors.primaryColor
            nextBtn.tintColor = colors.primaryColor
            minVolImg.tintColor = colors.primaryColor
            maxVolImg.tintColor = colors.primaryColor
            mpVolView.tintColor = colors.detailColor
            passStyle = viewLayout(prim: colors.primaryColor, sec: colors.detailColor, back: colors.backgroundColor, cell: .black, dark: false)
        }
        if(player.isShuffle){
            shufBtn.setTitle("Shuffle on", for: .normal)
            shufBtn.setTitleColor(colors.detailColor, for: .normal)
            //shufBtn.tintColor = colors.detailColor
            shufView.backgroundColor = colors.primaryColor.withAlphaComponent(0.3)
        }else{
            shufBtn.setTitle("Shuffle off", for: .normal)
            shufBtn.setTitleColor(colors.primaryColor, for: .normal)
            //shufBtn.tintColor = colors.primaryColor
            shufView.backgroundColor = .clear
        }
    }
    
    func setTemplates(){
        templates.removeAll()
        for i in 0 ..< playImg.count{
            templates.append(playImg[i].withRenderingMode(.alwaysTemplate))
        }
    }
    
    @IBAction func presentQueue(_ sender: Any){
        realPresent()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any){
        _ = navigationController?.popViewController(animated: true)
    }
    func statusBarStyle() {
        if(lightBar){
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    func updateQueueInfo(_ ta: Bool) {
        if ta{
            print("Kurwa")
        }
    }
    
    @objc func doubleTap(_ sender: UITapGestureRecognizer){
        realPresent()
    }
    
    func realPresent(){
        pickedID = player.currentItem?.albumPersistentID
        let tbvc = storyboard?.instantiateViewController(withIdentifier: "GOGOGO") as! PlumTabBarController
        if let upvc = tbvc.viewControllers?[0] as? UpNextVC{
            upvc.delegate = self
            upvc.style = passStyle
        }
        if let alvc = tbvc.viewControllers?[1] as? AlbumUpVC{
            alvc.delegate = self
            alvc.receivedID = pickedID
            alvc.style = passStyle
        }
        if let arvc = tbvc.viewControllers?[2] as? ArtistUpVC{
            arvc.delegate = self
            arvc.receivedID = pickedID
            arvc.style = passStyle
        }
        tbvc.modalPresentationStyle = .overCurrentContext
        tbvc.modalTransitionStyle = .coverVertical
        self.present(tbvc, animated: true, completion: nil)
    }
    
    @objc func tapOnLabel(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.2, animations: {
            self.titleView.alpha = 0.0
            self.ratingsView.alpha = 1.0
        })
        titleView.isUserInteractionEnabled = false
        ratingsView.isUserInteractionEnabled = true
        ratingLabel.isUserInteractionEnabled = true
    }
    
    @objc func panOnRatings(_ sender: UIPanGestureRecognizer){
        let location = sender.location(in: ratingLabel)
        let procent = location.x / ratingLabel.frame.maxX * 100
        print(procent)
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
        let procent = location.x / ratingLabel.frame.maxX * 100
        print(procent)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: view)
        if !ratingsView.frame.contains(location!){
            UIView.animate(withDuration: 0.2, animations: {
                self.titleView.alpha = 1.0
                self.ratingsView.alpha = 0.0
            })
            titleView.isUserInteractionEnabled = true
            ratingsView.isUserInteractionEnabled = false
            ratingLabel.isUserInteractionEnabled = false
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
    
    func setArtworkDoubleTap(){
        doubleTapArt = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTapArt.numberOfTapsRequired = 2
        doubleTapArt.numberOfTouchesRequired = 1
        artworkImage.isUserInteractionEnabled = true
        artworkImage.addGestureRecognizer(doubleTapArt)
    }
    
    func setLabelTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnLabel(_:)))
        titleView.addGestureRecognizer(tap)
        titleView.isUserInteractionEnabled = true
    }
    
    func setRatingsPan(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panOnRatings(_:)))
        ratingsView.addGestureRecognizer(pan)
        ratingsView.isUserInteractionEnabled = false
        ratingsView.alpha = 0.0
    }
    
    func setRatingsTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnRatings(_:)))
        ratingLabel.addGestureRecognizer(tap)
        ratingLabel.isUserInteractionEnabled = false
    }
    
    func setArtworkTap(){
        let artworkTap = UITapGestureRecognizer(target: self, action: #selector(tapOnArtwork(_:)))
        artworkTap.numberOfTapsRequired = 1
        artworkTap.numberOfTouchesRequired = 1
        artworkImage.addGestureRecognizer(artworkTap)
        artworkTap.require(toFail: doubleTapArt)
    }
    
    func setLyricsDoubleTap(){
        doubleTapLyr = UITapGestureRecognizer(target: self, action: #selector(doubleTapOnLyrics(_:)))
        doubleTapLyr.numberOfTapsRequired = 2
        doubleTapLyr.numberOfTouchesRequired = 1
        lyricsView.addGestureRecognizer(doubleTapLyr)
        lyricsTextView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
    }
    
    func setLyricsView(){
        lyricsView.alpha = 0.0
        lyricsView.isUserInteractionEnabled = false
        let lyricsTap = UITapGestureRecognizer(target: self, action: #selector(tapOnLyrics(_:)))
        lyricsTap.numberOfTapsRequired = 1
        lyricsTap.numberOfTouchesRequired = 1
        lyricsView.addGestureRecognizer(lyricsTap)
        setLyricsDoubleTap()
        lyricsTap.require(toFail: doubleTapLyr)
        lyricsView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        lyricsTextView.backgroundColor = .clear
        lyricsTextView.isScrollEnabled = true
        view.addSubview(lyricsView)
    }
    
    func setVolumeView(){
        mpVolView = MPVolumeView(frame: volView.bounds)
        mpVolView.showsVolumeSlider = true
        mpVolView.showsRouteButton = false
        volView.addSubview(mpVolView)
    }
    
    func setSlider(){
        timeSlider.addTarget(self, action: #selector(NowPlayingVC.scrubAudio), for: .valueChanged)
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(NowPlayingVC.updateTimes), userInfo: nil, repeats: true)
        timeSlider.isContinuous = false
    }
    
    @objc func tapOnLyrics(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView.alpha = 0.0
        })
        lyricsView.isUserInteractionEnabled = false
    }
    
    @objc func tapOnArtwork(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView.alpha = 1.0
        })
        //lyricsTextView.scrollRangeToVisible(NSRange(location:0, length:1))
        lyricsView.isUserInteractionEnabled = true
    }
    
    @objc func doubleTapOnLyrics(_ sender: UITapGestureRecognizer){
        realPresent()
    }
}

