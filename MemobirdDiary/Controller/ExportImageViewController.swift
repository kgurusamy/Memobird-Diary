//
//  ExportImageViewController.swift
//  MemobirdDiary
//
//  Created by Mohammed Aslam on 25/10/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData
extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
extension UIImage {
    func applying(contrast value: NSNumber) -> UIImage? {
        guard
            let ciImage = CIImage(image: self)?.applyingFilter("CIColorControls", parameters: [kCIInputContrastKey: value])
            else { return nil } // Swift 3 uses withInputParameters instead of parameters
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        UIImage(ciImage: ciImage).draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
// MARK: - UISlider @IBAction

extension ExportImageViewController {
    
    @IBAction func brightnesssliderbtn(_ sender: UISlider) {
        DispatchQueue.main.async {
           // self.brightnessLabel.text = "Brightness \(sender.value)"
            self.colorControl.brightness(sender.value)
            self.picimageView.image = self.colorControl.outputUIImage()
        }
    }
    
    @IBAction func contrastsliderbtn(_ sender: UISlider) {
        DispatchQueue.main.async {
          //  self.contrastLabel.text = "Contrast \(sender.value)"
            
            self.colorControl.contrast(sender.value)
            self.picimageView.image = self.colorControl.outputUIImage()
        }
    }
    
}
class ExportImageViewController: UIViewController,UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate,UITabBarDelegate {

    ////TabBarview
    @IBOutlet weak var undobtnoutlet: UIButton!
    @IBOutlet weak var scrollViewBG: UIScrollView!
    @IBOutlet weak var tabBarView: UITabBar!
    @IBOutlet weak var filterBGView: UIView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var collectionVerticalScrollview: UICollectionView!

    var picimageView = UIImageView()
    var picimageView1 = UIImageView()


    var textLabel = UILabel()
   // var scrollView: UIScrollView!
    var diaryEntries = [DiaryEntry]()
    var dataModelArr = [dataModel]()
    var selectedDiaryEntryIndex : Int! = 0
    var mode : String = ""
    var stickerView = LDStickerView()
    
    
    var addremovecount : Int = 0
    @IBOutlet weak var Exportimageview: UIImageView!
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    fileprivate var colorControl = ColorControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preview"
     

        filterBGView.isHidden = true
        self.scrollViewBG.delegate = self
        self.scrollViewBG.contentSize = CGSize(width:1.0, height: self.view.frame.size.height)
        self.scrollViewBG.backgroundColor = UIColor.white
        tabBarView.delegate = self
        self.collectionVerticalScrollview.dataSource = self
         self.collectionVerticalScrollview.delegate = self
        let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.itemSize = CGSizeMake(UIScreen.main.bounds.width/2 - 10, 190)
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        self.collectionVerticalScrollview.collectionViewLayout = flowLayout

        self.scrollViewBG.bringSubview(toFront: filterBGView)

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
       // scrollView.frame = CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: self.view.frame.size.height-102)
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getSavedData()
        loadData(atIndex : selectedDiaryEntryIndex)
        
    }
    @IBAction func undobtn(_ sender: Any) {
    }
    func loadData(atIndex : Int)
    {
       // self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
        
  
        if(diaryEntries.count > 0){
            let currentDiaryEntry = diaryEntries[selectedDiaryEntryIndex]
            let diaryData = currentDiaryEntry.diary_data as! [dataModel]
            for dataModelObj in diaryData
            {
                stickerView = LDStickerView(frame: CGRect(x: dataModelObj.xPos, y: dataModelObj.yPos, width: dataModelObj.width, height: dataModelObj.height))
                stickerView.center = CGPoint(x:dataModelObj.xPos, y:dataModelObj.yPos)
                stickerView.backgroundColor = UIColor.clear
                stickerView.accessibilityIdentifier = "drag"
                
                if(dataModelObj.type == contentType.image.rawValue){
                    let fullImagePath = imagesDirectoryPath + "/\(dataModelObj.imageName)"
                    do {
                        let fileURLPath = URL(fileURLWithPath : fullImagePath)
                        let imageData = try Data(contentsOf: fileURLPath)
                        let myImg = UIImage(data: imageData)
                        picimageView = UIImageView()
                        picimageView1 = UIImageView()

                        
     ////////////////////////                   /////////////////////
                       // let _:CGRect = CGRect(x:0, y:0, width:myImg!.size.width, height:myImg!.size.height)
                        // let colorSpace = CGColorSpaceCreateDeviceGray()
                        
                        let colorSpace = CGColorSpaceCreateDeviceRGB()
                        let width = 384
                        let height = myImg?.size.height
                        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
                        //let bytesPerPixel = 4
                        //let bytesPerRow = Int(width) * bytesPerPixel
                        let context = CGContext(data: nil,
                                                width: Int(width),
                                                height: Int(height!),
                                                bitsPerComponent: Int(8),
                                                bytesPerRow: Int(0),
                                                space: colorSpace,
                                                bitmapInfo: bitmapInfo.rawValue)
                        
                      //  context?.draw((myImg?.cgImage!)!, in: CGRect(origin: .zero, size: (myImg?.size)!))
                        context?.draw((myImg?.cgImage!)!, in: CGRect(x:0, y:0, width:384, height:height!))
                        
                        let imageRef = context?.makeImage()
                        //let newImage = UIImage(CGImage: imageRef!)
                        let newImage:UIImage = UIImage( cgImage: imageRef! )
                        // we create Core Image context
                        let ciContext = CIContext(options: nil)
                        // we create a CIImage, think of a CIImage as image data for processing, nothing is displayed or can be displayed at this point
                        //  let coreImage = CIImage(cgImage: resultImage as! CGImage)
                        let coreImage = CIImage(image : newImage)
                        
                        // we pick the filter we want
                        let filter = CIFilter(name: "CIDotScreen")
                        // we pass our image as input
                        filter?.setValue(coreImage, forKey: kCIInputImageKey)
                        // filter?.setValue(3, forKey: kCIInputWidthKey)
                        
                        // we retrieve the processed image
                        let filteredImageData = filter?.value(forKey: kCIOutputImageKey) as! CIImage
                        // returns a Quartz image from the Core Image context
                        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
                        // this is our final UIImage ready to be displayed
                        //  let personciImage = CIImage(cgImage: imageView.image!.cgImage!)
                        // let filteredImage = CIImage(cgImage: filteredImageRef!);
                        let filteredImage:UIImage = UIImage( cgImage: filteredImageRef! )
                        //imageView.image = filteredImage
          ///////////////////////////////////////////////////////
                        picimageView.image = filteredImage
                        picimageView.frame = CGRect(x: 20 , y: 20, width: stickerView.frame.size.width-40, height: stickerView.frame.size.height-40)
                        colorControl.input(picimageView.image!)

                       // imageView  = UIImageView(frame:CGRect(x:20, y:100, width:300, height:300));
                        picimageView.accessibilityIdentifier = dataModelObj.imageName
                        stickerView.setContentView(picimageView)
                    } catch {
                        print("Error loading image : \(error)")
                    }
                }
                else
                {
                    textLabel = UILabel()
                    textLabel.attributedText = dataModelObj.attributedString
                    textLabel.numberOfLines = 0
                    textLabel.frame = CGRect(x: 20 , y: 20, width: stickerView.frame.size.width-40, height: stickerView.frame.size.height-40)
                    textLabel.accessibilityIdentifier = "dragText"
                    textLabel.adjustsFontSizeToFitWidth = true
                    textLabel.minimumScaleFactor = 0.5
                    textLabel.textAlignment = .center
                    let myImg = UIImage.imageWithLabel(label: textLabel)
                    ////////////////////////                   /////////////////////
                    // we create a CIImage, think of a CIImage as image data for processing, nothing is displayed or can be displayed at this point
                    //  let coreImage = CIImage(cgImage: resultImage as! CGImage)
                    let ciContext = CIContext(options: nil)

                    let coreImage = CIImage(image : myImg)
                    
                    // we pick the filter we want
                    let filter = CIFilter(name: "CIDotScreen")
                    // we pass our image as input
                    filter?.setValue(coreImage, forKey: kCIInputImageKey)
                     filter?.setValue(3, forKey: kCIInputWidthKey)
                    
                    // we retrieve the processed image
                    let filteredImageData = filter?.value(forKey: kCIOutputImageKey) as! CIImage
                    // returns a Quartz image from the Core Image context
                    let filteredImageRef = ciContext.createCGImage(filteredImageData, from:filteredImageData.extent)
                   // let filteredImageRef = CGContext.createCGImage(filteredImageData, from: filteredImageData.extent)
                    // this is our final UIImage ready to be displayed
                    //  let personciImage = CIImage(cgImage: imageView.image!.cgImage!)
                    // let filteredImage = CIImage(cgImage: filteredImageRef!);
                    let filteredImage:UIImage = UIImage( cgImage: filteredImageRef! )
                    //imageView.image = filteredImage
                    ///////////////////////////////////////////////////////
                    picimageView1.image = filteredImage
                    picimageView1.frame = CGRect(x: 20 , y: 20, width: stickerView.frame.size.width-40, height: stickerView.frame.size.height-40)
                    colorControl.input(picimageView1.image!)

                    picimageView1.accessibilityIdentifier = dataModelObj.imageName
                    stickerView.setContentView(picimageView1)
                    //stickerView.setContentView(textLabel)
                }
                stickerView.transform = CGAffineTransform(rotationAngle : dataModelObj.radians)
                self.scrollViewBG.addSubview(stickerView)
                
                ///
                self.setUISLidersValues()
                
            }
        }
    }
    fileprivate func setUISLidersValues() {
        contrastSlider.value = colorControl.currentContrastValue
        contrastSlider.maximumValue = colorControl.maxContrastValue
        contrastSlider.minimumValue = colorControl.minContrastValue
        
        brightnessSlider.value = colorControl.currentBrightnessValue
        brightnessSlider.maximumValue = colorControl.maxBrightnessValue
        brightnessSlider.minimumValue = colorControl.minBrightnessValue
        
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getSavedData()
    {
        let fetchRequest: NSFetchRequest<DiaryEntry> = DiaryEntry.fetchRequest()
        
        // Sorting data according to modified time
        let sort = NSSortDescriptor(key: "modified_time", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            
            diaryEntries = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
            
        } catch {
            print(error)
        }
    }
    // MARK:- Tab bar
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
        if(item.tag == 1){
            
        }
        if(item.tag == 2){
            
        }
        if(item.tag == 3){
            
        }
        if(item.tag == 4){
           
        }
        }
       
    }
    var myArray = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    let rows = 3
    let columnsInPage = 5
    var itemsInPage: Int { return columnsInPage*rows }
    var columns: Int { return myArray.count%itemsInPage <= columnsInPage ? ((myArray.count/itemsInPage)*columnsInPage)  + (myArray.count%itemsInPage) : ((myArray.count/itemsInPage)+1)*columnsInPage }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        cell.textlabel.text = self.items[indexPath.item]
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
   
    // make a cell for each cell index path
   /* func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        
        

        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.textlabel.text = self.items[indexPath.item]
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }*/
 
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        if(indexPath.item == 0)
        {
            
        }
        if(indexPath.item == 1)
        {
            
        }
        if(indexPath.item == 2)
        {
            
        }
        if(indexPath.item == 3)
        {
            
        }
        if(indexPath.item == 4)
        {
            
        }
        if(indexPath.item == 5)
        {
            
        }
        if(indexPath.item == 6)
        {
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
