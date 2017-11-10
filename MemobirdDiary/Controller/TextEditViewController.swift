//
//  TextEditViewController.swift
//  MemobirdDiary
//
//  Created by Kumaravel on 25/09/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import UIKit

class TextEditViewController: UIViewController {

    @IBOutlet weak var vwfontOptions : UIView!
    @IBOutlet weak var btnBold : UIButton!
    @IBOutlet weak var btnFontSize : UIButton!
    @IBOutlet weak var sliderFontSize : UISlider!
    @IBOutlet weak var txtContent : UITextView!
    @IBOutlet weak var txtImageView : UIImageView!
   
    
    var keyboardHeight : CGFloat! = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Text Editing"

        sliderFontSize.isHidden = true
        vwfontOptions.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Insert", style: .done, target: self, action: #selector(insertTapped))
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @objc func insertTapped()
    {
        let vcsCount = self.navigationController?.viewControllers.count
        let diaryController = self.navigationController?.viewControllers[vcsCount! - 2] as! DiaryViewController
        
        self.txtContent.resignFirstResponder()
    
        diaryController.dragzoomroatateview(img: UIImage(), imgName: "", type: contentType.text.rawValue, attributedString : txtContent.attributedText)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBold_tapped(_ sender : UIButton)
    {
        sender.isSelected = !sender.isSelected;
        if (sender.isSelected) {
            sender.backgroundColor = UIColor.blue
            sender.setTitleColor(UIColor.white, for: UIControlState.normal)
            txtContent.font = UIFont.boldSystemFont(ofSize: CGFloat(16.0+sliderFontSize.value))
        }
        else
        {
            sender.backgroundColor = UIColor.white
            sender.setTitleColor(UIColor.blue, for: UIControlState.normal)
            txtContent.font = UIFont.systemFont(ofSize: CGFloat(16.0+sliderFontSize.value))
        }
    }
    
    @IBAction func btnFontSize_tapped(_ sender : UIButton)
    {
        sender.isSelected = !sender.isSelected;
        if (sender.isSelected) {
            sliderFontSize.isHidden = false
        }
        else{
            sliderFontSize.isHidden = true
        }
    }
    
    func screenshotTextView()
    {
        self.txtContent.resignFirstResponder()
        UIGraphicsBeginImageContextWithOptions(self.txtContent.contentSize, false, 0);
        self.txtContent.drawHierarchy(in: self.txtContent.bounds, afterScreenUpdates: true)
        let copied = UIGraphicsGetImageFromCurrentImageContext();
        self.txtImageView.image = copied
        self.txtImageView.contentMode = UIViewContentMode.scaleAspectFit
        print("screenshot imagesize \(String(describing: self.txtImageView.image?.size))")
        UIGraphicsEndImageContext()
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = sender.value
        if(btnBold.isSelected){
            txtContent.font = UIFont.boldSystemFont(ofSize: CGFloat(16.0+currentValue))
        }
        else{
            txtContent.font = UIFont.systemFont(ofSize: CGFloat(16.0+currentValue))
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            self.vwfontOptions.frame = CGRect(x:self.vwfontOptions.frame.origin.x,y: self.view.frame.size.height - keyboardSize.height - vwfontOptions.frame.size.height, width : self.vwfontOptions.frame.size.width, height : self.vwfontOptions.frame.size.height)
           
            self.vwfontOptions.isHidden = false
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        
            self.vwfontOptions.frame = CGRect(x:self.vwfontOptions.frame.origin.x, y:self.view.frame.size.height - keyboardHeight - vwfontOptions.frame.size.height, width : self.vwfontOptions.frame.size.width, height : self.vwfontOptions.frame.height)
            print("frame hide : \(self.vwfontOptions.frame), keyboardHeight : \(keyboardHeight)")
            self.vwfontOptions.isHidden = true
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
