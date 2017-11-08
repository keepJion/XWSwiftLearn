//
//  VersionModel.swift
//  RxSwiftStudy
//
//  Created by Mr.xiao on 2017/10/22.
//  Copyright © 2017年 keepJion. All rights reserved.
//

import Foundation
import HandyJSON

struct VersionModel : HandyJSON {
    
    var msg: String?
    var status: Int?
    var latest: String?
}

struct ZVersion : HandyJSON {
    var msg: String?
    var status: Int?
    var latest: String?
}
