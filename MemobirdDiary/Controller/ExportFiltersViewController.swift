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
import TouchDraw


extension ExportFiltersViewController {
    
    @IBAction func brightnesssliderbtn(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.colorControl.brightness(sender.value)
            self.filteredImageView.inputImage = self.colorControl.outputUIImage()
        }
    }
    
    @IBAction func contrastsliderbtn(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.colorControl.contrast(sender.value)
            self.filteredImageView.inputImage = self.colorControl.outputUIImage()
        }
    }
    
}
class ExportFiltersViewController:UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UITabBarDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate,TouchDrawViewDelegate  {
    @IBOutlet weak var strokesbgview: UIView!
    
    @IBOutlet weak var stroke1btn: UIButton!
    @IBOutlet weak var stroke2btn: UIButton!
    @IBOutlet weak var stroke3btn: UIButton!
    @IBOutlet weak var stroke4btn: UIButton!
    @IBOutlet weak var stroke5btn: UIButton!
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
    
    @IBOutlet weak var tabBarDrawView: UITabBar!
    
    @IBOutlet weak var drawbgview: UIView!
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
        ("CILineOverlay", "Sketch"),
        ("CIColorInvert", "Invert"),
        ("CIComicEffect", "Comic"),
        ("CIEdgeWork", "Pencil"),
        ("CIPhotoEffectChrome", "Chrome"),
        ("CIPhotoEffectProcess", "Process"),
        ("CIPhotoEffectTransfer", "Transfer"),
        ("CIPhotoEffectInstant", "Instant"),
        ("CIStraightenFilter", "Straighten"),
        ("CITemperatureAndTint", "Temperature"),
        ("CITileFilter", "TileFilter"),
        ("CIToneCurve", "ToneCurve"),
        ("CIUnsharpMask", "UnsharpMask"),
        ]
    
    ////////////NEW CODE FOR PAINT
    private static let deltaWidth = CGFloat(2.0)
    
    @IBOutlet weak var drawVieww: TouchDrawView!
    ///////////////


    
    //////////
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Processing"
        
        filterBGView.isHidden = true
        tabBarView.delegate = self
        drawbgview.isHidden = true
        undobtnoutlet.isHidden = false

        undobtnoutlet.backgroundColor = .clear
        undobtnoutlet.layer.cornerRadius = 24
        undobtnoutlet.layer.borderWidth = 1
        undobtnoutlet.layer.borderColor = UIColor.black.cgColor
        for descriptor in filterDescriptors {
            filters.append(CIFilter(name: descriptor.filterName)!)
        }
        self.photoFilterCollectionView.delegate = self
        self.photoFilterCollectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        self.photoFilterCollectionView.collectionViewLayout = flowLayout
        filteredImageView.inputImage = getnewImage
        filteredImageView.contentMode = .scaleAspectFit
        filteredImageView.backgroundColor = UIColor.clear
        filteredImageView.filter = filters[0]
        colorControl.input(filteredImageView.inputImage!)
        drawVieww.setColor(nil)

        strokesbgview.isHidden = true
    }
    
    @IBAction func cancelbtn(_ sender: Any) {
        
        drawVieww.undo()


    }
    @IBAction func storkebtn(_ sender: Any) {
        strokesbgview.isHidden = false


    }
    @IBAction func eraserbtn(_ sender: Any)
    {
        drawVieww.setColor(nil)

    }
    @IBAction func pencilbtn(_ sender: Any) {
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
        cell.filteredImageView.contentMode = .scaleAspectFit
        cell.backgroundColor = UIColor.clear
        cell.filteredImageView.inputImage = UIImage(named: "duckling.jpg")
        cell.filteredImageView.filter = filters[indexPath.item]
        cell.filterNameLabel.text = filterDescriptors[indexPath.item].filterDisplayName
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 68.0 , height: 72.0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filteredImageView.filter = filters[indexPath.item]
    }
    // MARK: - Private methods
    private func updateEditButtonEnabled() {
    }
    
    // MARK: - CropView
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: true, completion: nil)
        filteredImageView.inputImage = image
        updateEditButtonEnabled()
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
        updateEditButtonEnabled()
    }
    
    // MARK: - UIImagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        getnewImage = image
        filteredImageView.inputImage = getnewImage

        dismiss(animated: true) { [unowned self] in
        }
    }
    @IBAction func undobtn(_ sender: Any)
    {
        for descriptor in filterDescriptors {
            filters.append(CIFilter(name: descriptor.filterName)!)
        }
        self.photoFilterCollectionView.delegate = self
        self.photoFilterCollectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        self.photoFilterCollectionView.collectionViewLayout = flowLayout
        filteredImageView.inputImage = getnewImage
        filteredImageView.contentMode = .scaleAspectFit
        filteredImageView.filter = filters[0]
        colorControl.input(filteredImageView.inputImage!)
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if(item.tag == 0){
            if(filterBGView.isHidden == true)
            {
                filterBGView.isHidden = false
                self.undobtnoutlet.frame = CGRect(x: 290, y: 370, width: self.undobtnoutlet.frame.width, height: self.undobtnoutlet.frame.height)
                
            }else{
                filterBGView.isHidden = true
                self.undobtnoutlet.frame = CGRect(x: 290, y: 540, width: self.undobtnoutlet.frame.width, height: self.undobtnoutlet.frame.height)
                
            }
        }
            if(item.tag == 1){
                let controller = CropViewController()
                controller.delegate = self
                controller.image = getnewImage
                
                let navController = UINavigationController(rootViewController: controller)
                present(navController, animated: true, completion: nil)
            }
            if(item.tag == 2){
               

            }
            if(item.tag == 3){
                undobtnoutlet.isHidden = true
                filterBGView.isHidden = true

                tabBarView.isHidden = true
                tabBarView.delegate = nil
                drawbgview.isHidden = false
                drawVieww.delegate = self
                let color = UIColor.black
                drawVieww.setColor(color)
                drawVieww.setWidth(ExportFiltersViewController.deltaWidth)
            }
            if(item.tag == 4){
                UIView.animate(withDuration: 1.0, animations: {
                
                    self.filteredImageView.transform = self.filteredImageView.transform.rotated(by: CGFloat(M_PI_2))
                })
            }
       
        
    }
    // MARK: - Actions
    @IBAction func stroke1btn(_ sender: Any) {
       drawVieww.setWidth(CGFloat(2.0))
        strokesbgview.isHidden = true

    }
    @IBAction func stroke2btn(_ sender: Any) {
        drawVieww.setWidth(CGFloat(6.0))
        strokesbgview.isHidden = true

    }
    @IBAction func stroke3btn(_ sender: Any) {
       drawVieww.setWidth(CGFloat(8.0))
        strokesbgview.isHidden = true

    }
    @IBAction func saveBtn(_ sender: Any)
    {
    }
    @IBAction func stroke4btn(_ sender: Any) {
        drawVieww.setWidth(CGFloat(12.0))
        strokesbgview.isHidden = true

    }
    @IBAction func stroke5btn(_ sender: Any) {
        drawVieww.setWidth(CGFloat(14.0))
        strokesbgview.isHidden = true

    }
    @IBAction func Graffitibtn(_ sender: Any)
    {
        let color = UIColor.black
        drawVieww.setColor(color)
    }
}

