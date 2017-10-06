//
//  HistoryViewController.swift
//  MemobirdDiary
//
//  Created by Mohammed Aslam on 25/09/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!
    var diaryEntries = [DiaryEntry]()
    let imageViewDefaultTag = 10
    let dateLabelDefaultTag = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.title = "History"
        self.tableView.rowHeight = UITableViewAutomaticDimension
        getSavedData()
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return diaryEntries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(diaryEntries[indexPath.row].diary_height/1.85)
        //return 300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
        let myDateLabel : UILabel! = cell.contentView.viewWithTag(dateLabelDefaultTag) as! UILabel!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let modifiedDateTime = diaryEntries[indexPath.row].modified_time
        myDateLabel.text = formatter.string(from: modifiedDateTime! as Date)
       
        let myImageView : UIImageView! = cell.contentView.viewWithTag(imageViewDefaultTag) as! UIImageView!
       
        myImageView.contentMode = UIViewContentMode.scaleToFill
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        let diaryImagesDirectoryPath = documentDirectorPath + "/DiaryImages"
        let data = FileManager.default.contents(atPath: diaryImagesDirectoryPath + "/\(diaryEntries[indexPath.row].diary_image ?? "")")
        if(data != nil){
            myImageView.image = UIImage(data: data!)
        }
        myImageView.frame = CGRect(x : 30, y: 15, width : CGFloat((myImageView.image?.size.width)!/2), height:CGFloat(diaryEntries[indexPath.row].diary_height/2))
        myImageView.center = cell.contentView.center
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.navigateToDiaryView(forIndex: indexPath.row)
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            CoreDataStack.managedObjectContext.delete(self.diaryEntries[indexPath.row])
            deleteFileWithImageName(imageName: self.diaryEntries[indexPath.row].diary_image!, isDiary: true)
            deleteImagesFromDiaryData(dataModelArr: self.diaryEntries[indexPath.row].diary_data as! [dataModel])
            self.getSavedData()
            self.tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(optionMenu, animated: true) {
            print("option menu presented")
        }
    }
    
    func navigateToDiaryView(forIndex : Int)
    {
        let diaryVC = storyboard?.instantiateViewController(withIdentifier: "DiaryViewController") as! DiaryViewController
        diaryVC.selectedDiaryEntryIndex = forIndex
        self.navigationController?.pushViewController(diaryVC, animated: true)
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
            self.diaryEntries = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
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
