//
//  ArtworkVC.swift
//  Plum
//
//  Created by Adam Wienconek on 11.04.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class ArtworkVC: UIViewController {

    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var lyricsView: UITextView!
    
    var queueVC: SixQueueVC!
    var queuePresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lyricsView.alpha = 0.0
        addGestures()
        
        queueVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sixQueueVC") as! SixQueueVC
        queueVC.modalTransitionStyle = .coverVertical
        queueVC.modalPresentationStyle = .overCurrentContext
    }
    
    private func addGestures() {
        let artworkTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapOnArtwork(_:)))
        artworkTap.numberOfTapsRequired = 1
        artworkTap.numberOfTouchesRequired = 1
        artworkView.isUserInteractionEnabled = true
        artworkView.addGestureRecognizer(artworkTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapOnArtwork(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        artworkView.addGestureRecognizer(doubleTap)
        lyricsView.isUserInteractionEnabled = true
        lyricsView.addGestureRecognizer(doubleTap)
        
        let lyricsTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapOnArtwork(_:)))
        lyricsTap.numberOfTapsRequired = 1
        lyricsTap.numberOfTouchesRequired = 1
        artworkView.addGestureRecognizer(lyricsTap)
        artworkTap.require(toFail: doubleTap)
        lyricsTap.require(toFail: doubleTap)
    }
    
    @objc func handleSingleTapOnArtwork(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView.alpha = 1.0
        })
    }
    
    @objc func handleSingleTapOnLyrics(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView.alpha = 0.0
        })
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        presentQueue()
    }
    
    func presentQueue() {
//        self.queueVC.definesPresentationContext = true
//        present(queueVC, animated: true, completion: {
//            self.queuePresented = true
//        })
        performSegue(withIdentifier: "flip", sender: nil)
    }
    
    func dismissQueue() {
        queueVC.dismiss(animated: true, completion: {
            self.queuePresented = false
            self.definesPresentationContext = true
        })
    }

}
