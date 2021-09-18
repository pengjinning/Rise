//
//  TodayViewController.swift
//  Rise
//
//  Created by Vladimir Korolev on 03/06/2019.
//  Copyright © 2019-2020 VladimirBrejcha. All rights reserved.
//

import UIKit

final class TodayViewController: UIViewController, PropertyAnimatable {

    private var todayView: TodayView { view as! TodayView }
    private let daysViewController = Story.days() as! DaysViewController

    private let getPlan: GetPlan
    private let observePlan: ObservePlan
    private let getDailyTime: GetDailyTime
    private let confirmPlan: ConfirmPlan

    var propertyAnimationDuration: Double { 0.15 }
    private var schedule: RisePlan?

    // MARK: - LifeCycle

    init(
        getPlan: GetPlan,
        observePlan: ObservePlan,
        getDailyTime: GetDailyTime,
        confirmPlan: ConfirmPlan
    ) {
        self.getPlan = getPlan
        self.observePlan = observePlan
        self.getDailyTime = getDailyTime
        self.confirmPlan = confirmPlan

        super.init(nibName: nil, bundle: nil)

        self.schedule = try? self.getPlan()
        self.observePlan.observe { [weak self] schedule in
            self?.schedule = schedule
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoder")
    }

    override func loadView() {
        super.loadView()
        self.view = TodayView(
            timeUntilSleepDataSource: { [weak self] in
                self?.floatingLabelModel ?? .empty
            },
            sleepHandler: { [weak self] in
                self?.present(
                    AnimatedTransitionNavigationController(
                        rootViewController: Story.prepareToSleep()
                    ),
                    with: .fullScreen
                )
            },
            daysView: daysViewController.daysView
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(daysViewController)
        daysViewController.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let confirmed = try? confirmPlan.checkIfConfirmed() {
            makeTabBar(visible: confirmed)
            if !confirmed {
                present(
                    Story.confirmation(),
                    with: .overContext
                )
            }
        }
    }

    deinit {
        observePlan.cancel()
    }

    // MARK: - Floating label model
    
    private var floatingLabelModel: FloatingLabel.Model {
        guard let plan = schedule else { return .empty }

        let alpha: Float = 0.85
        
        if plan.paused {
            return .init(
                text: Text.riseScheduleIsPaused,
                alpha: alpha
            )
        }
        
        guard
            let todayDailyTime = try? getDailyTime(
                for: plan,
                date: NoonedDay.today.date
            ),
            let minutesUntilSleep = calendar.dateComponents(
                [.minute],
                from: Date(),
                to: todayDailyTime.sleep
            ).minute
        else {
            return .empty
        }

        switch minutesUntilSleep {
        case ...0:
            return .init(
                text: Text.itsTimeToSleep,
                alpha: alpha
            )
        case 1..<10:
            return .init(
                text: Text.sleepInJustAFew(minutesUntilSleep.HHmmString),
                alpha: alpha
            )
        case 10...(60 * 5):
            return .init(
                text: Text.sleepIsScheduledIn(minutesUntilSleep.HHmmString),
                alpha: alpha
            )
        default:
            return .empty
        }
    }

    // MARK: - Utils

    private func makeTabBar(visible: Bool) {
        animate {
            self.tabBarController?.tabBar.alpha = visible ? 1 : 0
        }
    }
}

fileprivate extension FloatingLabel.Model {
    static var empty = FloatingLabel.Model(text: "", alpha: 0)
}
