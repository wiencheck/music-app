//
//  IconsVC.swift
//  Plum
//
//  Created by Adam Wienconek on 23.01.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

@available(iOS 10.3, *) class IconsVC: UIViewController {
    
    struct Icon {
        let name: String
        let image: UIImage
        let file: String
        init(name: String, image: UIImage, file: String) {
            self.name = name
            self.image = image
            self.file = file
        }
    }
    
    var borderLess = [Icon]()
    var border = [Icon]()
    var currentArray = [Icon]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segment: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        setCollection()
        segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segment.tintColor = GlobalSettings.tint.color
        populateBorderLessArray()
        populateBorderArray()
        currentArray = border
    }
    
    func setCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    func populateBorderLessArray() {
        borderLess.append(Icon(name: "Black", image: #imageLiteral(resourceName: "black.png"), file: "black"))
        borderLess.append(Icon(name: "Blue", image: #imageLiteral(resourceName: "blue.png"), file: "blue"))
        borderLess.append(Icon(name: "Crazy Black", image: #imageLiteral(resourceName: "crazy_black.png"), file: "crazy_black"))
        borderLess.append(Icon(name: "Crazy White", image: #imageLiteral(resourceName: "crazy_white.png"), file: "crazy_white"))
        borderLess.append(Icon(name: "Gray", image: #imageLiteral(resourceName: "gray.png"), file: "gray"))
        borderLess.append(Icon(name: "Orange", image: #imageLiteral(resourceName: "orange.png"), file: "orange"))
        borderLess.append(Icon(name: "Purple", image: #imageLiteral(resourceName: "purple.png"), file: "purple"))
        borderLess.append(Icon(name: "Red", image: #imageLiteral(resourceName: "red.png"), file: "red"))
        borderLess.append(Icon(name: "Pink Red", image: #imageLiteral(resourceName: "redpink.png"), file: "redpink"))
        borderLess.append(Icon(name: "Rose", image: #imageLiteral(resourceName: "rose.png"), file: "rose"))
        borderLess.append(Icon(name: "Classix", image: #imageLiteral(resourceName: "sixyy.png"), file: "sixyy"))
        borderLess.append(Icon(name: "Spot on Green", image: #imageLiteral(resourceName: "spotgreen.png"), file: "spotgreen"))
        borderLess.append(Icon(name: "Wizard", image: #imageLiteral(resourceName: "wizard.png"), file: "wizard"))
        borderLess.append(Icon(name: "Yellow", image: #imageLiteral(resourceName: "yellow.png"), file: "yellow"))
        borderLess.append(Icon(name: "Modern", image: #imageLiteral(resourceName: "modern.png"), file: "modern"))
    }
    
    func populateBorderArray() {
        border.append(Icon(name: "Black", image: #imageLiteral(resourceName: "black_border.png"), file: "black_border"))
        border.append(Icon(name: "Blue", image: #imageLiteral(resourceName: "blue_border.png"), file: "blue_border"))
        border.append(Icon(name: "Crazy Black", image: #imageLiteral(resourceName: "crazy_black_border.png"), file: "crazy_black_border"))
        border.append(Icon(name: "Crazy White", image: #imageLiteral(resourceName: "crazy_white_border.png"), file: "crazy_white_border"))
        border.append(Icon(name: "Gray", image: #imageLiteral(resourceName: "gray_border.png"), file: "gray_border"))
        border.append(Icon(name: "Orange", image: #imageLiteral(resourceName: "orange_border.png"), file: "orange_border"))
        border.append(Icon(name: "Purple", image: #imageLiteral(resourceName: "purple_border.png"), file: "purple_border"))
        border.append(Icon(name: "Red", image: #imageLiteral(resourceName: "red_border.png"), file: "red_border"))
        border.append(Icon(name: "Pink Red", image: #imageLiteral(resourceName: "redpink_border.png"), file: "redpink_border"))
        border.append(Icon(name: "Rose", image: #imageLiteral(resourceName: "rose_border.png"), file: "rose_border"))
        border.append(Icon(name: "Classix", image: #imageLiteral(resourceName: "six_border.png"), file: "six_border"))
        border.append(Icon(name: "Spot on Green", image: #imageLiteral(resourceName: "spotgreen_border.png"), file: "spotgreen_border"))
        border.append(Icon(name: "Wizard", image:#imageLiteral(resourceName: "wizard_border.png"), file: "wizard_border"))
        border.append(Icon(name: "Yellow", image: #imageLiteral(resourceName: "yellow_border.png"), file: "yellow_border"))
        border.append(Icon(name: "Classic", image: #imageLiteral(resourceName: "classic.png"), file: "classic"))
    }
    
    func changeIcon(icon: String?) {
        UIApplication.shared.setAlternateIconName(icon) { (error) in
            if let error = error {
                print("error: \(error)")
            }
        }
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentArray = border
        case 1:
            currentArray = borderLess
        default:
            currentArray = [Icon(name: "Default", image: #imageLiteral(resourceName: "default.png"), file: "default")]
            changeIcon(icon: nil)
        }
        collectionView.reloadData()
    }

}

@available(iOS 10.3, *) extension IconsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! IconCell
        cell.imageView.image = currentArray[indexPath.row].image
        cell.label.text = currentArray[indexPath.row].name
        //cell.imageView.layer.cornerRadius = 6.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = currentArray[indexPath.row]
        changeIcon(icon: item.file)
    }
    
}
