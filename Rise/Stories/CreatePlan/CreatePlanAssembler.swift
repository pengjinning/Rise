//
//  CreatePlanAssembler.swift
//  Rise
//
//  Created by Vladimir Korolev on 06.01.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

final class CreatePlanAssembler {
    func assemble() -> CreatePlanViewController {
        let controller = Storyboard.setupPlan.instantiateViewController(of: CreatePlanViewController.self)
        controller.createSchedule = DomainLayer.createSchedule
        controller.saveSchedule = DomainLayer.saveSchedule
        controller.stories = [
            .welcomeCreatePlan,
            .sleepDurationCreatePlan(
                sleepDurationOutput: { [weak controller] value in
                    controller?.sleepDurationValueChanged(value)
                },
                presettedSleepDuration: controller.choosenSleepDuration
            ),
            .wakeUpTimeCreatePlan(
                wakeUpTimeOutput: { [weak controller] value in
                    controller?.wakeUpTimeValueChanged(value)
                },
                presettedWakeUpTime: controller.choosenWakeUpTime
            ),
            .wentSleepCreatePlan(
                wentSleepOutput: { [weak controller] value in
                    controller?.lastTimeWentSleepValueChanged(value)
                },
                presettedWentSleepTime: controller.choosenLastTimeWentSleep
            ),
            .planCreatedSetupPlan
        ]
        return controller
    }
}
