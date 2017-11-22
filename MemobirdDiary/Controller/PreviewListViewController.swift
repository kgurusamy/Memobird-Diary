//
//  PreviewListViewController.swift
//  MemobirdDiary
//
//  Created by Mohammed Aslam on 20/11/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import UIKit
import CoreData

class PreviewListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let preiewList = [PreviewList]()
    // These strings will be the data for the table view cells
    //let animals: [String] = ["nature1.jpg", "nature1.jpg", "nature1.jpg", "nature1.jpg", "nature1.jpg"]
    
    // These are the colors of the square views in our table view cells.
    // In a real project you might use UIImages.
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]
    
    // Don't forget to enter this in IB also
    let cellReuseIdentifier = "cell"
    var previewList = [PreviewList]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preview"
        getSavedData()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.previewList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PreviewlistTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PreviewlistTableViewCell
        let fullImagePath = previewImagesDirectoryPath + "/\(previewList[indexPath.row].preview_image ?? "")"
        do {
            let fileURLPath = URL(fileURLWithPath : fullImagePath)
            let imageData = try Data(contentsOf: fileURLPath)
            let image = UIImage(data: imageData)
            cell.previewimageview.image = image
        }
        catch {
            print("Error loading image : \(error)")
        }
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            return 80
    }
    
    func getSavedData()
    {
        let fetchRequest: NSFetchRequest<PreviewList> = PreviewList.fetchRequest()
        // Sorting data according to modified time
        let sort = NSSortDescriptor(key: "modified_time", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            previewList = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
            
        } catch {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
