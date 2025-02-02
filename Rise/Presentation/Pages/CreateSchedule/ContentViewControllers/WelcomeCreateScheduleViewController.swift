//
//  WelcomeCreateScheduleViewController.swift
//  Rise
//
//  Created by Vladimir Korolev on 22.12.2019.
//  Copyright © 2019-2020 VladimirBrejcha. All rights reserved.
//

import UIKit

final class WelcomeCreateScheduleViewController: UIViewController {

    @IBOutlet private var icon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        icon.layer.applyStyle(.gloomingIcon)
    }
}
