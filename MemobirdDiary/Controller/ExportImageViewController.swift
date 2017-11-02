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
class ExportImageViewController: UIViewController,UIScrollViewDelegate {
    
    var picimageView = UIImageView()
    var picimageView1 = UIImageView()

    var textLabel = UILabel()
    var scrollView: UIScrollView!
    var diaryEntries = [DiaryEntry]()
    var dataModelArr = [dataModel]()
    var selectedDiaryEntryIndex : Int! = 0
    var mode : String = ""
    var stickerView = LDStickerView()
    var addremovecount : Int = 0
    @IBOutlet weak var Exportimageview: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preview"
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width:1.0, height: self.view.frame.size.height)
        self.scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getSavedData()
        loadData(atIndex : selectedDiaryEntryIndex)
        
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
                    let coreImage = CIImage(image : newImage)
                    
                    // we pick the filter we want
                    let filter = CIFilter(name: "CIDotScreen")
                    // we pass our image as input
                    filter?.setValue(coreImage, forKey: kCIInputImageKey)
                     filter?.setValue(3, forKey: kCIInputWidthKey)
                    
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
                    picimageView1.image = filteredImage
                    picimageView1.frame = CGRect(x: 20 , y: 20, width: stickerView.frame.size.width-40, height: stickerView.frame.size.height-40)
                    picimageView1.accessibilityIdentifier = dataModelObj.imageName
                    stickerView.setContentView(picimageView1)
                    //stickerView.setContentView(textLabel)
                }
                stickerView.transform = CGAffineTransform(rotationAngle : dataModelObj.radians)
                self.scrollView.addSubview(stickerView)
                
            }
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
