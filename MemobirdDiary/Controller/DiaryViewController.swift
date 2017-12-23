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
import CoreImage

var diaryImagesDirectoryPath : String!
var imagesDirectoryPath : String!
var previewImagesDirectoryPath : String!

// For checking content type
enum contentType: Int {
    case image = 0
    case text = 1
    case imageAndText = 2
}
// For checking text Formatting buttons tag
enum textFormat: Int {
    case bold = 101
    case underline = 102
    case italic = 103
    case leftAlign = 104
    case centerAlign = 105
    case rightAlign = 106
}

class DiaryViewController: UIViewController,UITabBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var contrastslider: UISlider!
    @IBOutlet weak var brightnessslider: UISlider!
    let imagePicker = UIImagePickerController()
    var picimageView = UIImageView()
    var textLabel = UILabel()
    var btnImageWithText = UIButton()
    var scrollView: UIScrollView!
    var diaryEntries = [DiaryEntry]()
    var dataModelArr = [dataModel]()
    var selectedDiaryEntryIndex : Int! = -1
    var mode : String = ""
    var stickerView = LDStickerView()
    var addremovecount : Int = 0
    var backgroundTextView : UITextView!
    var keyboardHeight : CGFloat! = 0
    @IBOutlet weak var filteredImageView: FilteredImageView!
    
    // MARK:- Text Format controls
    @IBOutlet weak var vwTextOptions : UIView!
    @IBOutlet weak var vwTextFormat : UIView!
    @IBOutlet weak var vwTextFont : UIView!
    @IBOutlet weak var sliderFontSize : UISlider!
    @IBOutlet weak var btnTextFont : UIButton!
    @IBOutlet weak var btnTextFormat : UIButton!
    @IBOutlet weak var fontCollectionView:UICollectionView!
   
    var fontArray = UIFont.familyNames
    let columnsInFirstPage = 5
    var selectedCollectionItemIndex : Int = -1
    var selectedFontName : String = UIFont.familyNames[0]
    var sliderFontSizeValue : Float = 0.0
    let collectionViewRows = 2
    
    var PreviewSelectedimage: UIImage?
    
    // MARK:- TextBox Option controls
    @IBOutlet weak var vwTextBoxOption : UIView!
    @IBOutlet weak var textBoxCollectionView:UICollectionView!
    @IBOutlet weak var vwEditTextBox : UIView!
    @IBOutlet weak var textViewEditTextBox : UITextView!
    var selectedTextBoxButton : UIButton!
    
    var textBoxImagesArray = ["text_01.png","text_02.png","text_03.png","text_04.png","text_05.png","text_06.png","text_07.png"]
    var materialImagesArray = ["bubble_graph_1.png","bubble_graph_2.png","bubble_graph_3.png","bubble_graph_4.png","bubble_graph_5.png.png","food_breakfast.png","food_cake.png","food_drinking.png","food_spice.png","food_tea.png","im31.png","im32.png","im33.png","im34.png","im35.png","im36.png","im37.png","im38.png","im39.png","im40.png","im44.png","im45.png","im46.png","im47.png","im48.png","im49.png","im50.png","line_1.png","line_2.png","line_3.png","line_4.png","line_5.png","iine_6.png","iine_dash.png","line_dot.png","line_head_bold.png","im50.png","im50.png","im50.png","im50.png","im50.png","im50.png"]
    // MARK:- QRCode related controls
    @IBOutlet weak var vwOverlay : UIView!
    @IBOutlet weak var vwQRCode : UIView!
    @IBOutlet weak var txtVwQRCode : UITextView!
    
    // MARK:- MAterial Related
    @IBOutlet weak var materialsBGview: UIView!
    @IBOutlet weak var materialcollectionView: UICollectionView!
    
    
    // MARK:- Image filter related
    @IBOutlet weak var materialBGview: UIView!
    var filters = [CIFilter]()
    fileprivate var colorControl = ColorControl()
    //////////
   
    /////////////////
    @IBOutlet weak var filterscollectionView: UICollectionView!
    @IBOutlet weak var filterscontrastsliderBGview: UIView!
    @IBOutlet weak var filtercollectionviewbg: UIView!
    
     // MARK:- Editor controls
    @IBOutlet weak var editorBGview: UIView!
    @IBOutlet weak var EditorBGTempView: UIView!
    @IBOutlet weak var brightnesssliderBGview: UIView!
    @IBOutlet weak var morebtnoutlet: UIButton!
    @IBOutlet weak var PredefineImagesBtn: UIButton!
    // calculate number of columns needed to display all items
    var columns: Int { return fontArray.count<=columnsInFirstPage ? fontArray.count : fontArray.count > collectionViewRows*columnsInFirstPage ? (fontArray.count-1)/collectionViewRows + 1 : columnsInFirstPage }
    
    
    @IBAction func materialSavebtn(_ sender: Any)
    {
        self.materialsBGview.isHidden = true

    }
    
    @IBAction func materialbackbtn(_ sender: Any)
    {
        self.materialsBGview.isHidden = true

    }
    
    @IBAction func cambtn(_ sender: Any)
    {
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
    
    @IBAction func filtersbtn(_ sender: Any)
    {
        filterscontrastsliderBGview.isHidden = false
        EditorBGTempView.isHidden = true
        brightnesssliderBGview.isHidden = true
        filtercollectionviewbg.isHidden = false
    }
    @IBAction func brightnesscontrastbtn(_ sender: Any)
    {
        filterscontrastsliderBGview.isHidden = false
        EditorBGTempView.isHidden = true
        brightnesssliderBGview.isHidden = false
        filtercollectionviewbg.isHidden = true
    }
    
    @IBAction func editorbtnn(_ sender: Any)
    {
        filterscontrastsliderBGview.isHidden = false
        EditorBGTempView.isHidden = false
        brightnesssliderBGview.isHidden = true
        filtercollectionviewbg.isHidden = true
    }
    @IBAction func savebtnn(_ sender: Any) {
    }
    @IBAction func cropimgbtn(_ sender: Any) {
    }
    @IBAction func Rotateimgbtn(_ sender: Any) {
    }
    
     // MARK:- Local storage coredata related
    func loadData(atIndex : Int)
    {
        self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
        
        if(diaryEntries.count > 0){
        let currentDiaryEntry = diaryEntries[selectedDiaryEntryIndex]
        let diaryData = currentDiaryEntry.diary_data as! [dataModel]
        addBackgroundTextView()
        backgroundTextView.attributedText = currentDiaryEntry.diary_text as! NSAttributedString
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
                coreDataDiary.diary_text = backgroundTextView.attributedText
              
                print(self.scrollView.contentSize.height)
                print(self.scrollView.frame.size.height)

                if(self.scrollView.contentSize.height > self.scrollView.frame.size.height + 130)
                {
                    coreDataDiary.diary_height = Float(self.scrollView.frame.size.height+200)
                    
                }else{
                    coreDataDiary.diary_height = Float(self.scrollView.frame.size.height)
                    
                }
                
            } else {
                // Fallback on earlier versions
                let entityDesc = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: CoreDataStack.managedObjectContext)
                let coreDataDiary = DiaryEntry(entity: entityDesc!, insertInto: CoreDataStack.managedObjectContext)
                coreDataDiary.diary_image = captureDiaryScreenAndSave()
                coreDataDiary.diary_text = backgroundTextView.attributedText
                coreDataDiary.modified_time = Date()
                coreDataDiary.diary_data = dataModelArr as NSObject
                if(self.scrollView.contentSize.height > self.scrollView.frame.size.height+130)
                {
                    coreDataDiary.diary_height = Float(self.scrollView.frame.size.height+200)

                }else{
                    coreDataDiary.diary_height = Float(self.scrollView.frame.size.height)

                }
            }
            CoreDataStack.saveContext()
        }
        UIGraphicsBeginImageContextWithOptions(scrollView.frame.size, false, scrollView.layer.contentsScale)
      
        let savedFrame = scrollView.frame
        
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 60, width: scrollView.frame.width, height: scrollView.contentSize.height)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.frame = savedFrame
        
        UIGraphicsEndImageContext()
        let ExportVC = storyboard?.instantiateViewController(withIdentifier: "ExportFiltersViewController") as! ExportFiltersViewController
        ExportVC.getnewImage = image
        self.navigationController?.pushViewController(ExportVC, animated: true)
        
    }
    func getImageOfScrollView() -> String?{
        UIGraphicsBeginImageContextWithOptions(scrollView.frame.size, false, scrollView.layer.contentsScale)

        let savedFrame = scrollView.frame
        
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 60, width: scrollView.frame.width, height: scrollView.contentSize.height)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        scrollView.frame = savedFrame
        UIGraphicsEndImageContext()
        ///////
        var imageName = Date().description
        imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
        imageName = imageName.replacingOccurrences(of: ":", with: "")
        let fullImagePath = diaryImagesDirectoryPath + "/\(imageName)"
        
        let data = UIImagePNGRepresentation((image)!)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            print("DiaryImage saved successfully in local")
        }
        return imageName
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
    // MARK:- QR Code related methods

    @IBAction func btnQRPopupClose_clicked(_ sender : UIButton){
        self.vwOverlay.isHidden = true
        self.vwQRCode.isHidden = true
    }
    
    @IBAction func btnQRCodeOK_clicked(_ sender : UIButton){
        let imageName = getImageNameFromDate()
        let fullImagePath = imagesDirectoryPath + "/\(imageName)"
        let myImage = generateQRCode(withString: self.txtVwQRCode.text)
        
        dragzoomroatateview(img:myImage, imgName: imageName, type: contentType.image.rawValue, attributedString: NSAttributedString(string:""))
        
        let data = UIImagePNGRepresentation(myImage)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            self.vwOverlay.isHidden = true
            self.vwQRCode.isHidden = true
        }
        
    }
    
    func generateQRCode(withString:String) -> UIImage {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        let data = withString.data(using: String.Encoding.utf8)
        filter?.setValue("H", forKey:"inputCorrectionLevel")
        filter?.setValue(data, forKey:"inputMessage")
        
        let outputImage = filter?.outputImage
        let context = CIContext(options:nil)
        let cgImage = context.createCGImage(outputImage!, from:outputImage!.extent)
        
        let image = UIImage(cgImage:cgImage!, scale:1.0, orientation:UIImageOrientation.up)
        let resized = resizeImage(image: image, withQuality:CGInterpolationQuality.none, rate:5.0)
        return resized
    }
    
    func resizeImage(image: UIImage, withQuality quality: CGInterpolationQuality, rate: CGFloat) -> UIImage {
        let width = image.size.width * rate
        let height = image.size.height * rate
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:width, height: height), true, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = quality
        //CGContex.InterpolationQuality(context!, quality)
        image.draw(in: CGRect(x:0, y:0, width:width, height:height))
        
        let resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resized!;
    }
    // MARK:- TextBox methods
    @IBAction func btnCompleteTextBox_action(_ sender : UIButton){
        
        selectedTextBoxButton.setAttributedTitle(textViewEditTextBox.attributedText, for: .normal)
        textViewEditTextBox.resignFirstResponder()
        self.vwEditTextBox.isHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        selectedTextBoxButton.setAttributedTitle(textViewEditTextBox.attributedText, for: .normal)
    }
        
     // MARK:- TextFormating methods
    @IBAction func textFormatActions(_ sender : UIButton){
        let btnLeftAlign = self.view.viewWithTag(textFormat.leftAlign.rawValue) as! UIButton
        let btnRightAlign = self.view.viewWithTag(textFormat.rightAlign.rawValue) as! UIButton
        let btnCenterAlign = self.view.viewWithTag(textFormat.centerAlign.rawValue) as! UIButton
        let btnBold = self.view.viewWithTag(textFormat.bold.rawValue) as! UIButton
        let btnItalic = self.view.viewWithTag(textFormat.italic.rawValue) as! UIButton
        //let btnUnderline = self.view.viewWithTag(textFormat.underline.rawValue) as! UIButton
        switch(sender.tag){
           
        case textFormat.bold.rawValue:
            sender.isSelected = !sender.isSelected
           
            backgroundTextView.font = UIFont(name: selectedFontName, size: CGFloat(16.0+sliderFontSizeValue))
            if(sender.isSelected == true && btnItalic.isSelected == true)
            {
                sender.setBackgroundImage(UIImage(named:"ico_bold_checked.png"), for: UIControlState.normal)
                backgroundTextView.font = backgroundTextView.font?.bold()
                backgroundTextView.font = backgroundTextView.font?.italic()
            }
            else if(sender.isSelected == true)
            {
                 sender.setBackgroundImage(UIImage(named:"ico_bold_checked.png"), for: UIControlState.normal)
                backgroundTextView.font = backgroundTextView.font?.bold()
            }
            else
            {
                sender.setBackgroundImage(UIImage(named:"ico_bold_unchecked.png"), for: UIControlState.normal)
                backgroundTextView.font = backgroundTextView.font?.noBold()
                if(btnItalic.isSelected == true){
                    backgroundTextView.font = backgroundTextView.font?.italic()
                }
            }

        break
        case textFormat.italic.rawValue:
            sender.isSelected = !sender.isSelected
            backgroundTextView.font = UIFont(name: selectedFontName, size: CGFloat(16.0+sliderFontSizeValue))
            if(btnBold.isSelected == true && sender.isSelected == true)
            {
                sender.setBackgroundImage(UIImage(named:"ico_italic_checked.png"), for: UIControlState.normal)
                backgroundTextView.font = backgroundTextView.font?.italic()
                backgroundTextView.font = backgroundTextView.font?.bold()
            }
            else if(sender.isSelected == true)
            {
                sender.setBackgroundImage(UIImage(named:"ico_italic_checked.png"), for: UIControlState.normal)
                backgroundTextView.font = backgroundTextView.font?.italic()
            }
            else
            {
                sender.setBackgroundImage(UIImage(named:"ico_italic_unchecked.png"), for: UIControlState.normal)
                backgroundTextView.font = backgroundTextView.font?.noItalic()
                if(btnBold.isSelected == true){
                    backgroundTextView.font = backgroundTextView.font?.bold()
                }
            }

        break
        
        case textFormat.underline.rawValue:
            sender.isSelected = !sender.isSelected
            let attString = NSMutableAttributedString(attributedString: backgroundTextView.attributedText)
            if (sender.isSelected) {
                //var attString = backgroundTextView.attributedText as! NSMutableAttributedString
                attString.addAttribute(NSAttributedStringKey.underlineStyle, value:NSUnderlineStyle.styleSingle.rawValue, range :NSRange(location: 0, length: attString.length))
                //backgroundTextView.attributedText = attString
                sender.setBackgroundImage(UIImage(named:"ico_underline_checked.png"), for: UIControlState.normal)
            }
            else{
                //let attString = NSMutableAttributedString(attributedString: backgroundTextView.attributedText)
                attString.removeAttribute(NSAttributedStringKey.underlineStyle, range: NSRange(location: 0, length: attString.length))
                //backgroundTextView.attributedText = attString
                sender.setBackgroundImage(UIImage(named:"ico_underline_unchecked.png"), for: UIControlState.normal)
                }
            backgroundTextView.attributedText = attString
        break
            
        case textFormat.leftAlign.rawValue:
            backgroundTextView.textAlignment = NSTextAlignment.left
            btnLeftAlign.setBackgroundImage(UIImage(named:"ico_left_checked.png"), for: UIControlState.normal)
            btnRightAlign.setBackgroundImage(UIImage(named:"ico_right_unchecked.png"), for: UIControlState.normal)
            btnCenterAlign.setBackgroundImage(UIImage(named:"ico_center_unchecked.png"), for: UIControlState.normal)
        break
            
        case textFormat.rightAlign.rawValue:
            backgroundTextView.textAlignment = NSTextAlignment.right
            btnLeftAlign.setBackgroundImage(UIImage(named:"ico_left_unchecked.png"), for: UIControlState.normal)
            btnRightAlign.setBackgroundImage(UIImage(named:"ico_right_checked.png"), for: UIControlState.normal)
            btnCenterAlign.setBackgroundImage(UIImage(named:"ico_center_unchecked.png"), for: UIControlState.normal)
        break
            
        case textFormat.centerAlign.rawValue:
            backgroundTextView.textAlignment = NSTextAlignment.center
            btnLeftAlign.setBackgroundImage(UIImage(named:"ico_left_unchecked.png"), for: UIControlState.normal)
            btnRightAlign.setBackgroundImage(UIImage(named:"ico_right_unchecked.png"), for: UIControlState.normal)
            btnCenterAlign.setBackgroundImage(UIImage(named:"ico_center_checked.png"), for: UIControlState.normal)
        break
            
        default:
            break
        }
    }
    @IBAction func btnTextFormat(_ sender : UIButton){
        vwTextFormat.isHidden = false
        vwTextFont.isHidden = true
        btnTextFormat.backgroundColor = UIColor.lightGray
        btnTextFont.backgroundColor = UIColor.white
    }
    
    @IBAction func btnTextFont(_ sender : UIButton){
        vwTextFormat.isHidden = true
        vwTextFont.isHidden = false
        btnTextFormat.backgroundColor = UIColor.white
        btnTextFont.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func btnCompleteFormat(_ sender : UIButton)
    {
        vwTextOptions.isHidden = true
    }
    
    @IBAction func btnCompleteTextBoxOption(_ sender : UIButton)
    {
        vwTextBoxOption.isHidden = true
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    {
        self.scrollView.isScrollEnabled = true
        hideOtherViewSelection()
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        sliderFontSizeValue = sender.value
        let btnBold = self.view.viewWithTag(textFormat.bold.rawValue) as! UIButton
        //let btnUnderline = self.view.viewWithTag(textFormat.underline.rawValue) as! UIButton
        let btnItalic = self.view.viewWithTag(textFormat.italic.rawValue) as! UIButton
       
        if(btnBold.isSelected){
            backgroundTextView.font = backgroundTextView.font?.bold()
        }
        else{
            backgroundTextView.font = backgroundTextView.font?.noBold()
        }
        if(btnItalic.isSelected){
            backgroundTextView.font = backgroundTextView.font?.italic()
        }
        else{
            backgroundTextView.font = backgroundTextView.font?.noItalic()
        }
         backgroundTextView.font = UIFont(name:selectedFontName, size : CGFloat(16.0+sliderFontSizeValue))
    }
    
   
    // MARK:- Font CollectionView delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == fontCollectionView){
        return columns*collectionViewRows
        }
        else if(collectionView == textBoxCollectionView){
            return textBoxImagesArray.count
        }else if(collectionView == materialcollectionView){
            return materialImagesArray.count
        }
        else{
            return 0
        }
        //return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == fontCollectionView){
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        //cell.backgroundColor = UIColor.green
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.gray.cgColor
        let labelFont = UILabel()
        labelFont.text = "Aa"
        
        labelFont.textAlignment = .center
        labelFont.tag = indexPath.row
        labelFont.frame.size = CGSize(width:50, height:50)
        labelFont.center = CGPoint(x:cell.contentView.center.x+5,y:cell.contentView.center.y+5)
        
        cell.backgroundColor = UIColor.white
        labelFont.textColor = UIColor.black
        
        if(cell.contentView.subviews.count==0){
            labelFont.font = UIFont(name: fontArray[indexPath.row], size: 25.0)
            cell.contentView.addSubview(labelFont)
        }
        else{
            let labelFontCheck = cell.contentView.subviews[0] as! UILabel
            if(selectedCollectionItemIndex == indexPath.row){
                cell.backgroundColor = UIColor.gray
                labelFontCheck.textColor = UIColor.white
                labelFontCheck.font = UIFont(name: fontArray[indexPath.row], size: 20.0)
            }
            else{
                labelFontCheck.font = UIFont(name: fontArray[indexPath.row], size: 20.0)
                cell.backgroundColor = UIColor.white
                labelFontCheck.textColor = UIColor.black
            }
        }
          return cell
        }
        else if(collectionView == textBoxCollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellTextBox", for: indexPath)
            let imgTextBoxItem = UIImageView()
            imgTextBoxItem.image = UIImage(named: textBoxImagesArray[indexPath.row])
            
            if(cell.contentView.subviews.count==0){
                imgTextBoxItem.frame = CGRect(x:0, y:0, width:80, height:80)
                cell.addSubview(imgTextBoxItem)
            }
            return cell
        }
        else if(collectionView == materialcollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMaterial", for: indexPath)
            let imgMaterialItem = UIImageView()
            imgMaterialItem.image = UIImage(named: materialImagesArray[indexPath.row])
            
            if(cell.contentView.subviews.count==0){
                imgMaterialItem.frame = CGRect(x:0, y:0, width:80, height:80)
                cell.addSubview(imgMaterialItem)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(collectionView == fontCollectionView){
        let btnBold = self.view.viewWithTag(textFormat.bold.rawValue) as! UIButton
        let btnItalic = self.view.viewWithTag(textFormat.italic.rawValue) as! UIButton
        selectedCollectionItemIndex = indexPath.row
        selectedFontName = fontArray[indexPath.row]
        backgroundTextView.font = UIFont(name: selectedFontName, size: CGFloat(16.0+sliderFontSize.value))
        if(btnBold.isSelected)
        {
            backgroundTextView.font = backgroundTextView.font?.bold()
        }
        else if(btnItalic.isSelected)
        {
            backgroundTextView.font = backgroundTextView.font?.italic()
        }
        if(btnBold.isSelected == true && btnItalic.isSelected == true)
        {
            backgroundTextView.font = backgroundTextView.font?.bold().italic()
        }
            
        collectionView.reloadData()
        }
        if(collectionView == materialcollectionView)
        {
            let imageName = getImageNameFromDate()
            let fullImagePath = imagesDirectoryPath + "/\(imageName)"
            let getimageName : UIImage = UIImage(named:materialImagesArray[indexPath.row])!
            let myImage = self.fixOrientation(image: getimageName)
            
            dragzoomroatateview(img:myImage, imgName: imageName, type: contentType.image.rawValue, attributedString: NSAttributedString(string:""))
            let data = UIImagePNGRepresentation(myImage)
            let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
            if(success){
                print("image saved successfully in local")
            }
        }
        
        if(collectionView == textBoxCollectionView)
        {
            let imageName = getImageNameFromDate()
            let fullImagePath = imagesDirectoryPath + "/\(imageName)"
            let getimageName : UIImage = UIImage(named:textBoxImagesArray[indexPath.row])!
            let myImage = self.fixOrientation(image: getimageName)
            
            dragzoomroatateview(img:myImage, imgName: imageName, type: contentType.imageAndText.rawValue, attributedString: NSAttributedString(string:"Double Tab to edit"))
            let data = UIImagePNGRepresentation(myImage)
            let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
            if(success){
                print("image saved successfully in local")
            }
        }
    }
    
    // MARK:- ViewController delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        addremovecount = 1;

        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width:self.view.frame.width-30, height: self.view.frame.size.height)
        self.scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        addBackgroundTextView()
        //self.backgroundTextView.becomeFirstResponder()
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(scrolltouchhandlePan))
        self.view.addGestureRecognizer(gestureRecognizer)
        //tabBarview.delegate = self
        imagePicker.delegate = self
        createImagesFolder()
        createDiaryImagesFolder()
        self.view.bringSubview(toFront: editorBGview)
        materialBGview.frame = CGRect(x: 0, y: 1000, width: self.materialBGview.frame.width, height: self.materialBGview.frame.height)
     //self.view.bringSubview(toFront: self.tabBarview)
        
        self.view.bringSubview(toFront: self.materialsBGview)
        self.view.bringSubview(toFront: self.vwTextOptions)
        self.materialsBGview.isHidden = true
        ////////////////////////Image view
        
        textViewEditTextBox.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        addDoneButtonOnKeyboard()
        ///////////////////////
    }
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(DiaryViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.backgroundTextView.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction() {
        self.backgroundTextView.resignFirstResponder()
        self.textViewEditTextBox.resignFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        print(getkeyboardHeight)
        print(self.view.frame.size.height-getkeyboardHeight-60)
        if(self.vwOverlay.isHidden == false){
            self.vwOverlay.isHidden = true
        }
    
    }
   
    @objc func keyboardWillAppear() {
        //Do something here
        didDisplayedKeyboard = true
       
    }
    
    @objc func keyboardWillDisappear() {
        //Do something here
        didDisplayedKeyboard = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        if(vwTextBoxOption.isHidden == false){
            vwTextBoxOption.isHidden = true
        }
    }
    var getkeyboardHeight : CGFloat = CGFloat()
    var didDisplayedKeyboard:Bool = false
    var checkmorebtn : Bool = true

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            getkeyboardHeight = keyboardSize.height
           
            if(self.vwTextBoxOption.isHidden == false && self.textViewEditTextBox.isFirstResponder == true){
                //vwEditTextBox.isHidden = false
                
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    keyboardHeight = keyboardSize.height
                    self.vwEditTextBox.frame = CGRect(x:self.vwEditTextBox.frame.origin.x,y: self.view.frame.size.height - keyboardSize.height - vwEditTextBox.frame.size.height+5, width : self.view.frame.size.width, height : self.vwEditTextBox.frame.size.height)
                    //self.textViewEditTextBox.backgroundColor = .lightGray
                    self.vwEditTextBox.isHidden = false
                }
                
            }
           
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
         materialBGview.frame = CGRect(x: 0, y: 1000, width: self.materialBGview.frame.width, height: self.materialBGview.frame.height)
        getSavedData()
        if(mode == "edit"){
            if(selectedDiaryEntryIndex != -1){
                
                loadData(atIndex : selectedDiaryEntryIndex)
            }
            mode = ""
        }
        if(PreviewSelectedimage !== nil){
            var imageName = Date().description
            imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
            imageName = imageName.replacingOccurrences(of: ":", with: "")
            let fullImagePath = imagesDirectoryPath + "/\(imageName)"
            let myImage = self.fixOrientation(image: PreviewSelectedimage!)
            
            dragzoomroatateview(img:myImage, imgName: imageName, type: contentType.image.rawValue, attributedString: NSAttributedString(string:""))
            let data = UIImagePNGRepresentation(myImage)
            let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
            if(success){
                print("image saved successfully in local")
            }
            PreviewSelectedimage = nil
        }
        // Collection view UI changes
        let fontCollectionlayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        fontCollectionlayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        fontCollectionlayout.itemSize = CGSize(width: 50, height: 50)
        fontCollectionlayout.scrollDirection = .horizontal
        fontCollectionView.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:120)
        fontCollectionView.collectionViewLayout = fontCollectionlayout
        fontCollectionView.dataSource = self
        fontCollectionView.delegate = self
        fontCollectionView.backgroundColor = UIColor.white
        
        let textBoxCollectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        textBoxCollectionLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textBoxCollectionLayout.itemSize = CGSize(width: 80, height: 80)
        textBoxCollectionLayout.scrollDirection = .horizontal
        textBoxCollectionView.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:160)
        textBoxCollectionView.collectionViewLayout = textBoxCollectionLayout
        textBoxCollectionView.dataSource = self
        textBoxCollectionView.delegate = self
        textBoxCollectionView.backgroundColor = UIColor.white
        /////////Material collection view
        let materialCollectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        materialCollectionLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        materialCollectionLayout.itemSize = CGSize(width: 80, height: 80)
        materialCollectionLayout.scrollDirection = .horizontal
        materialcollectionView.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:160)
        materialcollectionView.collectionViewLayout = materialCollectionLayout
        materialcollectionView.dataSource = self
        materialcollectionView.delegate = self
        materialcollectionView.backgroundColor = UIColor.white
        //self.vwOverlay.isHidden = true

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
      //  scrollView.frame = CGRect(x: 10, y: 70, width: self.view.frame.size.width-20, height: self.view.frame.size.height-180)
          scrollView.frame = CGRect(x: 10, y: 70, width: self.view.frame.size.width-20, height: self.view.frame.size.height)
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addBackgroundTextView(){
        self.backgroundTextView = UITextView()
        self.backgroundTextView.allowsEditingTextAttributes = true
        self.backgroundTextView.backgroundColor = UIColor.clear
        self.backgroundTextView.font = .systemFont(ofSize: 18)
        self.backgroundTextView.frame = CGRect(x:0,y:0,width:self.view.frame.width-30, height:self.scrollView.contentSize.height)
    
        self.scrollView.addSubview(backgroundTextView)
    }
    // MARK:- ScrollView methods
    @objc func scrolltouchhandlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began
        {
            self.scrollView.isScrollEnabled = true
            hideOtherViewSelection()
             self.backgroundTextView.resignFirstResponder()
            //stickerView.hideEditingHandles()
        }
    }

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

        
        stickerView = LDStickerView(frame: CGRect(x: 40, y: self.scrollView.contentSize.height - 400, width: calcWidth, height: calcHeight))
        stickerView.accessibilityIdentifier = "drag"

        if(type == contentType.image.rawValue){
            picimageView = UIImageView()
            picimageView.image = img
            picimageView.frame = CGRect(x: 20 , y: 20, width: calcWidth-40, height: calcHeight-40)
            picimageView.accessibilityIdentifier = imgName
            picimageView.contentMode = UIViewContentMode.scaleToFill
            stickerView.setContentView(picimageView)
        }
        else if(type == contentType.imageAndText.rawValue){
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(textBoxDoubleTapped))
            doubleTap.numberOfTapsRequired = 2
            
            btnImageWithText = UIButton(type : .custom)
            btnImageWithText.setBackgroundImage(img, for: .normal)
            btnImageWithText.frame = CGRect(x: 20 , y: 20, width: calcWidth-40, height: calcHeight-40)
            btnImageWithText.titleLabel?.textColor = .black
            btnImageWithText.titleLabel?.numberOfLines = 0
            btnImageWithText.setAttributedTitle(attributedString, for: .normal)
            btnImageWithText.adjustsImageWhenHighlighted = false
            btnImageWithText.accessibilityIdentifier = imgName
            btnImageWithText.titleEdgeInsets = UIEdgeInsets(top:-15, left: 0, bottom: 0, right: 0)
            btnImageWithText.isUserInteractionEnabled = false
            stickerView.addGestureRecognizer(doubleTap)
            
            stickerView.setContentView(btnImageWithText)
            
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
    
    @objc func textBoxDoubleTapped(_ gesture : UIGestureRecognizer){
        self.view.bringSubview(toFront: self.vwEditTextBox)
        
        selectedTextBoxButton = gesture.view?.subviews[0] as! UIButton
        self.textViewEditTextBox.layer.borderWidth = 1.0
        self.textViewEditTextBox.layer.borderColor = UIColor.gray.cgColor
        self.textViewEditTextBox.text = selectedTextBoxButton.titleLabel?.text
        self.textViewEditTextBox.becomeFirstResponder()
 
        //addDoneButtonOnKeyboard()
    }

    // MARK:- Tab bar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if(item.tag == 0){
            self.vwTextOptions.isHidden = false
            self.vwTextFormat.isHidden = false
            self.vwTextFont.isHidden = true
            self.btnTextFormat.backgroundColor = UIColor.lightGray
            self.btnTextFont.backgroundColor = UIColor.white
        }
        if(item.tag == 1){
          
        }
        if(item.tag == 2){
            
        }
        if(item.tag == 3){
            //print("Test3")
            if(addremovecount <= 3)
            {
                addremovecount += 1
                let addremovecountcgfloat = CGFloat(addremovecount)
                
                self.scrollView.contentSize = CGSize(width:1.0, height: self.view.frame.height*addremovecountcgfloat)
            }else{
                
                // create the alert
                let alert = UIAlertController(title: "Alert!", message: "Maximum 3 page allowed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

            }
            
        }
        if(item.tag == 4){
            //print("Test4")
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
   
    @IBAction func Textbtn(_ sender: Any)
    {
        self.vwTextOptions.isHidden = false
        self.vwTextFormat.isHidden = false
        self.vwTextFont.isHidden = true
        self.btnTextFormat.backgroundColor = UIColor.lightGray
        self.btnTextFont.backgroundColor = UIColor.white
    }
    
    @IBAction func Camerabtn(_ sender: Any)
    {
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
    @IBAction func PreDefineimgbtn(_ sender: Any)
    {
        self.view.bringSubview(toFront: self.materialsBGview)
        self.materialsBGview.isHidden = false
    }
    @IBAction func morebtn(_ sender: UIButton)
    {
        print("morebtn")
        morebtnoutlet.isSelected = !sender.isSelected
        morebtnoutlet.backgroundColor = UIColor.clear
        if(checkmorebtn == true)
        {
            editorBGview.frame = CGRect(x: 0, y: self.view.frame.size.height-self.editorBGview.frame.size.height, width: self.editorBGview.frame.width, height: self.editorBGview.frame.height)
            checkmorebtn = false
        }else{
            checkmorebtn = true
            editorBGview.frame = CGRect(x: 0, y: self.view.frame.size.height-60, width: self.editorBGview.frame.width, height: self.editorBGview.frame.height)
        }
    }
    @IBAction func PredefineTextimgbtn(_ sender: Any)
    {
        self.view.bringSubview(toFront: vwTextBoxOption)
        vwTextBoxOption.isHidden = false
    }
    @IBAction func Grafittbtn(_ sender: Any)
    {
        camselectedimage = nil
        performSegue(withIdentifier: "ExportFiltersViewController", sender: self)


    }
    @IBAction func Barcodebtn(_ sender: Any)
    {
        self.view.bringSubview(toFront: self.vwOverlay)
        self.view.bringSubview(toFront: self.vwQRCode)
        self.vwOverlay.isHidden = false
        self.vwQRCode.isHidden = false

    }
    @IBAction func MicBtn(_ sender: Any)
    {

    }
    @IBAction func Colorbtn(_ sender: Any)
    {
    }
    @IBAction func Draftbtn(_ sender: Any)
    {

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
    var camselectedimage: UIImage?
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        var imageName = Date().description
        imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
        imageName = imageName.replacingOccurrences(of: ":", with: "")
        let fullImagePath = imagesDirectoryPath + "/\(imageName)"
        let myImage = self.fixOrientation(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!)
 
        self.dismiss(animated: true, completion: nil)
        for descriptor in filterDescriptors {
            filters.append(CIFilter(name: descriptor.filterName)!)
        }
       
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        
        self.vwOverlay.addSubview(activityView)
        self.view.bringSubview(toFront: self.vwOverlay)

        self.vwOverlay.isHidden = false
            camselectedimage = myImage
        performSegue(withIdentifier: "ExportFiltersViewController", sender: self)

      
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExportFiltersViewController" {
            if let nextViewController = segue.destination as? ExportFiltersViewController
            {
                if(camselectedimage !== nil){
                nextViewController.getnewImage = camselectedimage
                }

                
            }
        }
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
       UIGraphicsBeginImageContextWithOptions(scrollView.frame.size, false, scrollView.layer.contentsScale)

        let savedFrame = scrollView.frame
        
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 60, width: scrollView.frame.width, height: scrollView.contentSize.height)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.frame = savedFrame
        
        UIGraphicsEndImageContext()

        var imageName = Date().description
        imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
        imageName = imageName.replacingOccurrences(of: ":", with: "")
        let fullImagePath = diaryImagesDirectoryPath + "/\(imageName)"
        
        let data = UIImagePNGRepresentation((image)!)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            print("DiaryImage saved successfully in local")
        }
        return imageName
    }
}
// Get ImageName from date
func getImageNameFromDate()-> String
{
    var imageName = Date().description
    imageName = imageName.replacingOccurrences(of: " ", with: "") + ".png"
    imageName = imageName.replacingOccurrences(of: ":", with: "")
    return imageName
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

extension UIFont {
    
    func withTraits(_ traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits).union(self.fontDescriptor.symbolicTraits))
        if(descriptor != nil){
            return UIFont(descriptor: descriptor!, size: 0)
        }
        else{
            if(traits == [UIFontDescriptorSymbolicTraits.traitItalic]){
                return UIFont.italicSystemFont(ofSize: self.pointSize)
            }
            else if(traits == [UIFontDescriptorSymbolicTraits.traitBold]){
                return UIFont.boldSystemFont(ofSize: self.pointSize)
            }
            else
            {
                return UIFont.systemFont(ofSize: self.pointSize)
            }
        }
    }
    func withoutTraits(_ traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(  self.fontDescriptor.symbolicTraits.subtracting(UIFontDescriptorSymbolicTraits(traits)))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    func bold() -> UIFont {
        return withTraits( .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(.traitItalic)
    }
    
    func noItalic() -> UIFont {
        return withoutTraits(.traitItalic)
    }
    func noBold() -> UIFont {
        return withoutTraits(.traitBold)
    }
    
}
