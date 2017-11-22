//
//  ScaleVC.swift
//  Plum
//
//  Created by Adam Wienconek on 21.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class ScaleVC: UIViewController {
    
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var scale: Double!
    var images = [UIImage]()
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        scale = GlobalSettings.scale
        scaleLabel.text = "\(Int(scale!))"
        stepper.maximumValue = 200
        stepper.value = scale
        images = loadImages()
        image.image = images[index]
        magic()
        stepper.addTarget(self, action: #selector(stepperUpdated(_:)), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
    }
    
    func magic() {
        let colors = image.image?.getColors(scaleDownSize: CGSize(width: scale, height: scale))
        primaryLabel.textColor = colors?.primaryColor
        detailLabel.textColor = colors?.detailColor
        secondaryLabel.textColor = colors?.secondaryColor
        scaleLabel.textColor = colors?.secondaryColor
        view.backgroundColor = colors?.backgroundColor
        navigationController?.navigationBar.barTintColor = colors?.backgroundColor
        navigationController?.navigationBar.tintColor = colors?.detailColor
        stepper.tintColor = colors?.primaryColor
        nextBtn.tintColor = colors?.detailColor
        prevBtn.tintColor = colors?.detailColor
    }
    
    @objc func stepperUpdated(_ sender: UIStepper) {
        scale = sender.value
        GlobalSettings.changeScale(scale)
        scaleLabel.text = "\(Int(scale!))"
        magic()
    }
    
    func loadImages() -> [UIImage]{
        let all = musicQuery.shared.allAlbums()
        var albums = [UIImage]()
        var i = 0
        if all.count > 20 {
            while albums.count < 21 {
                if all[i].artwork != nil {
                    albums.append((all[i].artwork?.image(at: image.frame.size))!)
                }
                i += 1
            }
        }else{
            for i in 0 ..< all.count {
                if let img = all[i].artwork?.image(at: image.frame.size) {
                    albums.append(img)
                }
            }
        }
        return albums
    }

    @IBAction func nextBtnPressed() {
        if index == images.count - 1 {
            index = 0
        }else{
            index += 1
        }
        image.image = images[index]
        magic()
    }
    
    @IBAction func prevBtnPressed() {
        if index == 0 {
            index = images.count - 1
        }else{
            index -= 1
        }
        image.image = images[index]
        magic()
    }
    

}
