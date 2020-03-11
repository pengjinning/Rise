//
//  MakePlan.swift
//  Rise
//
//  Created by Владимир Королев on 05.01.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import Foundation

protocol MakePlan {
    func execute(sleepDurationMin: Int,
                 wakeUpTime: Date,
                 planDurationDays: Int,
                 firstSleepTime: Date) throws
}

final class MakePlanUseCase: MakePlan {
    private let planRepository: RisePlanRepository
    private let dailyShiftFormula: DailyShiftFormula
    private let dateIntervalFormula: DateIntervalFormula
    
    required init(planRepository: RisePlanRepository,
                  dailyShiftFormula: @escaping DailyShiftFormula,
                  dateIntervalFormula: @escaping DateIntervalFormula) {
        self.planRepository = planRepository
        self.dailyShiftFormula = dailyShiftFormula
        self.dateIntervalFormula = dateIntervalFormula
    }
    
    func execute(sleepDurationMin: Int,
                 wakeUpTime: Date,
                 planDurationDays: Int,
                 firstSleepTime: Date) throws {
        let dateInterval = dateIntervalFormula(firstSleepTime, planDurationDays)
        let sleepDuration: Double = Double(sleepDurationMin * 60)
        let wakeUpTime = calendar.date(bySettingHour: calendar.component(.hour, from: wakeUpTime),
                                       minute: calendar.component(.minute, from: wakeUpTime),
                                       second: calendar.component(.second, from: wakeUpTime),
                                       of: dateInterval.end)!
        let finalToSleepTime = wakeUpTime.addingTimeInterval(-sleepDuration)
        let dailyShift = dailyShiftFormula(firstSleepTime, finalToSleepTime, Double(planDurationDays))
        
        try planRepository.save(plan: RisePlan(dateInterval: dateInterval,
                                               firstSleepTime: firstSleepTime,
                                               finalWakeUpTime: wakeUpTime,
                                               sleepDurationSec: sleepDuration,
                                               dailyShiftSec: dailyShift,
                                               latestConfirmedDay: dateInterval.start,
                                               daysMissed: 0,
                                               paused: false))
    }
}