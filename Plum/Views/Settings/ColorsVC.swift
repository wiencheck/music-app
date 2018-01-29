//
//  ColorsVC.swift
//  Plum
//
//  Created by Adam Wienconek on 15.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
struct Color {
    let name: String
    let color: UIColor
    let bar: UIColor
    init(n: String, c: UIColor, b: UIColor) {
        self.name = n
        self.color = c
        self.bar = b
    }
}

class ColorsVC: UICollectionViewController {
    
    var colors: [Color]!
    @IBOutlet weak var upperBar: UINavigationItem!
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadColors()
        colorBar(color: GlobalSettings.tint)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ColorCell
        cell.setup(color: colors[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setColor(color: colors[indexPath.row])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "themeChanged"), object: nil)
        alert()
    }
    
    func alert() {
        let a = UIAlertController(title: "Changing colors?", message: "Please restart the app for all changes to be enabled", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        a.addAction(ok)
        present(a, animated: true, completion: nil)
    }

}

extension ColorsVC {
    
    func loadColors() {
        colors = [Color]()
        colors.append(Color(n: "Sexy red", c: UIColor(red:0.71, green:0.28, blue:0.28, alpha:1.0), b: .white))
        colors.append(Color(n: "Rose red", c: UIColor(red:0.72, green:0.07, blue:0.07, alpha:1.0), b: .white))
        colors.append(Color(n: "Apple Red", c: UIColor(red: 1.0, green: 0.180392156862745, blue: 0.333333333333333, alpha: 1.0), b: .white))
        colors.append(Color(n: "Mustang blue", c: UIColor(red:0.12, green:0.58, blue:0.99, alpha:1.0), b: .white))
        colors.append(Color(n: "Elegant blue", c: UIColor(red:0.02, green:0.37, blue:0.69, alpha:1.0), b: .white))
        colors.append(Color(n: "Jeans blue", c: UIColor(red:0.12, green:0.35, blue:0.47, alpha:1.0), b: .white))
        colors.append(Color(n: "Free-to-go", c: UIColor(red:0.11, green:0.74, blue:0.36, alpha:1.0), b: .white))
        colors.append(Color(n: "The best green", c: UIColor(red:0.04, green:0.43, blue:0.17, alpha:1.0), b: .white))
        colors.append(Color(n: "Neon green", c: UIColor(red:0.35, green:0.89, blue:0.54, alpha:1.0), b: .black))
        colors.append(Color(n: "Brick orange", c: UIColor(red:0.88, green:0.35, blue:0.23, alpha:1.0), b: .white))
        colors.append(Color(n: "Carrot juice", c: UIColor(red:0.88, green:0.46, blue:0.23, alpha:1.0), b: .white))
        colors.append(Color(n: "Mango", c: UIColor(red:1.00, green:0.69, blue:0.00, alpha:1.0), b: .white))
        colors.append(Color(n: "Fresh orange", c: UIColor(red:1.00, green:0.30, blue:0.00, alpha:1.0), b: .white))
        colors.append(Color(n: "Wizard purple", c: UIColor(red:0.26, green:0.31, blue:1.00, alpha:1.0), b: .white))
        colors.append(Color(n: "Plum", c: UIColor(red:0.21, green:0.24, blue:0.61, alpha:1.0), b: .white))
        colors.append(Color(n: "Moon gray", c: UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.0), b: .white))
        colors.append(Color(n: "Graphite", c: UIColor(red:0.29, green:0.29, blue:0.29, alpha:1.0), b: .white))
        colors.append(Color(n: "Men in Black", c: UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), b: .white))
    }
    
    func colorBar(color: Color){
        self.navigationController?.navigationBar.barTintColor = color.color
        self.navigationController?.navigationBar.tintColor = color.bar
        if color.bar == .white {
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    func setColor(color: Color) {
        GlobalSettings.changeTint(color)
        colorBar(color: color)
    }
    
}
