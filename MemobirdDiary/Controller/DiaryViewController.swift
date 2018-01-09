
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
    var btnPlainTextBox = UIButton()
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

    var selectedFontCollectionIndexPath : IndexPath = IndexPath(item: 2, section: 0)
    var selectedFontName : String = UIFont.familyNames[2]
    var sliderFontSizeValue : Float = 0.0
    //let collectionViewRows = 2
    
    var PreviewSelectedimage: UIImage?
    
    // MARK:- TextBox Option controls
    @IBOutlet weak var vwTextBoxOption : UIView!
    @IBOutlet weak var textBoxCollectionView:UICollectionView!
    @IBOutlet weak var vwEditTextBox : UIView!
    @IBOutlet weak var textViewEditTextBox : UITextView!
    var selectedTextBoxButton = UIButton(type:.custom)
    
    var textBoxImagesArray = ["[ Text ]","text_01.png","text_02.png","text_03.png","text_04.png","text_05.png","text_06.png","text_07.png"]
    var materialImagesArray = ["bubble_graph_1.png","bubble_graph_2.png","bubble_graph_3.png","bubble_graph_4.png","bubble_graph_5.png.png","food_breakfast.png","food_cake.png","food_drinking.png","food_spice.png","food_tea.png","im31.png","im32.png","im33.png","im34.png","im35.png","im36.png","im37.png","im38.png","im39.png","im40.png","im44.png","im45.png","im46.png","im47.png","im48.png","im49.png","im50.png","line_1.png","line_2.png","line_3.png","line_4.png","line_5.png","line_6.png","line_dash.png","line_dot.png","line_head_bold.png","other_birthday.png","other_love.png","other_travel.png","postmark_1.png","postmark_2.png","postmark_3.png", "postmark_4.png", "quest_bottle.png","quest_dream.png","quest_plane.png","quest_robot.png","quest_rocket.png","quest_sailing.png","quest_telescope.png","run_1.png","run_2.png"]
    // MARK:- QRCode related controls
    @IBOutlet weak var vwOverlay : UIView!
    @IBOutlet weak var vwQRCode : UIView!
    @IBOutlet weak var txtVwQRCode : UITextView!
    
    // MARK:- Material Related controls
    @IBOutlet weak var materialsBGview: UIView!
    @IBOutlet weak var materialcollectionView: UICollectionView!
    
    
    // MARK:- Image filter related controls
    @IBOutlet weak var materialBGview: UIView!
    var filters = [CIFilter]()
    fileprivate var colorControl = ColorControl()
    //////////
   
    /////////////////
    @IBOutlet weak var filterscollectionView: UICollectionView!
    @IBOutlet weak var filterscontrastsliderBGview: UIView!
    @IBOutlet weak var filtercollectionviewbg: UIView!
    
     // MARK:- Editor controls and methods
    @IBOutlet weak var editorBGview: UIView!
    @IBOutlet weak var EditorBGTempView: UIView!
    @IBOutlet weak var brightnesssliderBGview: UIView!
    @IBOutlet weak var morebtnoutlet: UIButton!
    @IBOutlet weak var PredefineImagesBtn: UIButton!
    // calculate number of columns needed to display all items
   
    
    
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
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(textBoxDoubleTapped))
                doubleTap.numberOfTapsRequired = 2
            
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
                else if(dataModelObj.type == contentType.imageAndText.rawValue){
                    let fullImagePath = imagesDirectoryPath + "/\(dataModelObj.imageName)"
                    do{
                    let fileURLPath = URL(fileURLWithPath : fullImagePath)
                    let imageData = try Data(contentsOf: fileURLPath)
                    let myImg = UIImage(data: imageData)
                    
                    btnImageWithText = UIButton(type : .custom)
                    btnImageWithText.setBackgroundImage(myImg, for: .normal)
                    btnImageWithText.frame = CGRect(x: 20 , y: 20, width: stickerView.frame.size.width-40, height: stickerView.frame.size.height-40)
                    btnImageWithText.titleLabel?.textColor = .black
                    btnImageWithText.titleLabel?.numberOfLines = 0
                    btnImageWithText.setAttributedTitle(dataModelObj.attributedString, for: .normal)
                    btnImageWithText.adjustsImageWhenHighlighted = false
                    btnImageWithText.accessibilityIdentifier = dataModelObj.imageName
                    btnImageWithText.titleEdgeInsets = UIEdgeInsets(top:-15, left: 0, bottom: 0, right: 0)
                    btnImageWithText.isUserInteractionEnabled = false
                    //btnImageWithText.accessibilityIdentifier = "dragImageTextBox"
                    stickerView.addGestureRecognizer(doubleTap)
                    
                    stickerView.setContentView(btnImageWithText)
                    }catch {
                        print("Error loading image : \(error)")
                    }
                    
                }
                else{

                    btnPlainTextBox = UIButton(type:.custom)
                    btnPlainTextBox.frame = CGRect(x: 20 , y: 20, width: stickerView.frame.size.width-40, height: stickerView.frame.size.height-40)
                    btnPlainTextBox.titleLabel?.textColor = .black
                    btnPlainTextBox.titleLabel?.numberOfLines = 0
                    btnPlainTextBox.setAttributedTitle(dataModelObj.attributedString, for: .normal)
                    btnPlainTextBox.isUserInteractionEnabled = false
                    btnPlainTextBox.accessibilityIdentifier = "dragPlainTextBox"
                    stickerView.addGestureRecognizer(doubleTap)
                    stickerView.setContentView(btnPlainTextBox)
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
                if(diaryEntries[selectedDiaryEntryIndex].diary_image != nil){
                    deleteFileWithImageName(imageName: diaryEntries[selectedDiaryEntryIndex].diary_image!, isDiary: true)
                }
                
                //CoreDataStack.managedObjectContext.delete(diaryEntries[selectedDiaryEntryIndex])
            }
            dataModelArr.removeAll()
            for dragView in fromView.subviews
            {
                if(dragView.accessibilityIdentifier == "drag"){
              
                     let radians:Double = Double(atan2f(Float(Double(dragView.transform.b)), Float(Double(dragView.transform.a))))
                    
                    let dataModelObj : dataModel
                    if (dragView.subviews[0] as? UIButton == nil)
                    {
                        
                        let imageView = dragView.subviews[0] as? UIImageView
                        dataModelObj = dataModel(imageName : (imageView?.accessibilityIdentifier)!, xPos :dragView.center.x, yPos :dragView.center.y, width : dragView.bounds.size.width, height : dragView.bounds.size.height,radians : CGFloat(radians), angle : CGFloat(0), type:contentType.image.rawValue, attributedString:(NSAttributedString(string:"")))
                        
                    }
                    else
                    {
                        let buttonTextBox = dragView.subviews[0] as? UIButton
                        if(dragView.subviews[0].accessibilityIdentifier == "dragPlainTextBox") {
                            dataModelObj = dataModel(imageName : (buttonTextBox?.accessibilityIdentifier)!, xPos :dragView.center.x, yPos :dragView.center.y, width : dragView.bounds.size.width, height : dragView.bounds.size.height,radians : CGFloat(radians), angle : CGFloat(0), type: contentType.text.rawValue, attributedString : (buttonTextBox?.titleLabel?.attributedText)!)
                        }
                        else{
                            dataModelObj = dataModel(imageName : (buttonTextBox?.accessibilityIdentifier)!, xPos :dragView.center.x, yPos :dragView.center.y, width : dragView.bounds.size.width, height : dragView.bounds.size.height,radians : CGFloat(radians), angle : CGFloat(0), type: contentType.imageAndText.rawValue, attributedString : (buttonTextBox?.titleLabel?.attributedText)!)
                        }

                    }
                    
                    dataModelArr.append(dataModelObj)
                }
                
            }
            let maxHeight = self.getMaximumUsedHeightOfDiaryView() + 10
            if(diaryEntries.count > 0 && selectedDiaryEntryIndex != -1){
                let selectedDiaryEntry = diaryEntries[selectedDiaryEntryIndex]
                selectedDiaryEntry.modified_time = Date()
                
                selectedDiaryEntry.diary_image = captureDiaryScreenAndSave(maxHeight : maxHeight)
                
                selectedDiaryEntry.diary_data = dataModelArr as NSObject
                selectedDiaryEntry.diary_text = backgroundTextView.attributedText
                selectedDiaryEntry.diary_height = maxHeight
//                if(self.scrollView.contentSize.height > self.scrollView.frame.size.height + 130)
//                {
//                    selectedDiaryEntry.diary_height = Float(self.scrollView.frame.size.height+200)
//
//                }else{
//                    selectedDiaryEntry.diary_height = Float(self.scrollView.frame.size.height)
//                }
                diaryEntries[selectedDiaryEntryIndex] = selectedDiaryEntry
            }else{
            if #available(iOS 10.0, *) {
                let coreDataDiary = DiaryEntry(context: CoreDataStack.managedObjectContext)
                coreDataDiary.modified_time = Date()
                coreDataDiary.diary_image = captureDiaryScreenAndSave(maxHeight : maxHeight)
                
                coreDataDiary.diary_data = dataModelArr as NSObject
                coreDataDiary.diary_text = backgroundTextView.attributedText
              
                coreDataDiary.diary_height = maxHeight

//                if(self.scrollView.contentSize.height > self.scrollView.frame.size.height + 130)
//                {
//                    coreDataDiary.diary_height = Float(self.scrollView.frame.size.height+200)
//
//                }else{
//                    coreDataDiary.diary_height = Float(self.scrollView.frame.size.height)
//
//                }
                
            } else {
                // Fallback on earlier versions
                let entityDesc = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: CoreDataStack.managedObjectContext)
                let coreDataDiary = DiaryEntry(entity: entityDesc!, insertInto: CoreDataStack.managedObjectContext)
                coreDataDiary.diary_image = captureDiaryScreenAndSave(maxHeight: maxHeight)
                coreDataDiary.diary_text = backgroundTextView.attributedText
                coreDataDiary.modified_time = Date()
                coreDataDiary.diary_data = dataModelArr as NSObject
                coreDataDiary.diary_height = maxHeight
//                if(self.scrollView.contentSize.height > self.scrollView.frame.size.height+130)
//                {
//                    coreDataDiary.diary_height = Float(self.scrollView.frame.size.height+200)
//
//                }else{
//                    coreDataDiary.diary_height = Float(self.scrollView.frame.size.height)
//
//                }
                
            }
            }
            CoreDataStack.saveContext()
        }
        // the alert view
        self.showAlert(alertMessage: "Saved successfully!")
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
        self.txtVwQRCode.text = ""
    }
    
    @IBAction func btnQRCodeOK_clicked(_ sender : UIButton){
        let imageName = getImageNameFromDate()
        let fullImagePath = imagesDirectoryPath + "/\(imageName)"
        let myImage = generateQRCode(withString: self.txtVwQRCode.text)
        
        dragzoomroatateview(img:myImage, imgName: imageName, type: contentType.image.rawValue, attributedString: NSAttributedString(string:""))
        
        let data = UIImagePNGRepresentation(myImage)
        let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
        if(success){
            self.txtVwQRCode.text = ""
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
        image.draw(in: CGRect(x:0, y:0, width:width, height:height))
        let resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resized!;
    }
    // MARK:- TextBox methods
    @IBAction func btnCompleteTextBox_action(_ sender : UIButton){
        let myAttribute = [ NSAttributedStringKey.font: selectedFont ]
        let myString = NSMutableAttributedString(string:textViewEditTextBox.text, attributes: myAttribute )
        selectedTextBoxButton.setAttributedTitle(myString, for: .normal)
      self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height - 60 )
        textViewEditTextBox.resignFirstResponder()
        self.vwEditTextBox.isHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView == textViewEditTextBox){
          //selectedTextBoxButton.setAttributedTitle(textViewEditTextBox.attributedText, for: .normal)
            selectedFont = selectedTextBoxButton.titleLabel?.font
            let myAttribute = [ NSAttributedStringKey.font: selectedFont ]
            let myString = NSMutableAttributedString(string:textViewEditTextBox.text, attributes: myAttribute )
            selectedTextBoxButton.setAttributedTitle(myString, for: .normal)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if(textView == backgroundTextView){
            self.vwEditTextBox.isHidden = true
        }
        
        return true 
    }
    
    var selectedFont : UIFont!
    @objc func textBoxDoubleTapped(_ gesture : UIGestureRecognizer){
        self.view.bringSubview(toFront: self.vwEditTextBox)
        
        selectedTextBoxButton = gesture.view?.subviews[0] as! UIButton
        self.textViewEditTextBox.layer.borderWidth = 1.0
        self.textViewEditTextBox.layer.borderColor = UIColor.gray.cgColor
        //self.textViewEditTextBox.font = selectedTextBoxButton.titleLabel?.font
        selectedFont = selectedTextBoxButton.titleLabel?.font
        if(selectedTextBoxButton.titleLabel?.text == "Double Tap to edit"){
            self.textViewEditTextBox.text = ""
            selectedTextBoxButton.titleLabel?.text = ""
            selectedTextBoxButton.setAttributedTitle(NSAttributedString(string:""), for: .normal)
        }
        self.textViewEditTextBox.text = selectedTextBoxButton.titleLabel?.text
        self.textViewEditTextBox.autocorrectionType = .no
        self.textViewEditTextBox.becomeFirstResponder()
        if(didDisplayedKeyboard == true){
            
            //getkeyboardHeight -= 90
            showEditTextBox()
            
        }
        
        
    }

    func showEditTextBox(){
        self.view.bringSubview(toFront: self.vwEditTextBox)
        self.vwEditTextBox.frame = CGRect(x:self.vwEditTextBox.frame.origin.x,y: self.view.frame.size.height - getkeyboardHeight - vwEditTextBox.frame.size.height+5, width : self.view.frame.size.width, height : self.vwEditTextBox.frame.size.height)
        //self.textViewEditTextBox.frame = CGRect(x:5.0,y:5.0,width:self.view.frame.size.width/0.75,height:self.vwEditTextBox.frame.size.height-5)
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 100 )
        print("vwEditTextBox frame : \(self.vwEditTextBox.frame)")
        self.vwEditTextBox.isHidden = false
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
        self.dismissKeyboard()
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
    
   
    // MARK:- CollectionView delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == fontCollectionView){
            return fontArray.count
        }
        if(collectionView == textBoxCollectionView){
            return textBoxImagesArray.count
        }
        if(collectionView == materialcollectionView){
            return materialImagesArray.count
        }
        return 0
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == fontCollectionView){
         
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCell", for: indexPath) as! FontCollectionViewCell

        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.gray.cgColor
        
        cell.fontLabel.text = "Aa"
        
        cell.fontLabel.textAlignment = .center
        cell.fontLabel.tag = indexPath.row
        
        cell.backgroundColor = UIColor.white
        cell.fontLabel.textColor = UIColor.black
        
        cell.fontLabel.font = UIFont(name: fontArray[indexPath.row], size: 25.0)
       
        if selectedFontCollectionIndexPath != nil && indexPath == selectedFontCollectionIndexPath {
            cell.backgroundColor = UIColor.gray
        }else{
            cell.backgroundColor = UIColor.white
        }
        
          return cell
        }
        if(collectionView == textBoxCollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellTextBox", for: indexPath)
            // Checking for plain textbox
            if(indexPath.row == 0){
                if(cell.contentView.subviews.count==0){
                    let plainText = UILabel()
                    plainText.text = textBoxImagesArray[indexPath.row]
                    plainText.frame = CGRect(x:0, y:0, width:80, height:80)
                    cell.contentView.addSubview(plainText)
                }
            }else{ // If it is not plain textbox adding image to the cell
                
                if(cell.contentView.subviews.count==0){
                    let imgTextBoxItem = UIImageView()
                    imgTextBoxItem.image = UIImage(named: textBoxImagesArray[indexPath.row])
                    imgTextBoxItem.contentMode = .scaleAspectFit
                    imgTextBoxItem.frame = CGRect(x:0, y:0, width:80, height:80)
                    cell.contentView.addSubview(imgTextBoxItem)
                }
            }
            return cell
        }
        if(collectionView == materialcollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMaterial", for: indexPath)
            
                cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                let imgMaterialItem = UIImageView()
                imgMaterialItem.image = UIImage(named: materialImagesArray[indexPath.row])
                imgMaterialItem.contentMode = .scaleAspectFit
                imgMaterialItem.frame = CGRect(x:0, y:0,width :80, height:80)
                cell.contentView.addSubview(imgMaterialItem)
         
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(collectionView == fontCollectionView){
        let btnBold = self.view.viewWithTag(textFormat.bold.rawValue) as! UIButton
        let btnItalic = self.view.viewWithTag(textFormat.italic.rawValue) as! UIButton
        selectedFontCollectionIndexPath = indexPath
            for var visibleIndexPath in collectionView.indexPathsForVisibleItems
            {
                var cell = collectionView.cellForItem(at: visibleIndexPath)
                if(visibleIndexPath == selectedFontCollectionIndexPath){
                    cell?.layer.backgroundColor = UIColor.gray.cgColor
                }else{
                    cell?.layer.backgroundColor = UIColor.white.cgColor
                }
            }
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
        
        }
        if(collectionView == materialcollectionView)
        {
            let imageName = getImageNameFromDate()
            let fullImagePath = imagesDirectoryPath + "/\(imageName)"
            let getimage : UIImage = UIImage(named:materialImagesArray[indexPath.row])!
            let myImage = self.fixOrientation(image: getimage)
            
            dragzoomroatateview(img:myImage, imgName: imageName, type: contentType.image.rawValue, attributedString: NSAttributedString(string:""))
            let data = UIImagePNGRepresentation(myImage)
            let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
            if(success){
                print("image saved successfully in local")
            }
          
        }
        
        if(collectionView == textBoxCollectionView)
        {
            if(indexPath.row == 0){
                 dragzoomroatateview(img:UIImage(), imgName: "", type: contentType.text.rawValue, attributedString: NSAttributedString(string:"Double Tap to edit"))
            }
            else{
                let imageName = getImageNameFromDate()
                let fullImagePath = imagesDirectoryPath + "/\(imageName)"
                let getimage : UIImage = UIImage(named:textBoxImagesArray[indexPath.row])!
                let myImage = self.fixOrientation(image: getimage)
            
                dragzoomroatateview(img:myImage, imgName: imageName, type: contentType.imageAndText.rawValue, attributedString: NSAttributedString(string:"Double Tap to edit"))
                let data = UIImagePNGRepresentation(myImage)
                let success = FileManager.default.createFile(atPath: fullImagePath, contents: data, attributes: nil)
                if(success){
                    print("image saved successfully in local")
                }
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
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(scrolltouchhandlePan))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        imagePicker.delegate = self
        createImagesFolder()
        createDiaryImagesFolder()
        self.view.bringSubview(toFront: editorBGview)
        materialBGview.frame = CGRect(x: 0, y: 1000, width: self.materialBGview.frame.width, height: self.materialBGview.frame.height)
    
        let btnLeftAlign = self.view.viewWithTag(textFormat.leftAlign.rawValue) as! UIButton
        btnLeftAlign.setBackgroundImage(UIImage(named:"ico_left_checked.png"), for: UIControlState.normal)

        self.view.bringSubview(toFront: self.vwTextOptions)
        self.view.bringSubview(toFront: self.materialsBGview)

        self.materialsBGview.isHidden = true
    
        textViewEditTextBox.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        backgroundTextView.autocorrectionType = .no
        addDoneButtonOnKeyboard()
        
        self.hideKeyboardWhenTappedAround()
       
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        if(self.vwOverlay.isHidden == false){
            self.vwOverlay.isHidden = true
        }
        if(self.vwEditTextBox.isHidden == false){
            self.vwEditTextBox.isHidden = true
        }
        if(self.vwTextBoxOption.isHidden == false){
            self.vwTextBoxOption.isHidden = true
        }
        if(self.materialsBGview.isHidden == false){
            self.materialsBGview.isHidden = true
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
        if(vwTextBoxOption.isHidden == false){
            vwTextBoxOption.isHidden = true
        }
    }
    
 var gettouchLocationy:CGFloat = 0
    @objc func StickerImageMoveNotification(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            print("dictdictdictdict")
            print(dict)
            CalculateIncreasescrollviewHeight(getdicdata: dict)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reduceScrollviewHeight), name: NSNotification.Name(rawValue: "reduceScrollviewHeightNotification"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.dismissKeyboardOnDeleteTextBox), name: NSNotification.Name(rawValue: "dismissKeybordOnDeleteTextBoxNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.StickerImageMoveNotification), name: NSNotification.Name(rawValue: "StickerImageMoveNotification"), object: nil)

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
        //fontCollectionlayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        fontCollectionlayout.itemSize = CGSize(width: 55, height: 55)
        fontCollectionlayout.scrollDirection = .horizontal
        fontCollectionView.frame = CGRect(x:0,y:10,width:self.view.frame.width-10,height:130)
        fontCollectionView.collectionViewLayout = fontCollectionlayout
        fontCollectionView.dataSource = self
        fontCollectionView.delegate = self
        fontCollectionView.backgroundColor = UIColor.white
        
       fontCollectionView.selectItem(at: selectedFontCollectionIndexPath, animated: false, scrollPosition: .left)
        
        let textBoxCollectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        textBoxCollectionLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textBoxCollectionLayout.itemSize = CGSize(width: 80, height: 80)
        textBoxCollectionLayout.scrollDirection = .horizontal
        textBoxCollectionView.frame = CGRect(x:0,y:60,width:self.view.frame.width,height:160)
        textBoxCollectionView.collectionViewLayout = textBoxCollectionLayout
        textBoxCollectionView.dataSource = self
        textBoxCollectionView.delegate = self
        textBoxCollectionView.backgroundColor = UIColor.white
        /////////Material collection view
        let materialCollectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        materialCollectionLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        materialCollectionLayout.itemSize = CGSize(width: 80, height: 80)
        materialCollectionLayout.scrollDirection = .horizontal
        materialcollectionView.frame = CGRect(x:0,y:60,width:self.view.frame.width,height:160)
        materialcollectionView.collectionViewLayout = materialCollectionLayout
        materialcollectionView.dataSource = self
        materialcollectionView.delegate = self
        materialcollectionView.backgroundColor = UIColor.white
       
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = CGRect(x: 10, y: 70, width: self.view.frame.size.width-20, height: self.view.frame.size.height-140)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Keypad/Keyboard related methods
    @objc func keyboardWillAppear() {
        //Do something here
        didDisplayedKeyboard = true
        // Scroll Up when user selects background textView
//        if(backgroundTextView.isFirstResponder == true){
//            var offset = scrollView.contentOffset
//            offset.y = 0
//            self.scrollView.setContentOffset(offset, animated: true)
//            
//        }
    }
    
    @objc func keyboardWillDisappear() {
        //Do something here
        didDisplayedKeyboard = false
        self.vwEditTextBox.isHidden = true
    }
    var getkeyboardHeight : CGFloat = CGFloat()
    var didDisplayedKeyboard:Bool = false
    var checkmorebtn : Bool = true
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            getkeyboardHeight = keyboardSize.height
            
            if(self.textViewEditTextBox.isFirstResponder == true){
                
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    keyboardHeight = keyboardSize.height
                
                    showEditTextBox()
                }
                
            }else{
                self.vwEditTextBox.isHidden = true
            }
            
        }
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
   
    func addBackgroundTextView(){
        self.backgroundTextView = UITextView()
        self.backgroundTextView.allowsEditingTextAttributes = true
        self.backgroundTextView.backgroundColor = UIColor.clear
        self.backgroundTextView.font = .systemFont(ofSize: 18)
        self.backgroundTextView.frame = CGRect(x:0,y:0,width:self.view.frame.width-30, height:self.scrollView.contentSize.height)
        self.backgroundTextView.font = UIFont(name : selectedFontName, size:17)
        self.scrollView.addSubview(backgroundTextView)
    }
    
    @objc func dismissKeyboardOnDeleteTextBox(notification: NSNotification) {
        if(self.textViewEditTextBox.isFirstResponder == true && didDisplayedKeyboard == true){
            self.dismissKeyboard()
        }
    }
    
    // MARK:- ScrollView methods
    func CalculateIncreasescrollviewHeight(getdicdata: NSDictionary){
        if let Lastimageyposition = getdicdata["viewSize"] as? Int{
            print("compare")
            print(Lastimageyposition)

            var LastimageHeight = Int()
            LastimageHeight = (getdicdata["viewHeight"] as? Int)!
            var sumLastypositionandHeight = Int()
            sumLastypositionandHeight = Lastimageyposition + LastimageHeight
            // do something with your image
            let scrollviewcontentIntvalue = Int(self.scrollView.contentSize.height)
            if(sumLastypositionandHeight+20 > scrollviewcontentIntvalue)
            {
                
                self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 200)
                print("Increased Heoight")
                
            }
        }
    }
    func CalculateReducescrollviewHeight(getdicdata: NSDictionary)
    {
        if let Lastimageyposition = getdicdata["viewSize"] as? Int{
           
            var differencescrolllastimage = Int()
            var Reducedifferencescrolllastimage = Int()
            var LastimageHeight = Int()
            LastimageHeight = (getdicdata["viewHeight"] as? Int)!
            var sumLastypositionandHeight = Int()
            sumLastypositionandHeight = Lastimageyposition + LastimageHeight
            let scrollviewcontentIntvalue = Int(self.scrollView.contentSize.height)
        
            differencescrolllastimage = scrollviewcontentIntvalue - sumLastypositionandHeight
            
            var floatReducedifferencescrolllastimage = CGFloat()
            if(differencescrolllastimage > 60)
            {
                Reducedifferencescrolllastimage = differencescrolllastimage - 10
                floatReducedifferencescrolllastimage = CGFloat(Reducedifferencescrolllastimage)
                self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height - floatReducedifferencescrolllastimage)

            }
//            print(self.scrollView.contentSize.height)
//            print(sumLastypositionandHeight)
//            print("sumLastypositionandHeight")

            var offset = scrollView.contentOffset
            offset.y = scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom + 10
            scrollView.setContentOffset(offset, animated: false)
        }
    }
    // MARK:- ScrollView methods
    @objc func reduceScrollviewHeight(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            CalculateReducescrollviewHeight(getdicdata: dict)
        }
    }
    
    @objc func scrolltouchhandlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began
        {
            self.scrollView.isScrollEnabled = true
        }
    }

    // MARK:- Custom methods
    @IBAction func savebtn(_ sender: Any)
    {
        if(self.scrollView.subviews.count > 3){
            saveDataToCoredata(fromView: self.scrollView)
        }else{
            self.showAlert(alertMessage: "Nothing to Save!")
        }
        
    }
    // MARK
    var calcWidth = CGFloat(0)
    var calcHeight = CGFloat(0)
    func dragzoomroatateview(img : UIImage, imgName : String, type : Int, attributedString : NSAttributedString)
    {
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height )
        
        backgroundTextView.frame.size = CGSize(width:backgroundTextView.frame.size.width, height:self.scrollView.contentSize.height)
        
        hideOtherViewSelection()
        
        if(type == contentType.image.rawValue){
            let calcFrameWidth = self.view.frame.width-20
                if(img.size.width > (calcFrameWidth*7)){
                    calcWidth = img.size.width/15
                    calcHeight = img.size.height/15
                }else if(img.size.width > (calcFrameWidth*6) && img.size.width < (calcFrameWidth*7)){
                    calcWidth = img.size.width/13
                    calcHeight = img.size.height/13
                }else if(img.size.width > (calcFrameWidth*5) && img.size.width < (calcFrameWidth*6)){
                    calcWidth = img.size.width/11
                    calcHeight = img.size.height/11
                }else if(img.size.width > (calcFrameWidth*4) && img.size.width < (calcFrameWidth*5)){
                    calcWidth = img.size.width/9
                    calcHeight = img.size.height/9
                }else if(img.size.width > (calcFrameWidth*3) && img.size.width < (calcFrameWidth*4)){
                    calcWidth = img.size.width/7
                    calcHeight = img.size.height/7
                }else if(img.size.width > (calcFrameWidth*2) && img.size.width < (calcFrameWidth*3)){
                    calcWidth = img.size.width/5
                    calcHeight = img.size.height/5
                }else if(img.size.width > calcFrameWidth && img.size.width < (calcFrameWidth*2)){
                    if(img.size.height < 80 && img.size.height > 40){
                        calcWidth = img.size.width/2.5
                        calcHeight = img.size.height
                    }else if(img.size.height < 40){
                        calcWidth = img.size.width/2.5
                        calcHeight = 50
                    }
                    else{
                        calcWidth = img.size.width/2.5
                        calcHeight = img.size.height/2.5
                    }
                }else if((img.size.width > 300) && (img.size.width < calcFrameWidth)){
                    calcWidth = img.size.width/2
                    calcHeight = img.size.height/2
                }else{
                    calcWidth = img.size.width
                    calcHeight = img.size.height
                }
        }
        else if(type == contentType.imageAndText.rawValue){
            //calcWidth = CGFloat(200)
            //calcHeight = CGFloat(200)
            if(img.size.width > self.view.frame.width){
                calcWidth = img.size.width/4
                calcHeight = img.size.height/4
            }
            else{
                calcWidth = img.size.width
                calcHeight = img.size.height
            }
        }
        else{
            calcWidth = CGFloat(200)
            calcHeight = CGFloat(120)
        }

        stickerView = LDStickerView(frame: CGRect(x: (self.scrollView.contentSize.width-calcWidth)/2, y: self.scrollView.contentOffset.y+200, width: calcWidth, height: calcHeight))
     
        stickerView.accessibilityIdentifier = "drag"
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(textBoxDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        if(type == contentType.image.rawValue){
            picimageView = UIImageView()
            picimageView.image = img
            picimageView.frame = CGRect(x: 20 , y: 20, width: calcWidth-40, height: calcWidth-40)
            picimageView.accessibilityIdentifier = imgName
            //picimageView.contentMode = UIViewContentMode.scaleAspectFit
            stickerView.setContentView(picimageView)
        }
        else if(type == contentType.imageAndText.rawValue){
            btnImageWithText = UIButton(type : .custom)
            btnImageWithText.setBackgroundImage(img, for: .normal)
            btnImageWithText.frame = CGRect(x: 20 , y: 20, width: calcWidth-40, height: calcHeight-40)
            btnImageWithText.titleLabel?.textColor = .black
            btnImageWithText.titleLabel?.numberOfLines = 0
            btnImageWithText.titleLabel?.minimumScaleFactor = 0.2
            btnImageWithText.titleLabel?.adjustsFontSizeToFitWidth = true
            btnImageWithText.setAttributedTitle(attributedString, for: .normal)
            
            btnImageWithText.accessibilityIdentifier = imgName
            btnImageWithText.titleEdgeInsets = UIEdgeInsets(top:-10, left: 0, bottom: 0, right: 0)
            btnImageWithText.isUserInteractionEnabled = false
            //btnImageWithText.accessibilityIdentifier = "dragImageTextBox"
            stickerView.addGestureRecognizer(doubleTap)
            stickerView.setContentView(btnImageWithText)
        }
        else{

            btnPlainTextBox = UIButton(type:.custom)
            btnPlainTextBox.frame = CGRect(x: 20 , y: 20, width: calcWidth-40, height: calcHeight-40)
            btnPlainTextBox.titleLabel?.textColor = .black
            btnPlainTextBox.titleLabel?.numberOfLines = 0
            btnPlainTextBox.setAttributedTitle(attributedString, for: .normal)
            btnPlainTextBox.isUserInteractionEnabled = false
            btnPlainTextBox.accessibilityIdentifier = "dragPlainTextBox"
            stickerView.addGestureRecognizer(doubleTap)
            stickerView.setContentView(btnPlainTextBox)
        }
        if(stickerView.subviews.count == 3){
            stickerView.subviews[1].isHidden = false
            stickerView.subviews[2].isHidden = false
        }
        stickerView.tag = randomNumber(range: 1000...3000)
        self.scrollView.addSubview(stickerView)
        self.scrollView.isScrollEnabled = false
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
        self.txtVwQRCode.becomeFirstResponder()
    }
    @IBAction func MicBtn(_ sender: Any)
    {

    }
    @IBAction func Colorbtn(_ sender: Any)
    {
    }
    @IBAction func Draftbtn(_ sender: Any)
    {
        let HistoryVC = storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        self.navigationController?.pushViewController(HistoryVC, animated: true)
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
    
    func getMaximumUsedHeightOfDiaryView() -> Float {
            let array = NSMutableArray()
            var maxHeight : Float = 0.0
            if((self.scrollView?.subviews.count)! > 0){
                for view in (self.scrollView?.subviews)!
                {
                    if(view.accessibilityIdentifier == "drag"){
                        let dict : NSDictionary = ["tag" : view.tag, "viewSize" :  Int(view.frame.origin.y+view.frame.size.height)]
                        array.add(dict)
                    }
                }
                let sizeDescriptor = NSSortDescriptor(key: "viewSize", ascending: false)
                let sortedArray = array.sortedArray(using: [sizeDescriptor])
               
                let dict = sortedArray[0] as! NSDictionary
                maxHeight = Float(dict.value(forKey: "viewSize") as? Int ?? 0)
            }
        return maxHeight
    }
    
    func hideOtherViewSelection()
    {
        for view in self.scrollView.subviews
        {
            if(view.accessibilityIdentifier == "drag"){
                if(view.subviews.count == 3){
                    view.subviews[1].isHidden = true
                    view.subviews[2].isHidden = true
                    view.subviews[0].layer.borderWidth = 0.0
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
    func captureDiaryScreenAndSave(maxHeight : Float) -> String? {
        hideOtherViewSelection()
      
       //UIGraphicsBeginImageContextWithOptions(scrollView.frame.size, false, scrollView.layer.contentsScale)
        UIGraphicsBeginImageContext(scrollView.contentSize)
        
        let savedFrame = scrollView.frame
        scrollView.contentOffset = CGPoint.zero
       
        print("Max height : \(maxHeight)")
        scrollView.frame = CGRect(x: 0, y: 5, width: scrollView.contentSize.width, height: CGFloat(maxHeight+10) /*scrollView.contentSize.height*/)
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
    
    func showAlert(alertMessage:String){
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

func randomNumber(range: ClosedRange<Int> = 1...6) -> Int {
    let min = range.lowerBound
    let max = range.upperBound
    return Int(arc4random_uniform(UInt32(1 + max - min))) + min
}

