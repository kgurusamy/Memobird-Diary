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

extension UIView {
    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
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
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4 = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
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
    @IBOutlet weak var imgStrokeIcon : UIImageView!
    @IBOutlet weak var imgPencilIcon : UIImageView!
    @IBOutlet weak var imgEraserIcon : UIImageView!
    @IBOutlet weak var filteredImageView: FilteredImageView!
    @IBOutlet weak var photoFilterCollectionView: UICollectionView!
    ////TabBarview
    @IBOutlet weak var undobtnoutlet: UIButton!
    @IBOutlet weak var scrollViewBG: UIScrollView!
    @IBOutlet weak var tabBarView: UITabBar!
    @IBOutlet weak var filterBGView: UIView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var rightBarButtonItem : UIBarButtonItem!
    
    var getnewImage: UIImage!

    
    
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
    var drawcheckbool:Bool = false

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
        ("CITileFilter", "TileFilter"),
        ("CIToneCurve", "ToneCurve"),
        
        ]
    
    ////////////NEW CODE FOR PAINT
    private static let deltaWidth = CGFloat(2.0)
    @IBOutlet weak var drawVieww: TouchDrawView!
    ///////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Processing"
        self.rightBarButtonItem.title = "OK"
        
        filterBGView.isHidden = true
        tabBarView.delegate = self
        drawbgview.isHidden = true
        undobtnoutlet.isHidden = false

        undobtnoutlet.backgroundColor = .clear
        undobtnoutlet.layer.cornerRadius = 24
        undobtnoutlet.layer.borderWidth = 1
        undobtnoutlet.layer.borderColor = UIColor.black.cgColor
        
        ///////////?FIlter Code
        if(getnewImage !== nil){
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
        }else{
            filteredImageView.isHidden = true
            undobtnoutlet.isHidden = true
            let color = UIColor.black
            drawVieww.setColor(color)
            undobtnoutlet.isHidden = true
            filterBGView.isHidden = true
            
            tabBarView.isHidden = true
            //tabBarView.delegate = nil
            drawbgview.isHidden = false
            drawVieww.delegate = self
            drawVieww.setWidth(ExportFiltersViewController.deltaWidth)

        }
        ///////////////////
        drawVieww.setColor(nil)
        strokesbgview.isHidden = true
        createPreviewImagesFolder()
        
        // Icon background color change
        imgPencilIcon.backgroundColor = UIColor.lightGray
        imgEraserIcon.backgroundColor = UIColor.clear
        
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
        imgEraserIcon.backgroundColor = UIColor.lightGray
        imgPencilIcon.backgroundColor = UIColor.clear
    }
    
    @IBAction func pencilbtn(_ sender: Any) {
        imgEraserIcon.backgroundColor = UIColor.clear
        imgPencilIcon.backgroundColor = UIColor.lightGray
    }

//     @IBAction func closeDrawViewMenu(_ sender: Any) {
//        drawbgview.isHidden = true
//        tabBarView.isHidden = false
//        strokesbgview.isHidden = true
//    }
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        drawcheckbool = false
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
                print("screenType:", UIDevice.current.screenType.rawValue)
                if(UIDevice.current.screenType.rawValue == "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus")
                {
                    self.undobtnoutlet.frame = CGRect(x: 290, y: 400, width: self.undobtnoutlet.frame.width, height: self.undobtnoutlet.frame.height)
                }else{
                    self.undobtnoutlet.frame = CGRect(x: 290, y: 370, width: self.undobtnoutlet.frame.width, height: self.undobtnoutlet.frame.height)
                }
            }else{
                filterBGView.isHidden = true
                print("screenType:", UIDevice.current.screenType.rawValue)
                if(UIDevice.current.screenType.rawValue == "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus")
                {
                    self.undobtnoutlet.frame = CGRect(x: 290, y: 580, width: self.undobtnoutlet.frame.width, height: self.undobtnoutlet.frame.height)
                }else{
                    self.undobtnoutlet.frame = CGRect(x: 290, y: 540, width: self.undobtnoutlet.frame.width, height: self.undobtnoutlet.frame.height)
                }
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
                //tabBarView.delegate = nil
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
        imgStrokeIcon.image = UIImage(named: "ico_dot_01.png")
        drawcheckbool = true

    }
    @IBAction func stroke2btn(_ sender: Any) {
        drawVieww.setWidth(CGFloat(6.0))
        strokesbgview.isHidden = true
        imgStrokeIcon.image = UIImage(named: "ico_dot_02.png")
        drawcheckbool = true

    }
    @IBAction func stroke3btn(_ sender: Any) {
       drawVieww.setWidth(CGFloat(8.0))
        strokesbgview.isHidden = true
        imgStrokeIcon.image = UIImage(named: "ico_dot_03.png")
        drawcheckbool = true

    }
    @IBAction func saveBtn(_ sender: Any)
    {
        if(self.rightBarButtonItem.title == "OK"){
            //self.rightBarButtonItem.title = "Print"
            insertImageToMainDairyView()
            // Show filter options here
        }else if(self.rightBarButtonItem.title == "Preview"){
            saveDataToPreviewList()
        }
        else if(self.rightBarButtonItem.title == "Print")
        {
            let alertView = UIAlertController(title: "", message: "Coming Soon", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                
            })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    @IBAction func stroke4btn(_ sender: Any) {
        drawVieww.setWidth(CGFloat(12.0))
        strokesbgview.isHidden = true
        imgStrokeIcon.image = UIImage(named: "ico_dot_04.png")
        drawcheckbool = true


    }
    @IBAction func stroke5btn(_ sender: Any) {
        drawVieww.setWidth(CGFloat(14.0))
        strokesbgview.isHidden = true
        imgStrokeIcon.image = UIImage(named: "ico_dot_05.png")
        drawcheckbool = true


    }
    @IBAction func Graffitibtn(_ sender: Any)
    {
        let color = UIColor.black
        drawVieww.setColor(color)
    }
    
    // MARK: - CoreData methods
    func saveDataToPreviewList()
    {
        if #available(iOS 10.0, *) {
            let coreDataPreviewList = PreviewList(context: CoreDataStack.managedObjectContext)
            coreDataPreviewList.modified_time = Date()
            coreDataPreviewList.preview_image = captureImageForPreview()
            
        } else {
            // Fallback on earlier versions
            let entityDesc = NSEntityDescription.entity(forEntityName: "PreviewList", in: CoreDataStack.managedObjectContext)
            let coreDataPreviewList = PreviewList(entity: entityDesc!, insertInto: CoreDataStack.managedObjectContext)
            coreDataPreviewList.preview_image = captureImageForPreview()
            coreDataPreviewList.modified_time = Date()
        }
        CoreDataStack.saveContext()
      
    }
    func insertImageToMainDairyView() {
        
        var getpreviewimage: UIImage!
        if(getnewImage == nil)
        {
            getpreviewimage = drawVieww?.snapshot
            
        }else{
            if(drawcheckbool == true){
                 getpreviewimage = drawVieww?.snapshot

            }else{
                getpreviewimage = filteredImageView?.snapshot
            }
        }
        
        let DiaryListVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2] as! DiaryViewController!
        DiaryListVC?.PreviewSelectedimage = getpreviewimage
        self.navigationController?.popToViewController(DiaryListVC!, animated: true)
        // self.navigationController?.pushViewController(DiaryListVC, animated: true)
        var imageName = Date().description
        imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
        imageName = imageName.replacingOccurrences(of: ":", with: "")
        let fullImagePath = previewImagesDirectoryPath + "/\(imageName)"
        
        let data = UIImagePNGRepresentation((getpreviewimage)!)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            print("Inserted image successfully in local")
        }
       
    }
    func captureImageForPreview() -> String? {

        var getpreviewimage: UIImage!
        if(getnewImage == nil)
        {
            getpreviewimage = drawVieww?.snapshot

        }else{
            getpreviewimage = filteredImageView?.snapshot

        }
    
        let DiaryListVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2] as! DiaryViewController!
        DiaryListVC?.PreviewSelectedimage = getpreviewimage
        self.navigationController?.popToViewController(DiaryListVC!, animated: true)
       // self.navigationController?.pushViewController(DiaryListVC, animated: true)
        var imageName = Date().description
        imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
        imageName = imageName.replacingOccurrences(of: ":", with: "")
        let fullImagePath = previewImagesDirectoryPath + "/\(imageName)"
        
        let data = UIImagePNGRepresentation((getpreviewimage)!)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            print("Preview Image saved successfully in local")
        }
        return imageName
    }
    
    func createPreviewImagesFolder()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        previewImagesDirectoryPath = documentDirectorPath + "/PreviewImages"
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: previewImagesDirectoryPath, isDirectory: &objcBool)
        print("Preview                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Images path : \(previewImagesDirectoryPath)")
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: previewImagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                
            }catch{
                print("Something went wrong while creating a folder")
            }
        }
    }
}

