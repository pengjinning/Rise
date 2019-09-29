//
//  Constants.swift
//  Rise
//
//  Created by Vladimir Korolev on 27/05/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import Foundation

struct DataForPicker {
    static let daysArray = ["Hardcore - 10 days", "Normal - 15 days", "Recommended - 30 days", "Calm - 50 days"]
    static let hoursArray = ["7 hours", "7.5 hours", "Recommended - 8 hours", "8.5 hours", "9 hours"]
    
    private init() { }
}

struct Formater {
    static let dateFormatter = CustomDateFormatter()
    
    private init() { }
}

struct Identifiers {
    static let sleep = "sleep"
    static let personal = "personal"
    
    private init() { }
}

