//
//  ViewController.swift
//  Rise
//
//  Created by Vladimir Korolev on 23/05/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit
import UserNotifications

final class SleepViewController: UIViewController {
    
    // MARK: Properties
    private var gradientManager: GradientManager? {
        return GradientManager(frame: view.bounds)
    }
    private let textColor = "textColor"
    
    // MARK: IBOutlets
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTimePicker()
        registerLocal()
        createBackground()
    }
    
    // MARK: UI setup methods
    private func setupTimePicker() {
        timePicker.setValue(UIColor.white, forKeyPath: textColor)
    }
    
    private func createBackground() {
        guard let gradientView = gradientManager?.createStaticGradient(colors: [#colorLiteral(red: 0.1254607141, green: 0.1326543987, blue: 0.2668849528, alpha: 1), #colorLiteral(red: 0.34746629, green: 0.1312789619, blue: 0.2091784477, alpha: 1)],
                                                                       direction: .up,
                                                                       alpha: 1) else { return }
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
    }
    
    // MARK: Notification center methods
    private func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("granted")
            } else {
                print("\(String(describing: error))")
            }
        }
    }
    
    private func scheduleLocal() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        
        content.title = "Wake up"
        content.body = "its time to rise and shine"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        
        let date = timePicker.date
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        
    }
    
    // MARK: IBActions
    @IBAction func sleepButtonPressed(_ sender: UIButton) {
        scheduleLocal()
    }
    
}