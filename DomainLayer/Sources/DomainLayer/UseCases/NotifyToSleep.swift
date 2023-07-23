import Foundation
import Core
import UIKit

public typealias OnNotifyParams = (title: String, description: String, acceptButton: String, cancelButton: String)

public protocol HasNotifyToSleep {
    var notifyToSleep: NotifyToSleep { get }
}

public protocol NotifyToSleep: AnyObject {
    var onNotify: ((OnNotifyParams) -> Void)? { get set }
    var didNotify: Bool { get set }
    func startNotificationTimer()
    func stopNotificationTimer()
    func setNotificationActiveViewController(_ viewController: UIViewController)
    func setPermissionViewControllerIfNeeded(_ permission: UIViewController)
}

class NotifyToSleepImpl: NotifyToSleep {
    func setNotificationActiveViewController(_ viewController: UIViewController) {
        self.activeViewController = viewController
    }
    func setPermissionViewControllerIfNeeded(_ permission: UIViewController) {
        self.permissionViewController = permission
    }
    
    var startTime: TimeInterval = 0.0
    var timer: Timer?
    var didNotify: Bool = false
    let getSchedule: GetSchedule
    let manageActiveSleep: ManageActiveSleep
    var onNotify: ((OnNotifyParams) -> Void)?
    var activeViewController: UIViewController?
    var permissionViewController: UIViewController?
    var lastNotificationDate: Date?
    
    init(getSchedule: GetSchedule, manageActiveSleep: ManageActiveSleep) {
        self.getSchedule = getSchedule
        self.manageActiveSleep = manageActiveSleep
        
    }
    
    func startNotificationTimer() {
        if didNotify {
            return
        }
        stopNotificationTimer()
        startTime = Date.timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(checkSleepTime), userInfo: nil, repeats: true)
    }
    
    @objc func checkSleepTime() {
        let currentDate = Date()
        guard let timeToSleep = getSchedule.today()?.toBed else { return }
        
        if currentDate >= timeToSleep {
            checkPermissions()
            if manageActiveSleep.sleepStartedAt == nil {
                notify()
            }
        }
    }
    
    func stopNotificationTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func notify() {
        let randomInt = Int.random(in: 0...9)
        guard randomInt >= 0 && randomInt < NotificationData.alertTitles.count else { return }
        
        let title = NotificationData.alertTitles[randomInt]
        let description = NotificationData.alertDescriptions[randomInt]
        let acceptButton = NotificationData.acceptButtons[randomInt]
        let cancelButton = NotificationData.cancelButtons[randomInt]
        
        onNotify?(OnNotifyParams(title, description, acceptButton, cancelButton))
    }
    
    func checkPermissions() {
        if NotificationManager.isNotificationPermissionGraned {
            log(.info, "Notification permission granted")
        } else {
            let permissionVC = PermissionViewController()
            
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let topViewController = windowScene.windows.first?.rootViewController {
                topViewController.present(permissionVC, animated: true, completion: nil)
            }
        }
    }
    
    struct NotificationData {
        static let alertTitles: [String] = ["Sleepy Time Awaits",
                                            "Ready for Dreamland?",
                                            "Dream Journey Ahead",
                                            "Time to Recharge",
                                            "Off to the Land of Nod",
                                            "Embrace the Night",
                                            "Your Dreams Await",
                                            "Healing Slumber Calls",
                                            "Step into Tranquility",
                                            "Unleash Your Rest"]
        
        static let alertDescriptions: [String] = ["Sleep is the best meditation. Are you ready to recharge for a better tomorrow?",
                                                  "Don't count sheep, count on us for a better sleep. Shall we begin?",
                                                  "Your dreams are waiting for you. Ready to explore them with us?",
                                                  "The stars are shining, and the moon is bright. It's the perfect time to say goodnight. Shall we?",
                                                  "Empower your tomorrow with the sleep of today. Ready to rest your mind?",
                                                  "Your body heals during sleep. Let's get some healing done, shall we?",
                                                  "Sweet dreams are made of these moments of peace. Ready to dive into tranquility?",
                                                  "Tonight's forecast? 100% chance of sleep. Ready for a blissful journey?",
                                                  "A well-rested you is the best you. Are you ready to wake up refreshed?",
                                                  "The night is young, and dreams are waiting. Ready to join the world of dreams?"]
        
        static let cancelButtons: [String] = ["Maybe Later",
                                              "Not Now",
                                              "Perhaps Later",
                                              "Maybe in a Bit",
                                              "Later",
                                              "Not Yet",
                                              "Later Maybe",
                                              "Soon",
                                              "In a While",
                                              "A Bit Later"]
        
        static  let acceptButtons: [String] = ["Start Sleeping",
                                               "Yes, Let's Sleep",
                                               "Begin Dreaming",
                                               "Goodnight",
                                               "Start Resting",
                                               "Time to Heal",
                                               "Dive In",
                                               "Start Journey",
                                               "Refresh Now",
                                               "Join Dreams"]
    }
}

