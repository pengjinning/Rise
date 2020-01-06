//
//  CreatePlan.swift
//  Rise
//
//  Created by Владимир Королев on 05.01.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import Foundation

final class CreatePlan: UseCase {
    typealias InputValue = PersonalPlan
    typealias CompletionHandler = Void
    typealias OutputValue = Bool
    
    private let planRepository: PersonalPlanRepository
    
    required init(planRepository: PersonalPlanRepository) {
        self.planRepository = planRepository
    }
    
    func execute(_ requestValue: PersonalPlan, completion: Void) -> Bool {
        planRepository.create(personalPlan: requestValue)
    }
}