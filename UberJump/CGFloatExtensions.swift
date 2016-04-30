//
//  CGFloatExtensions.swift
//  LocknRoll
//
//  Created by Daniel Ekeroth on 2016-04-24.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation

public extension CGFloat {
    public static func Random() -> CGFloat {
        
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    public static func Random(min min: CGFloat,max: CGFloat) -> CGFloat
    {
        return CGFloat.Random() * (max-min) + min
    }
}