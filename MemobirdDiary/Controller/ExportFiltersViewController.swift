//
//  ExportFiltersViewController.swift
//  MemobirdDiary
//
//  Created by Mohammed Aslam on 07/11/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import UIKit
// MARK: - UISlider @IBAction
import QuartzCore
import CoreData
extension ExportFiltersViewController {
    
    @IBAction func brightnesssliderbtn(_ sender: UISlider) {
        DispatchQueue.main.async {
            // self.brightnessLabel.text = "Brightness \(sender.value)"
            self.colorControl.brightness(sender.value)
            self.filteredImageView.inputImage = self.colorControl.outputUIImage()
        }
    }
    
    @IBAction func contrastsliderbtn(_ sender: UISlider) {
        DispatchQueue.main.async {
            //  self.contrastLabel.text = "Contrast \(sender.value)"
            
            self.colorControl.contrast(sender.value)
            self.filteredImageView.inputImage = self.colorControl.outputUIImage()
        }
    }
    
}
class ExportFiltersViewController:UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UITabBarDelegate {
    @IBOutlet weak var filteredImageView: FilteredImageView!
    @IBOutlet weak var photoFilterCollectionView: UICollectionView!
    ////TabBarview
    @IBOutlet weak var undobtnoutlet: UIButton!
    @IBOutlet weak var scrollViewBG: UIScrollView!
    @IBOutlet weak var tabBarView: UITabBar!
    @IBOutlet weak var filterBGView: UIView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    var getnewImage: UIImage!

    var picimageView = UIImageView()
    var picimageView1 = UIImageView()
    
    
    var textLabel = UILabel()
    // var scrollView: UIScrollView!
    var diaryEntries = [DiaryEntry]()
    var dataModelArr = [dataModel]()
    var selectedDiaryEntryIndex : Int! = 0
    var mode : String = ""
    var stickerView = LDStickerView()
    var filters = [CIFilter]()
    fileprivate var colorControl = ColorControl()

    let filterDescriptors: [(filterName: String, filterDisplayName: String)] = [
        ("CIColorControls", "None"),
        ("CIPhotoEffectMono", "Mono"),
        ("CIPhotoEffectTonal", "Tonal"),
        ("CIPhotoEffectNoir", "Noir"),
        ("CIPhotoEffectFade", "Fade"),
        ("CIPhotoEffectChrome", "Chrome"),
        ("CIPhotoEffectProcess", "Process"),
        ("CIPhotoEffectTransfer", "Transfer"),
        ("CIPhotoEffectInstant", "Instant"),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterBGView.isHidden = false
        tabBarView.delegate = self

        for descriptor in filterDescriptors {
            filters.append(CIFilter(name: descriptor.filterName)!)
        }
        self.photoFilterCollectionView.delegate = self
        self.photoFilterCollectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.itemSize = CGSizeMake(UIScreen.main.bounds.width/2 - 10, 190)
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        self.photoFilterCollectionView.collectionViewLayout = flowLayout
        filteredImageView.inputImage = getnewImage
        filteredImageView.contentMode = .scaleAspectFit
        filteredImageView.filter = filters[0]
        colorControl.input(filteredImageView.inputImage!)
    }
    
    fileprivate func setUISLidersValues() {
        contrastSlider.value = colorControl.currentContrastValue
        contrastSlider.maximumValue = colorControl.maxContrastValue
        contrastSlider.minimumValue = colorControl.minContrastValue
        
        brightnessSlider.value = colorControl.currentBrightnessValue
        brightnessSlider.maximumValue = colorControl.maxBrightnessValue
        brightnessSlider.minimumValue = colorControl.minBrightnessValue
        
        
    }
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterDescriptors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFilterCell", for: indexPath) as! PhotoFilterCollectionViewCell
        cell.filteredImageView.contentMode = .scaleAspectFill
        cell.filteredImageView.inputImage = UIImage(named: "duckling.jpg")
        cell.filteredImageView.filter = filters[indexPath.item]
        cell.filterNameLabel.text = filterDescriptors[indexPath.item].filterDisplayName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filteredImageView.filter = filters[indexPath.item]
    }
}
