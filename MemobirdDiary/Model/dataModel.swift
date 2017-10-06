//
//  ItemModel.swift
//  MemobirdDiary
//
//  Created by Oottru Technologies on 27/09/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import Foundation
import CoreGraphics
class dataModel : NSObject,NSCoding {
    
    var imageName: String
    var xPos : CGFloat
    var yPos : CGFloat
    var width : CGFloat
    var height : CGFloat
    var radians : CGFloat
    var angle : CGFloat
    var type : Int
    var attributedString : NSAttributedString
    
    init(imageName:String, xPos : CGFloat, yPos : CGFloat, width : CGFloat, height : CGFloat,radians : CGFloat, angle : CGFloat, type : Int, attributedString : NSAttributedString)
    {
        self.imageName = imageName
        self.xPos = xPos
        self.yPos = yPos
        self.width = width
        self.height = height
        self.radians = radians
        self.angle = angle
        self.type = type
        self.attributedString = attributedString
    }
    
    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
        self.imageName = (decoder.decodeObject(forKey: "imageName") as? String) ?? ""
        self.xPos = (decoder.decodeObject(forKey: "xPos") as? CGFloat) ?? 0
        self.yPos = (decoder.decodeObject(forKey: "yPos") as? CGFloat) ?? 0
        self.width = (decoder.decodeObject(forKey: "width") as? CGFloat) ?? 0
        self.height = (decoder.decodeObject(forKey: "height") as? CGFloat) ?? 0
        self.radians = (decoder.decodeObject(forKey: "radians") as? CGFloat) ?? 0
        self.angle = (decoder.decodeObject(forKey: "angle") as? CGFloat) ?? 0
        self.type = decoder.decodeInteger(forKey: "type")
        self.attributedString = ((decoder.decodeObject(forKey: "attributedString") as? NSAttributedString) ?? NSAttributedString(string: ""))
    }
    
    func encode(with coder: NSCoder) {
    
        coder.encode(self.imageName, forKey: "imageName")
        coder.encode(self.xPos, forKey: "xPos")
        coder.encode(self.yPos, forKey: "yPos")
        coder.encode(self.width, forKey: "width")
        coder.encode(self.height, forKey: "height")
        coder.encode(self.radians, forKey: "radians")
        coder.encode(self.angle, forKey: "angle")
        coder.encode(self.type, forKey: "type")
        coder.encode(self.attributedString, forKey: "attributedString")
    }
    
    
}
