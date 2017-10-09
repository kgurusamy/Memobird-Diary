//
//  DiaryViewController.swift
//  MemobirdDiary
//
//  Created by Mohammed Aslam on 25/09/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData

var diaryImagesDirectoryPath : String!
var imagesDirectoryPath : String!

// For checking content type
enum contentType: Int {
    case image = 0
    case text = 1
}

class DiaryViewController: UIViewController,UITabBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate {

    @IBOutlet weak var tabBarview: UITabBar!
    
    let imagePicker = UIImagePickerController()
    var picimageView = UIImageView()
    var textLabel = UILabel()
    var scrollView: UIScrollView!
    var diaryEntries = [DiaryEntry]()
    var dataModelArr = [dataModel]()
    var selectedDiaryEntryIndex : Int! = -1
    var stickerView = LDStickerView()
    var addremovecount : Int = 0

    func loadData(atIndex : Int)
    {
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
                        picimageView.image = myImg
                        picimageView.frame = CGRect(x: 20 , y: 20, width: stickerView.frame.size.width-40, height: stickerView.frame.size.height-40)
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
                    stickerView.setContentView(textLabel)
                }
                stickerView.transform = CGAffineTransform(rotationAngle : dataModelObj.radians)
                self.scrollView.addSubview(stickerView)

            hideOtherViewSelection()
        }
    }
    }
    
    
    func saveDataToCoredata(fromView : UIScrollView)
    {
        if(fromView.subviews.count > 0)
        {
            if(diaryEntries.count > 0 && selectedDiaryEntryIndex != -1)
            {
                deleteFileWithImageName(imageName: diaryEntries[selectedDiaryEntryIndex].diary_image!, isDiary: true)
                CoreDataStack.managedObjectContext.delete(diaryEntries[selectedDiaryEntryIndex])
            }
            dataModelArr.removeAll()
            for dragView in fromView.subviews
            {
                if(dragView.accessibilityIdentifier == "drag"){
                //print("subviews : ")
                //print(dragView.subviews)
                     let radians:Double = Double(atan2f(Float(Double(dragView.transform.b)), Float(Double(dragView.transform.a))))
                    
                    let dataModelObj : dataModel
                    if(dragView.subviews[0].accessibilityIdentifier != "dragText")
                    {
                        
                        let imageView = dragView.subviews[0] as? UIImageView
                        dataModelObj = dataModel(imageName : (imageView?.accessibilityIdentifier)!, xPos :dragView.center.x, yPos :dragView.center.y, width : dragView.bounds.size.width, height : dragView.bounds.size.height,radians : CGFloat(radians), angle : CGFloat(0), type:contentType.image.rawValue, attributedString:(NSAttributedString(string:"")))
                        
                    }
                    else
                    {
                        let labelView = dragView.subviews[0] as? UILabel
                        dataModelObj = dataModel(imageName : (labelView?.accessibilityIdentifier)!, xPos :dragView.center.x, yPos :dragView.center.y, width : dragView.bounds.size.width, height : dragView.bounds.size.height,radians : CGFloat(radians), angle : CGFloat(0), type: contentType.text.rawValue, attributedString : (labelView?.attributedText)!)
                    }
                    
                    
                    dataModelArr.append(dataModelObj)
                }
                
            }
            if #available(iOS 10.0, *) {
                let coreDataDiary = DiaryEntry(context: CoreDataStack.managedObjectContext)
                coreDataDiary.modified_time = Date()
                coreDataDiary.diary_image = captureDiaryScreenAndSave()
               
                coreDataDiary.diary_data = dataModelArr as NSObject
                coreDataDiary.diary_height = Float(self.scrollView.contentSize.height)
                
            } else {
                // Fallback on earlier versions
                let entityDesc = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: CoreDataStack.managedObjectContext)
                let coreDataDiary = DiaryEntry(entity: entityDesc!, insertInto: CoreDataStack.managedObjectContext)
                coreDataDiary.diary_image = captureDiaryScreenAndSave()
                
                coreDataDiary.modified_time = Date()
                coreDataDiary.diary_data = dataModelArr as NSObject
                coreDataDiary.diary_height = Float(self.scrollView.contentSize.height)
            }
            CoreDataStack.saveContext()
        }
        let historyVC = storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        self.navigationController?.pushViewController(historyVC, animated: true)
        
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
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    {
        self.scrollView.isScrollEnabled = true
        hideOtherViewSelection()
        //stickerView.hideEditingHandles()
    }
    // MARK:- ViewController delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        addremovecount = 1;
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width:1.0, height: self.view.frame.height)
        self.scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(scrolltouchhandlePan))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        tabBarview.delegate = self
        imagePicker.delegate = self
        
        createImagesFolder()
        createDiaryImagesFolder()
        
        if(diaryEntries.count==0){
        }
        if(selectedDiaryEntryIndex != -1){
            getSavedData()
            loadData(atIndex : selectedDiaryEntryIndex)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
//        NotificationCenter.default.addObserver(self, selector: #selector(DiaryViewController.scrolldisableReceivedNotification(notification:)), name: Notification.Name("ScollviewDisableNotificationIdentifier"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(DiaryViewController.scrollenableReceivedNotification(notification:)), name: Notification.Name("ScollviewEnableNotificationIdentifier"), object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = CGRect(x: 10, y: 70, width: self.view.frame.size.width-20, height: self.view.frame.size.height-130)
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("ScollviewDisableNotificationIdentifier"), object: nil)
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("ScollviewEnableNotificationIdentifier"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- ScrollView methods
    @objc func scrolltouchhandlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began
        {
            self.scrollView.isScrollEnabled = true
            hideOtherViewSelection()
            //stickerView.hideEditingHandles()
        }
    }
//    @objc func scrolldisableReceivedNotification(notification: Notification)
//    {
//        //Take Action on Notification
//        self.scrollView.isScrollEnabled = false
//        //hideOtherViewSelection()
//    }
//    @objc func scrollenableReceivedNotification(notification: Notification)
//    {
//        //Take Action on Notification
//        
//        self.scrollView.isScrollEnabled = true
//    }
//
    // MARK:- Custom methods
    @IBAction func savebtn(_ sender: Any)
    {
        saveDataToCoredata(fromView: self.scrollView)
    }
    
    func dragzoomroatateview(img : UIImage, imgName : String, type : Int, attributedString : NSAttributedString)
    {
        var calcWidth = CGFloat(0)
        var calcHeight = CGFloat(0)
        
        if(type == contentType.image.rawValue)
        {
            calcWidth = CGFloat(200)
            calcHeight = CGFloat(200)
        }
        else
        {
            calcWidth = CGFloat(200)
            calcHeight = CGFloat(120)
        }

        stickerView = LDStickerView(frame: CGRect(x: 40, y: 200, width: calcWidth, height: calcHeight))
        stickerView.accessibilityIdentifier = "drag"

        if(type == contentType.image.rawValue){
            picimageView = UIImageView()
            picimageView.image = img
            picimageView.frame = CGRect(x: 20 , y: 20, width: calcWidth-40, height: calcHeight-40)
            picimageView.accessibilityIdentifier = imgName
            picimageView.contentMode = UIViewContentMode.scaleToFill
            stickerView.setContentView(picimageView)
        }
        else{
            textLabel = UILabel()
            textLabel.attributedText = attributedString
            textLabel.numberOfLines = 0
            textLabel.frame = CGRect(x: 20 , y: 20, width: calcWidth-40, height: calcHeight-40)
            textLabel.accessibilityIdentifier = "dragText"
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.textAlignment = .center
            textLabel.sizeToFit()
            stickerView.setContentView(textLabel)
        }
    
        if(stickerView.subviews.count == 3){
            stickerView.subviews[1].isHidden = false
            stickerView.subviews[2].isHidden = false
        }
        self.scrollView.addSubview(stickerView)
        self.scrollView.isScrollEnabled = false
    }

    // MARK:- Tab bar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if(item.tag == 0){
            let TextEditVC = storyboard?.instantiateViewController(withIdentifier: "TextEditViewController") as! TextEditViewController
            self.navigationController?.pushViewController(TextEditVC, animated: true)
        }
        if(item.tag == 1){
          
            let optionMenu = UIAlertController(title: nil, message: "Choose Image", preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openCamera()
            })
            let gallaryAction = UIAlertAction(title: "Gallery", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openGallary()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            optionMenu.addAction(cameraAction)
            optionMenu.addAction(gallaryAction)
            optionMenu.addAction(cancelAction)
            optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(optionMenu, animated: true) {
                print("option menu presented")
            }
            
        }
        if(item.tag == 2){
            
        }
        if(item.tag == 3){
            print("Test3")
            if(addremovecount <= 3)
            {
                addremovecount += 1
                let addremovecountcgfloat = CGFloat(addremovecount)
                
                self.scrollView.contentSize = CGSize(width:1.0, height: self.view.frame.height*addremovecountcgfloat)
            }else{
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Alert!"
                alertView.message = "Maximum 3 page allowed"
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
            
        }
        if(item.tag == 4){
            print("Test4")
            if(addremovecount >= 1)
            {
                addremovecount -= 1
                let addremovecountcgfloat = CGFloat(addremovecount)
                
                self.scrollView.contentSize = CGSize(width:1.0, height: self.view.frame.height*addremovecountcgfloat)
            }
        }
        if(item.tag == 5){
           
            let HistoryVC = storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
            self.navigationController?.pushViewController(HistoryVC, animated: true)
        }
    }
   
    
    // MARK:- Image picker methods
   
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        var imageName = Date().description
        imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
        let fullImagePath = imagesDirectoryPath + "/\(imageName)"
        let myImage = self.fixOrientation(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!)
        
        dragzoomroatateview(img:myImage, imgName: imageName, type: contentType.image.rawValue, attributedString: NSAttributedString(string:""))
        
        let data = UIImagePNGRepresentation(myImage)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            print("image saved successfully in local")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: - Helper methods
    func createImagesFolder()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath + "/Images"
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        print("Images path : \(imagesDirectoryPath)")
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a folder")
            }
        }
    }
    
    func createDiaryImagesFolder()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        diaryImagesDirectoryPath = documentDirectorPath + "/DiaryImages"
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: diaryImagesDirectoryPath, isDirectory: &objcBool)
        print("DiaryImages path : \(diaryImagesDirectoryPath)")
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: diaryImagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                
            }catch{
                print("Something went wrong while creating a folder")
            }
        }
    }
    
    func hideOtherViewSelection()
    {
        for view in self.scrollView.subviews
        {
            if(view.accessibilityIdentifier == "drag"){
                if(view.subviews.count == 3){
                    view.subviews[1].isHidden = true
                    view.subviews[2].isHidden = true
                }
            }
        }
    }
    
    func fixOrientation(image: UIImage) -> UIImage {
        // No-op if the orientation is already correct
        if (image.imageOrientation == UIImageOrientation.up) { return image; }
        
        print(image.imageOrientation)
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch (image.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -.pi/2)
            break
        case .up, .upMirrored:
            break
        }
        
        switch (image.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .up, .down, .left, .right:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)
        
        ctx!.concatenate(transform);
        
        switch (image.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx?.draw(image.cgImage!, in: CGRect(origin: .zero, size: CGSize(width: image.size.height, height: image.size.width)))
            
            break
            
        default:
            ctx?.draw(image.cgImage!, in: CGRect(origin: .zero, size: CGSize(width: image.size.width, height: image.size.height)))
            break
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx!.makeImage()
        let img = UIImage(cgImage: cgimg!)
        
        return img
    }
    func captureDiaryScreenAndSave() -> String? {
        hideOtherViewSelection()
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, self.view.layer.contentsScale)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var imageName = Date().description
        imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
        let fullImagePath = diaryImagesDirectoryPath + "/\(imageName)"
        
        let data = UIImagePNGRepresentation((image)!)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            print("DiaryImage saved successfully in local")
        }
        return imageName
    }
}
// Delete file with imageName
func deleteFileWithImageName(imageName : String, isDiary : Bool)
{
    if(imageName != ""){
        let filePath : String
        if(isDiary == true){
            filePath = "\(diaryImagesDirectoryPath!)/\(imageName)"
        }else {
            filePath = "\(imagesDirectoryPath!)/\(imageName)"
        }
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
}

func deleteImagesFromDiaryData(dataModelArr : [dataModel])
{
    for dataModelObj in dataModelArr
    {
        if(dataModelObj.type == contentType.image.rawValue){
            deleteFileWithImageName(imageName: dataModelObj.imageName, isDiary: false)
        }
    }
}
