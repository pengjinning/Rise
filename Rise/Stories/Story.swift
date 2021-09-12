//
//  Story.swift
//  Rise
//
//  Created by Vladimir Korolev on 04.01.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import UIKit

enum Story {
    // Onboarding
    case onboarding(dismissOnCompletion: Bool)

    // Main
    case tabBar
    case today
    case days (frame: CGRect)
    case plan
    case settings
    
    // Create plan
    case createPlan
    case welcomeCreatePlan
    case sleepDurationCreatePlan(sleepDurationOutput: (Int) -> Void, presettedSleepDuration: Int?)
    case wakeUpTimeCreatePlan(wakeUpTimeOutput: (Date) -> Void, presettedWakeUpTime: Date?)
    case wentSleepCreatePlan(wentSleepOutput: (Date) -> Void, presettedWentSleepTime: Date?)
    case planCreatedSetupPlan
    
    // Change plan
    case changePlan
    
    // Сonfirmation
    case confirmation
    
    // Sleep
    case prepareToSleep
    case sleep(alarmTime: Date)
    case alarming(alarmTime: Date)

    // Settings
    case about
    
    func callAsFunction() -> UIViewController {
        switch self {
        case .tabBar:
            return CustomTabBarController(
                items: [Story.plan(), Story.today(), Story.settings()],
                selectedIndex: 1
            )
        case let .onboarding(dismissOnCompletion):
            return OnboardingAssembler().assemble(dismissOnCompletion: dismissOnCompletion)
        case .today:
            return TodayAssembler().assemble()
        case .days(let frame):
            return DaysAssembler().assemble(frame: frame)
        case .plan:
            return PersonalPlanAssembler().assemble()
        case .settings:
            return SettingsAssembler().assemble()
        case .createPlan:
            return CreatePlanAssembler().assemble()
        case .welcomeCreatePlan:
            let controller = Storyboard.setupPlan.instantiateViewController(of: WelcomeCreatelPlanViewController.self)
            return controller
        case .sleepDurationCreatePlan(let sleepDurationOutput, let presettedSleepDuration):
            let controller = Storyboard.setupPlan.instantiateViewController(of: SleepDurationCreatePlanViewController.self)
            controller.sleepDurationOutput = sleepDurationOutput
            controller.presettedSleepDuration = presettedSleepDuration
            return controller
        case .wakeUpTimeCreatePlan(let wakeUpTimeOutput, let presettedWakeUpTime):
            let controller = Storyboard.setupPlan.instantiateViewController(of: WakeUpTimeCreatePlanViewController.self)
            controller.wakeUpTimeOutput = wakeUpTimeOutput
            controller.presettedWakeUpTime = presettedWakeUpTime
            return controller
        case .wentSleepCreatePlan(let wentSleepOutput, let presettedWentSleepTime):
            let controller = Storyboard.setupPlan.instantiateViewController(of: WentSleepCreatePlanViewController.self)
            controller.wentSleepTimeOutput = wentSleepOutput
            controller.presettedWentSleepTime = presettedWentSleepTime
            return controller
        case .planCreatedSetupPlan:
            let controller = Storyboard.setupPlan.instantiateViewController(of: PlanCreatedCreatePlanViewController.self)
            return controller
        case .changePlan:
            return ChangePlanAssembler().assemble()
        case .confirmation:
            return ConfirmationAssembler().assemble()
        case .prepareToSleep:
            return PrepareToSleepAssembler().assemble()
        case .sleep(let alarmTime):
            return SleepAssembler().assemble(alarm: alarmTime)
        case .alarming(let alarmTime):
            return AlarmingAssembler().assemble(alarm: alarmTime)
        case .about:
            return AboutAssembler().assemble()
        }
    }
}
