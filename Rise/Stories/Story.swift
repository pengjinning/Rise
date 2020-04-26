//
//  Story.swift
//  Rise
//
//  Created by Владимир Королев on 04.01.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import UIKit

enum Story {
    // Main
    case today
    case plan
    case settings
    
    // Create plan
    case createPlan
    case welcomeCreatePlan
    case sleepDurationCreatePlan(sleepDurationOutput: (Int) -> Void)
    case wakeUpTimeCreatePlan(wakeUpTimeOutput: (Date) -> Void)
    case planDurationCreatePlan(planDurationOutput: (Int) -> Void)
    case wentSleepCreatePlan(wentSleepOutput: (Date) -> Void)
    case planCreatedSetupPlan
    
    // Change plan
    case changePlan
    
    // Сonfirmation
    case confirmation
    
    // Sleep
    case prepareToSleep
    case sleep(alarmTime: Date)
    
    func configure() -> UIViewController {
        switch self {
        case .today:
            return TodayAssembler().assemble()
        case .plan:
            return PersonalPlanAssembler().assemble()
        case .settings:
            return SettingsAssembler().assemble()
        case .createPlan:
            return CreatePlanAssembler().assemble()
        case .welcomeCreatePlan:
            let controller = Storyboards.setupPlan.instantiateViewController(of: WelcomeCreatelPlanViewController.self)
            return controller
        case .sleepDurationCreatePlan(let sleepDurationOutput):
            let controller = Storyboards.setupPlan.instantiateViewController(of: SleepDurationCreatePlanViewController.self)
            controller.sleepDurationOutput = sleepDurationOutput
            return controller
        case .wakeUpTimeCreatePlan(let wakeUpTimeOutput):
            let controller = Storyboards.setupPlan.instantiateViewController(of: WakeUpTimeCreatePlanViewController.self)
            controller.wakeUpTimeOutput = wakeUpTimeOutput
            return controller
        case .planDurationCreatePlan(let planDurationOutput):
            let controller = Storyboards.setupPlan.instantiateViewController(of: PlanDurationCreatePlanViewController.self)
            controller.planDurationOutput = planDurationOutput
            return controller
        case .wentSleepCreatePlan(let wentSleepOutput):
            let controller = Storyboards.setupPlan.instantiateViewController(of: WentSleepCreatePlanViewController.self)
            controller.wentSleepTimeOutput = wentSleepOutput
            return controller
        case .planCreatedSetupPlan:
            let controller = Storyboards.setupPlan.instantiateViewController(of: PlanCreatedCreatePlanViewController.self)
            return controller
        case .changePlan:
            return ChangePlanAssembler().assemble()
        case .confirmation:
            return ConfirmationAssembler().assemble()
        case .prepareToSleep:
            return PrepareToSleepAssembler().assemble()
        case .sleep(let alarmTime):
            return SleepAssembler().assemble(alarm: alarmTime)
        }
    }
}
