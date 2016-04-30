//
//  Sound.swift
//  UberJump
//
//  Created by Daniel Ekeroth on 2016-04-19.
//  Copyright © 2016 Geekfox Consulting. All rights reserved.
//

import Foundation

public class Sound {
    init(path: String,name: String)
    {
        Path = path
        Name = name
    }
    var Path: String = ""
    func URL() -> NSURL {
        return NSURL(fileURLWithPath: Path)
    }
    var Name: String = ""
}