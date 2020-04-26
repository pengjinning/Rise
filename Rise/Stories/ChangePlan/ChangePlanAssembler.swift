//
//  ChangePlanAssembler.swift
//  Rise
//
//  Created by Владимир Королев on 02.02.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import Foundation

final class ChangePlanAssembler: StoryAssembler {
    typealias View = ChangePlanViewController
    
    func assemble() -> ChangePlanViewController {
        let controller = Storyboards.changePlan.instantiateViewController(of: ChangePlanViewController.self)
        controller.output = ChangePlanPresenter(view: controller,
                                                getPlan: DomainLayer.getPlan,
                                                updatePlan: DomainLayer.updatePlan,
                                                deletePlan: DomainLayer.deletePlan)
        return controller
    }
}
