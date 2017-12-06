//
//  EightNowPlayingVC.swift
//  Plum
//
//  Created by Adam Wienconek on 21.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications

class EightNowPlayingVC: UIViewController {

    var scale: Double!
    
    let player = Plum.shared
    @IBOutlet weak var volView: UIView!
    var mpVolView: MPVolumeView!
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
    @IBOutlet weak var lyricsButton: UIButton!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var BackgroundView: UIView!
    var viewActive = false
    
    let modesButtons = [#imageLiteral(resourceName: "lyricsbutton"), #imageLiteral(resourceName: "nolyricsbutton"), #imageLiteral(resourceName: "ratingsbutton"), #imageLiteral(resourceName: "noratingsbutton")]
    
    var doubleTapArt: UITapGestureRecognizer!
    var doubleTapLyr: UITapGestureRecognizer!
    var colors: UIImageColors!
    var lightStyle: Bool!
    var pickedID: MPMediaEntityPersistentID!
    
    var lightBar: Bool!
    var image: UIImage!
    var timer: Timer!
    var shouldUpdateSlider = true
    var interval: TimeInterval = 0.05
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .clear
        setVolumeView()
        setImages()
        setArtworkDoubleTap()
        setLabelTap()
        setRatingsPan()
        setRatingsTap()
        setArtworkTap()
        setLyricsDoubleTap()
        setLyricsView()
        setSlider()
        shufView.layer.cornerRadius = 6.0
        if GlobalSettings.blur {
            let blur = UIBlurEffect(style: .dark)
            let fx = UIVisualEffectView(frame: BackgroundView.frame)
            fx.effect = blur
            backgroundImgView.contentMode = .scaleAspectFill
            BackgroundView.addSubview(fx)
        }
        updateUI()
        GlobalSettings.changeBlur(false)
        GlobalSettings.changeColor(true)
        setColors()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        timer.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewActive = false
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if lightStyle {
            UIApplication.shared.statusBarStyle = .default
        }else{
            UIApplication.shared.statusBarStyle = .lightContent
        }
        viewActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(player.wasLoaded == false){
            nextBtn.isEnabled = false
            prevBtn.isEnabled = false
            playbackBtn.isEnabled = false
        }
        updateUI()
        //timer.fire()
        print("Scale = \(GlobalSettings.scale)")
    }
    
    @IBAction func presentQueue(_ sender: Any){
        realPresent()
    }
    
    @IBAction func ratingPressed() {
        GlobalSettings.changeRating(!GlobalSettings.rating)
        if GlobalSettings.rating {
            ratingButton.setImage(#imageLiteral(resourceName: "ratingsbutton"), for: .normal)
            lyricsButton.setImage(#imageLiteral(resourceName: "nolyricsbutton"), for: .normal)
        }else{
            ratingButton.setImage(#imageLiteral(resourceName: "noratingsbutton"), for: .normal)
        }
    }
    
    @IBAction func lyricsModePressed() {
        GlobalSettings.changeLyrics(!GlobalSettings.lyrics)
        askNotification()
        if GlobalSettings.lyrics {
            lyricsButton.setImage(#imageLiteral(resourceName: "lyricsbutton"), for: .normal)
            ratingButton.setImage(#imageLiteral(resourceName: "noratingsbutton"), for: .normal)
        }else{
            lyricsButton.setImage(#imageLiteral(resourceName: "nolyricsbutton"), for: .normal)
        }
    }
    
    @IBAction func playBackBtn(_ sender: Any) {
        if(player.isPlayin()){
            playbackBtn.setImage(#imageLiteral(resourceName: "play-butt"), for: .normal)
            player.pause()
        }else{
            playbackBtn.setImage(#imageLiteral(resourceName: "pause-butt"), for: .normal)
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
        setColors()
    }

}

extension EightNowPlayingVC: UIGestureRecognizerDelegate {
    
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
        ratingLabel.addGestureRecognizer(pan)
        ratingLabel.isUserInteractionEnabled = false
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
    
    /////////////////// Handlery
    
    @objc func doubleTap(_ sender: UITapGestureRecognizer){
        realPresent()
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
        lyricsView.isUserInteractionEnabled = true
    }
    
    @objc func doubleTapOnLyrics(_ sender: UITapGestureRecognizer){
        realPresent()
    }
    
    @objc func tapOnLabel(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.2, animations: {
            self.titleView.alpha = 0.0
            self.ratingsView.alpha = 1.0
        })
        showRating()
        titleView.isUserInteractionEnabled = false
        ratingsView.isUserInteractionEnabled = true
        ratingLabel.isUserInteractionEnabled = true
    }
    
    @objc func panOnRatings(_ sender: UIPanGestureRecognizer){
        let location = sender.location(in: ratingLabel)
        let procent = location.x / ratingLabel.bounds.maxX * 100
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
        let procent = location.x / ratingLabel.bounds.maxX * 100
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

extension EightNowPlayingVC {
    
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
        lyricsView.addSubview(lyricsTextView)
        view.superview?.addSubview(lyricsView)
    }
    
    func setVolumeView(){
        mpVolView = MPVolumeView(frame: volView.bounds)
        mpVolView.showsVolumeSlider = true
        mpVolView.showsRouteButton = false
        mpVolView.setVolumeThumbImage(#imageLiteral(resourceName: "thumb"), for: .normal)
        volView.addSubview(mpVolView)
    }
    
    func setSlider(){
        timeSlider.addTarget(self, action: #selector(EightNowPlayingVC.scrubAudio), for: .valueChanged)
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(EightNowPlayingVC.updateTimes), userInfo: nil, repeats: true)
        timeSlider.isContinuous = false
    }
}

extension EightNowPlayingVC: UpNextDelegate {
    
    func realPresent(){
        pickedID = player.currentItem?.albumPersistentID
        let tbvc = storyboard?.instantiateViewController(withIdentifier: "GOGOGO") as! UITabBarController
        if let upvc = tbvc.viewControllers?[0] as? QueueVC{
            upvc.lightTheme = lightStyle
            upvc.delegate = self
        }
        if let alvc = tbvc.viewControllers?[1] as? AlbumUpVC{
            alvc.receivedID = pickedID
            alvc.lightTheme = lightStyle
            alvc.delegate = self
        }
        if let arvc = tbvc.viewControllers?[2] as? ArtistUpVC{
            arvc.receivedID = pickedID
            arvc.lightTheme = lightStyle
            arvc.delegate = self
        }
        tbvc.modalPresentationStyle = .overCurrentContext
        tbvc.modalTransitionStyle = .coverVertical
        present(tbvc, animated: true, completion: nil)
        //presentDetail(tbvc)
    }
    
    func backFromUpNext() {
        self.outOfLabel.text = player.labelString(type: "out of")
    }
    
}

extension EightNowPlayingVC {       //Kolory i UI
    
    @objc func updateUI(){
        scale = GlobalSettings.scale
        if(self.player.currentItem != nil){
            self.titleLabel.text = self.player.labelString(type: "title")
            self.detailLabel.text = self.player.labelString(type: "detail")
            self.image = self.player.currentItem?.artwork?.image(at: self.artworkImage.bounds.size) ?? #imageLiteral(resourceName: "no_music")
        }else{
            self.titleLabel.text = "Choose a song"
            self.detailLabel.text = "to play"
            self.image = #imageLiteral(resourceName: "no_music")
        }
        if(self.player.isPlayin()){
            self.playbackBtn.setImage(#imageLiteral(resourceName: "pause-butt"), for: .normal)
        }else{
            self.playbackBtn.setImage(#imageLiteral(resourceName: "play-butt"), for: .normal)
        }
        self.artworkImage.image = self.image
        self.outOfLabel.text = self.player.labelString(type: "out of")
        self.timeSlider.setValue(0, animated: false)
        self.timeSlider.maximumValue = Float(self.player.player.duration)
        if GlobalSettings.blur {
            backgroundImgView.image = image
        }else if GlobalSettings.color {
            color()
        }
        if player.currentItem != nil{
            let ass = AVAsset(url: (self.player.currentItem?.assetURL)!)
            if let lyr = ass.lyrics {
                self.lyricsTextView.text = lyr
            }else{
                self.lyricsTextView.text = "\n\n\n\n\n\nNo lyrics available :(\n\nYou can add them in iTunes\non your Mac or PC\n"
            }
        }
        self.lyricsTextView.textColor = .white
        self.lyricsTextView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        if GlobalSettings.rating {
            ratingButton.setImage(#imageLiteral(resourceName: "ratingsbutton"), for: .normal)
        }else{
            ratingButton.setImage(#imageLiteral(resourceName: "noratingsbutton"), for: .normal)
        }
        if GlobalSettings.lyrics {
            lyricsButton.setImage(#imageLiteral(resourceName: "lyricsbutton"), for: .normal)
        }else{
            lyricsButton.setImage(#imageLiteral(resourceName: "nolyricsbutton"), for: .normal)
        }
        showRating()
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
    
    func setImages() {
        prevBtn.setImage(#imageLiteral(resourceName: "prev-butt"), for: .normal)
        nextBtn.setImage(#imageLiteral(resourceName: "next-butt"), for: .normal)
        minVolImg.image = #imageLiteral(resourceName: "zeroVol")
        maxVolImg.image = #imageLiteral(resourceName: "maxVol")
        if player.isPlayin() {
            playbackBtn.setImage(#imageLiteral(resourceName: "pause-butt"), for: .normal)
        }else{
            playbackBtn.setImage(#imageLiteral(resourceName: "play-butt"), for: .normal)
        }
        ratingButton.clipsToBounds = true
        lyricsButton.clipsToBounds = true
        ratingButton.layer.cornerRadius = 3
        lyricsButton.layer.cornerRadius = 3
    }
    
    func setColors() {
        if GlobalSettings.color {
            color()
        }else if GlobalSettings.blur {
            blur()
        }else{
            switch GlobalSettings.theme {
            case .dark:
                dark()
            case .light:
                light()
            }
        }
    }
    
    func color(){
        colors = image.getColors(scaleDownSize: CGSize(width: scale, height: scale))
        BackgroundView.backgroundColor = colors.backgroundColor
        self.titleLabel.textColor = colors.primaryColor
        self.detailLabel.textColor = colors.detailColor
        self.elapsedLabel.textColor = colors.detailColor
        self.remainingLabel.textColor = colors.detailColor
        customTrackSlider(slider: timeSlider, min: colors.primaryColor, max: colors.detailColor, thumb: colors.primaryColor)
        customVolumeSlider(min: colors.primaryColor, max: colors.detailColor, thumb: colors.detailColor, thumbImg: #imageLiteral(resourceName: "thumb"))
        doneBtn.tintColor = colors.detailColor
        upNextBtn.tintColor = colors.detailColor
        outOfLabel.textColor = colors.primaryColor
        ratingLabel.textColor = colors.primaryColor
        ratingButton.tintColor = colors.detailColor
        lyricsButton.tintColor = colors.detailColor
        if(colors.backgroundColor.isDarkColor){
            if viewActive { UIApplication.shared.statusBarStyle = .lightContent }
            lightBar = true
            prevBtn.tintColor = .white
            playbackBtn.tintColor = .white
            nextBtn.tintColor = .white
            minVolImg.tintColor = .white
            maxVolImg.tintColor = .white
            lightStyle = false
        }else{
            if viewActive { UIApplication.shared.statusBarStyle = .default }
            lightBar = false
            prevBtn.tintColor = colors.primaryColor
            playbackBtn.tintColor = colors.primaryColor
            nextBtn.tintColor = colors.primaryColor
            minVolImg.tintColor = colors.primaryColor
            maxVolImg.tintColor = colors.primaryColor
            lightStyle = true
        }
        if(player.isShuffle){
            shufBtn.setTitleColor(colors.detailColor, for: .normal)
            shufView.backgroundColor = colors.primaryColor.withAlphaComponent(0.3)
        }else{
            shufBtn.setTitleColor(colors.primaryColor, for: .normal)
            shufView.backgroundColor = .clear
        }
    }
    
    func blur() {
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        playbackBtn.tintColor = .white
        nextBtn.tintColor = .white
        prevBtn.tintColor = .white
        shufBtn.tintColor = .clear
        elapsedLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        remainingLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        let track = #imageLiteral(resourceName: "track")
        timeSlider.setMinimumTrackImage(track.tintPictogram(with: UIColor.white.withAlphaComponent(0.5)), for: .normal)
        timeSlider.setMaximumTrackImage(track.tintPictogram(with: UIColor.white.withAlphaComponent(0.2)), for: .normal)
        timeSlider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .normal)
        timeSlider.tintColor = UIColor.white.withAlphaComponent(0.3)
        minVolImg.tintColor = UIColor.white.withAlphaComponent(0.3)
        maxVolImg.tintColor = UIColor.white.withAlphaComponent(0.3)
        upperBar.backgroundColor = .clear
        doneBtn.tintColor = .white
        upNextBtn.tintColor = .white
        outOfLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        ratingsView.backgroundColor = .clear
        titleView.backgroundColor = .clear
        ratingLabel.textColor = .white
        shufView.tintColor = UIColor.white.withAlphaComponent(0.3)
        if player.isShuffle {
            shufBtn.setTitleColor(.white, for: .normal)
            shufView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }else{
            shufBtn.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
            shufView.backgroundColor = .clear
        }
        lyricsButton.tintColor = .white
        ratingButton.tintColor = .white
        customVolumeSlider(min: UIColor.white.withAlphaComponent(0.5), max: UIColor.white.withAlphaComponent(0.2), thumb: .white, thumbImg: #imageLiteral(resourceName: "thumb"))
        lightStyle = false
    }
    
    func dark() {
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        playbackBtn.tintColor = .white
        nextBtn.tintColor = .white
        prevBtn.tintColor = .white
        shufBtn.tintColor = .clear
        elapsedLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        remainingLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        timeSlider.tintColor = .clear
        minVolImg.tintColor = UIColor.white.withAlphaComponent(0.5)
        maxVolImg.tintColor = UIColor.white.withAlphaComponent(0.5)
        upperBar.backgroundColor = .clear
        doneBtn.tintColor = .white
        upNextBtn.tintColor = .white
        outOfLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        ratingsView.backgroundColor = .clear
        titleView.backgroundColor = .clear
        ratingLabel.textColor = .white
        shufView.tintColor = UIColor.white.withAlphaComponent(0.5)
        lyricsButton.tintColor = .white
        ratingButton.tintColor = .white
        mpVolView.tintColor = UIColor.white.withAlphaComponent(0.5)
        lightStyle = false
    }
    
    func light() {
        BackgroundView.backgroundColor = .clear
        backgroundImgView.image = #imageLiteral(resourceName: "background_se")
        titleLabel.textColor = .black
        detailLabel.textColor = .black
        playbackBtn.tintColor = .black
        nextBtn.tintColor = .black
        prevBtn.tintColor = .black
        shufBtn.tintColor = .black
        elapsedLabel.textColor = .black
        remainingLabel.textColor = .black
        timeSlider.minimumTrackTintColor = .black
        timeSlider.maximumTrackTintColor = UIColor.black.withAlphaComponent(0.5)
        minVolImg.tintColor = UIColor.black.withAlphaComponent(0.5)
        maxVolImg.tintColor = UIColor.black.withAlphaComponent(0.5)
        upperBar.backgroundColor = .clear
        doneBtn.tintColor = GlobalSettings.tint.color
        upNextBtn.tintColor = GlobalSettings.tint.color
        outOfLabel.textColor = .black
        ratingsView.backgroundColor = .clear
        titleView.backgroundColor = .clear
        ratingLabel.textColor = .black
        shufView.tintColor = GlobalSettings.tint.color.withAlphaComponent(0.5)
        lyricsButton.tintColor = .black
        ratingButton.tintColor = .black
        mpVolView.tintColor = .black
        lightStyle = true
    }
    
    func customVolumeSlider(min: UIColor, max: UIColor, thumb: UIColor, thumbImg: UIImage) {
        let temp = mpVolView.subviews
        for current in temp {
            if current.isKind(of: UISlider.self) {
                let tempSlider = current as! UISlider
                tempSlider.setMinimumTrackImage(#imageLiteral(resourceName: "volumetrack").tintPictogram(with: min), for: .normal)
                tempSlider.setMaximumTrackImage(#imageLiteral(resourceName: "volumetrack").tintPictogram(with: max), for: .normal)
                tempSlider.setThumbImage(thumbImg.tintPictogram(with: thumb), for: .normal)
            }
        }
    }
    
    func customTrackSlider(slider: UISlider, min: UIColor, max: UIColor, thumb: UIColor) {
        var thumbImg: UIImage
        if GlobalSettings.round {
            thumbImg = #imageLiteral(resourceName: "thumb")
            slider.setThumbImage(thumbImg, for: .normal)
        }else{
            thumbImg = #imageLiteral(resourceName: "thumb2")
            slider.setThumbImage(thumbImg.tintPictogram(with: thumb), for: .normal)
        }
        slider.setMinimumTrackImage(#imageLiteral(resourceName: "track").tintPictogram(with: min), for: .normal)
        slider.setMaximumTrackImage(#imageLiteral(resourceName: "track").tintPictogram(with: max), for: .normal)
    }
    
    @objc func didEnterBackground() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
        timer.invalidate()
    }
    
    @objc func didBecomeActive() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name(rawValue: "playBackStateChanged"), object: nil)
        timer.fire()
    }
    
    func askNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { enabled, error in
            if !enabled {
                self.notificationPermissionError(error)
            }
        })
    }
    
    func notificationPermissionError(_ error: Error?) {
        if error != nil {
            print(error!)
        }
        let alert = UIAlertController(title: "Error", message: "You have to allow notifications for this feature to work. Fix in settings?", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK Computer", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true) {
            GlobalSettings.changeLyrics(false)
        }
    }
    
}

extension UIViewController {
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
}