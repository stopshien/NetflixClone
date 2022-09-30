//
//  Extensions.swift
//  NetflixClone
//
//  Created by stopshien on 2022/8/9.
//

import Foundation

extension String{
    
    //將文字設定成第一個大寫其他小寫的Func，製作完之後在他使用在Section Heander 的文字上，因我這邊使用的是中文，故沒有進行更改。
    func capitalizeFirstLetter() -> String{
        return self.prefix(1).uppercased() + self.lowercased().dropFirst() //dropFirst拿掉第一個字
    }
}
