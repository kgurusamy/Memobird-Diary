
//
//  ViewController.swift
//  MemobirdDiary
//
//  Created by Mohammed Aslam on 22/09/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import UIKit
class ViewController: UIViewController,UITabBarDelegate {

    @IBOutlet weak var Tabbarview: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tabbarview.delegate = self
        self.title = "MEMOBIRD"
        // Do any additional setup after loading the view, typically from a nib.
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Test")
        if(item.tag == 1){
          
            let DiaryVC = storyboard?.instantiateViewController(withIdentifier: "DiaryViewController") as! DiaryViewController
            self.navigationController?.pushViewController(DiaryVC, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

