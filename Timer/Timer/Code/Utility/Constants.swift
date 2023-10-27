//
//  Constants.swift
//  Timer
//
//  Created by Ziya on 8/4/23.
//

import UIKit


struct Constants {
    static var hastopNotch: Bool {
        guard #available(iOS 11, *), let window = UIApplication.shared.windows.filter ({$0.isKeyWindow}).first else {return false}
        return window.safeAreaInsets.top >= 44
    }
}
