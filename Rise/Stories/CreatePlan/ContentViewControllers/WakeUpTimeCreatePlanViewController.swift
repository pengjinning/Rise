//
//  WakeUpTimeCreatePlanViewController.swift
//  Rise
//
//  Created by Владимир Королев on 11.12.2019.
//  Copyright © 2019-2020 VladimirBrejcha. All rights reserved.
//

import UIKit

final class WakeUpTimeCreatePlanViewController: UIViewController {
    
    var wakeUpTimeOutput: ((Date) -> Void)! // DI
    
    @IBAction private func wakeUpTimeChanged(_ sender: UIDatePicker) {
        wakeUpTimeOutput(sender.date)
    }
}
