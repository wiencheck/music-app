//
//  ColorflowVC.swift
//  Plum
//
//  Created by Adam Wienconek on 17.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class ColorflowVC: UIViewController {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    var current: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        current = GlobalSettings.color
        leftView.layer.cornerRadius = 4.0
        leftImage.layer.cornerRadius = 4.0
        rightView.layer.cornerRadius = 4.0
        rightImage.layer.cornerRadius = 4.0
        //rightImage.image = #imageLiteral(resourceName: "right.PNG")
        //leftImage.image = #imageLiteral(resourceName: "left.PNG")
        if !current {
            rightView.backgroundColor = GlobalSettings.tint.color
            rightLabel.textColor = GlobalSettings.tint.bar
        }else{
            leftView.backgroundColor = GlobalSettings.tint.color
            leftLabel.textColor = GlobalSettings.tint.bar
        }
        setText()
        setGestures()
    }
    
    func setGestures() {
        let mg = UITapGestureRecognizer(target: self, action: #selector(tapOnright))
        mg.numberOfTapsRequired = 1
        rightView.addGestureRecognizer(mg)
        let cg = UITapGestureRecognizer(target: self, action: #selector(tapOnleft))
        cg.numberOfTapsRequired = 1
        leftView.addGestureRecognizer(cg)
    }
    
    @objc func tapOnright() {
        if current {
            UIView.animate(withDuration: 0.2, animations: {
                self.rightView.backgroundColor = GlobalSettings.tint.color
                self.rightLabel.textColor = GlobalSettings.tint.bar
                self.leftView.backgroundColor = .white
                self.leftLabel.textColor = .black
            })
            current = false
            GlobalSettings.changeColor(false)
        }
    }
    
    @objc func tapOnleft() {
        if !current {
            UIView.animate(withDuration: 0.2, animations: {
                self.leftView.backgroundColor = GlobalSettings.tint.color
                self.leftLabel.textColor = GlobalSettings.tint.bar
                self.rightView.backgroundColor = .white
                self.rightLabel.textColor = .black
            })
            current = true
            GlobalSettings.changeColor(true)
        }
    }
    
    func setText() {
        let s = "\nPlum can set colors on now playing screen based on current artwork. \nPretty neat!"
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = s
    }
    
}
