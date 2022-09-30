//
//  Extension.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 21/09/22.
//

import Foundation

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}


