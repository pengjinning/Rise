//
//  Coordinator.swift
//  Rise
//
//  Created by Vladimir Korolev on 14.05.2022.
//  Copyright © 2022 VladimirBrejcha. All rights reserved.
//

import UIKit
import DomainLayer
import UserNotifications
import Core
import UILibrary

final class RootCoordinator {
    private var useCases: UseCases
    private let navigationController: UINavigationController
    
    init(useCases: UseCases,
         navigationController: UINavigationController
    ) {
        self.useCases = useCases
        self.navigationController = navigationController
    }
    
    func run() {
        if useCases.manageOnboardingCompleted.isCompleted == false {
            navigationController.setViewControllers(
                [onboarding()],
                animated: true
            )
        } else {
            configureRoot()
        }
        useCases.notifyToSleep.onNotify = showTimeToSleepAlert
    }
    // MARK: - rootControllers
    
    private func configureRoot() {
        navigationController.setViewControllers(
            rootControllers,
            animated: true
        )
    }
    
    private var rootControllers: [UIViewController] {
        var controllers: [UIViewController] = [tabBar]
        
        // if is sleeping
        if let activeSleepEndDate = useCases.manageActiveSleep.alarmAt {
            let minSinceWakeUp = Date().timeIntervalSince(activeSleepEndDate) / 60
            switch minSinceWakeUp {
            case ..<0:
                controllers.append(sleep(params: activeSleepEndDate))
            case 0...30:
                controllers.append(alarming)
            default:
                // if expected wake up happened more than 30 minutes ago, discard sleep
                useCases.manageActiveSleep.endSleep()
            }
        }
        
        return controllers
    }
    
    // MARK: - All View Controllers
    
    private var tabBar: TabBarController {
        TabBarController(
            items: [schedule, today, settings],
            selectedIndex: 1
        )
    }
    
    private func onboarding(initial: Bool = true) -> Onboarding.Controller {
        Onboarding.Controller(
            deps: useCases,
            params: Onboarding.defaultParams,
            out: { [weak self, weak nc = navigationController] command in
                switch command {
                case .finish:
                    if initial {
                        self?.configureRoot()
                    } else {
                        nc?.popViewController(animated: true)
                    }
                }
            })
    }
    
    private var settings: Settings.Controller {
        .init(deps: useCases) { [self, unowned nc = navigationController] command in
            switch command {
            case .editSchedule(let schedule):
                nc.pushViewController(editSchedule(params: schedule), animated: true)
            case .adjustSchedule(let schedule):
                nc.present(
                    adjustSchedule((schedule, nil)),
                    with: .fullScreen
                )
            case .showOnboarding:
                nc.pushViewController(
                    onboarding(initial: false),
                    animated: true
                )
            case .showAbout:
                nc.present(about, with: .modal)
            case .showRefreshSuntime:
                nc.present(refreshSunTimes, with: .modal)
            case .showSelectAlarmMelody:
                nc.present(selectAlarmMelody, with: .modal)
            }
        }
    }
    
    private func editSchedule(params: EditSchedule.Controller.Params) -> EditSchedule.Controller {
        .init(deps: useCases, params: params) { [unowned nc = navigationController] command in
            switch command {
            case .finish:
                nc.popViewController(animated: true)
            }
        }
    }
    
    private var schedule: SchedulePage.Controller {
        .init(deps: useCases) { [self, unowned nc = navigationController] command in
            switch command {
            case .createSchedule(let onCreate):
                nc.present(
                    createSchedule(onCreate: onCreate),
                    with: .modal
                )
            case .editSchedule( let schedule):
                nc.pushViewController(editSchedule(params: schedule), animated: true)
            }
        }
    }
    
    private func createSchedule(
        onCreate: @escaping () -> Void
    ) -> CreateScheduleViewController {
        CreateScheduleAssembler().assemble(
            deps: useCases,
            onCreate: onCreate
        )
    }
    
    private func keepAppOpened(
        params: KeepAppOpenedSuggestion.Controller.Params
    ) -> KeepAppOpenedSuggestion.Controller {
        .init(params: params) { [unowned nc = navigationController] command in
            switch command {
            case .finish(let completion):
                nc.dismiss(
                    animated: true,
                    completion: completion
                )
            }
        }
    }
    
    private var prepareToSleep: PrepareToSleepViewController {
        let controller = Storyboard.sleep.instantiateViewController(of: PrepareToSleepViewController.self)
        controller.deps = useCases
        controller.out = { [self, unowned nc = navigationController] command in
            switch command {
            case .showKeepAppOpenedSuggestion(let completion):
                nc.present(
                    keepAppOpened(params: completion),
                    with: .fullScreen
                )
            case .finish:
                nc.popToRootViewController(animated: true)
            case .showSleep(let wakeUp):
                nc.replaceAllOnTopOfRoot(
                    with: sleep(params: wakeUp)
                )
            }
        }
        return controller
    }
    
    private var today: Today.Controller {
        .init(
            deps: useCases,
            params: Days.Controller(deps: useCases)
        ) { [self, unowned nc = navigationController] command in
            switch command {
            case .prepareToSleep:
                nc.pushViewController(
                    prepareToSleep,
                    animated: true
                )
            case let .adjustSchedule(currentSchedule, completion):
                nc.present(
                    adjustSchedule((currentSchedule, nil), completion: completion),
                    with: .modal
                )
            }
        }
    }
    
    private var refreshSunTimes: RefreshSunTimesViewController {
        .init(deps: useCases) { [unowned nc = navigationController] command in
            switch command {
            case .finish:
                nc.dismiss(animated: true)
            }
        }
    }

    private var selectAlarmMelody: SelectAlarmMelodyViewController {
        .init(deps: useCases) { [unowned nc = navigationController] command in
            switch command {
            case .save, .close:
                nc.dismiss(animated: true)
            }
        }
    }
    
    private func sleep(params: SleepViewController.Params) -> SleepViewController {
        .init(deps: useCases, params: params) { [self, unowned nc = navigationController] command in
            switch command {
            case .showKeepAppOpenedSuggestion:
                nc.present(
                    keepAppOpened(params: nil),
                    with: .modal
                )
            case .showAfterSleep:
                nc.replaceAllOnTopOfRoot(
                    with: afterSleep
                )
            case .showAlarming:
                nc.replaceAllOnTopOfRoot(
                    with: alarming
                )
            }
        }
    }
    
    private var alarming: AlarmingViewController {
        .init(deps: useCases) { [self, unowned nc = navigationController] command in
            switch command {
            case .alarmStopped:
                nc.replaceAllOnTopOfRoot(
                    with: afterSleep
                )
            case .alarmSnoozed(let newAlarmTime):
                nc.replaceAllOnTopOfRoot(
                    with: sleep(params: newAlarmTime)
                )
            }
        }
    }
    
    private var afterSleep: AfterSleepViewController {
        .init(deps: useCases) { [self, unowned nc = navigationController] command in
            switch command {
            case .finish:
                nc.popToRootViewController(
                    animated: true
                )
            case let .adjustSchedule(currentSchedule, toBed):
                nc.present(
                    adjustSchedule((currentSchedule: currentSchedule, toBed: toBed)),
                    with: .modal
                )
            }
        }
    }
    
    private func adjustSchedule(
        _ params: AdjustScheduleViewController.Params,
        completion: ((Bool) -> Void)? = nil
    ) -> AdjustScheduleViewController {
        .init(deps: useCases, params: params) { [unowned nc = navigationController] command in
            switch command {
            case .cancelAdjustment:
                nc.dismiss(animated: true, completion: {
                    completion?(false)
                })
            case .adjustmentCompleted:
                nc.dismiss(animated: true, completion: {
                    completion?(true)
                })
            }
        }
    }
    
    private var about: AboutViewController {
        .init(deps: useCases)
    }
    //MARK: - Random alerts
    
    func showTimeToSleepAlert(_ params: OnNotifyParams) {
        let ac = UIAlertController(title: params.title, message: params.description, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: params.acceptButton, style: .default) { _ in
            self.goToPrepareToSleep()
            self.useCases.notifyToSleep.stopNotificationTimer()}
        let cancelAction = UIAlertAction(title: params.cancelButton, style: .cancel) { _ in
            self.useCases.notifyToSleep.stopNotificationTimer()}
        
        ac.addAction(cancelAction)
        ac.addAction(okAction)
        
        navigationController.present(ac, animated: true)
        useCases.notifyToSleep.didNotify = true
    }
    
    func goToPrepareToSleep() {
        let vc = prepareToSleep
        self.navigationController.pushViewController(vc, animated: true)
    }
}

extension UINavigationController {
    func replaceAllOnTopOfRoot(with controller: UIViewController) {
        setViewControllers(
            [viewControllers.first, controller].compactMap { $0 },
            animated: true
        )
    }
}
