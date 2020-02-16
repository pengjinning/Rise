//
//  DaysCollectionViewCellModel.swift
//  Rise
//
//  Created by Владимир Королев on 09.12.2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import Foundation

struct DaysCollectionViewCellModel {
    let day: Day
    var sunTime: (sunrise: String, sunset: String)?
    var planTime: (wake: String, sleep: String)?
    var sunErrorMessage: String?
    var planErrorMessage: String?
    
    mutating func update(sunTime: DailySunTime) {
        self.sunTime = (sunrise: sunTime.sunrise.HHmmString,
                        sunset: sunTime.sunset.HHmmString)
        sunErrorMessage = nil
    }
    
    mutating func update(planTime: DailyPlanTime) {
        self.planTime = (wake: planTime.wake.HHmmString,
                         sleep: planTime.sleep.HHmmString)
        planErrorMessage = nil
    }
}
