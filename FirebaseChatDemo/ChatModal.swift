//
//  ChatModal.swift
//  FirebaseChatDemo
//
//  Created by Shaik Baji on 14/10/19.
//  Copyright © 2019 smartitventures.com. All rights reserved.
//

import Foundation
import UIKit

class ChatModal
{
    var name:String?
    var profileImageUrl:String?
    var age:String?
    var id:String?
    
    init(id:String,name:String,profileImgURL:String, age:String)
    {
        self.name = name
        self.profileImageUrl = profileImgURL
        self.age = age
        self.id = id
    }
    
}
