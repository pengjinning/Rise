//
//  DaysViewController.swift
//  Rise
//
//  Created by Vladimir Korolev on 07.03.2021.
//  Copyright © 2021 VladimirBrejcha. All rights reserved.
//

import UIKit
import Core
import DomainLayer
import Localization
import DataLayer
import UILibrary

extension Days {

    final class Controller:
        UIViewController,
        AlertCreatable,
        LocationPermissionAlertPresentable,
        ViewController
    {
        typealias Deps = HasGetSunTime & HasGetSchedule

        private typealias Snapshot = CollectionView.Snapshot
        private typealias Item = CollectionView.Item.Model
        typealias View = Days.View

        struct State: Equatable {
            struct Data: Equatable { let days: [NoonedDay: SunTime]; let legal: WKLegal }
            let sunTime: LoadState<Data>
            let yesterdaySchedule: Schedule?
            let todaySchedule: Schedule?
            let tomorrowSchedule: Schedule?

            enum LoadState<Data: Equatable>: Equatable {
                case loading
                case loaded (data: Data)
                case failed (error: String)
                case noData
            }
        }
        private(set) var state: State = .init(
            sunTime: .loading,
            yesterdaySchedule: nil,
            todaySchedule: nil,
            tomorrowSchedule: nil
        ) {
            didSet {
                DispatchQueue.main.async { [self] in
                    if state == oldValue {
                        log(.info, "Skipping equal state \(state)")
                        return
                    }
                    setState(state)
                }
            }
        }

        private let deps: Deps

        // MARK: - LifeCycle

        init(deps: Deps) {
            self.deps = deps
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func loadView() {
            self.view = View(
                cellProvider: { collection, indexPath, item in
                    guard let cell = collection.dequeueReusableCell(
                        withReuseIdentifier: String(describing: CollectionView.Item.self),
                        for: indexPath
                    ) as? CollectionView.Item else {
                        return nil
                    }
                    let preview = ContextPreview()
                    cell.contextViewController = preview
                    preview.setState(
                        ContextPreview.State(
                            image: { () -> UIImage? in
                                switch item.id.kind {
                                case .schedule:
                                    return UIImage(systemName: "calendar.circle.fill")
                                case .sun:
                                    return UIImage(systemName: "sun.and.horizon.circle.fill")
                                }
                            }(),
                            title: { () -> String in
                                switch item.id.kind {
                                case .schedule:
                                    return "Schedule for \(item.id.day.rawValue)"
                                case .sun:
                                    return "Sun cycle for \(item.id.day.rawValue)"
                                }
                            }(),
                            description: { () -> String in
                                switch item.id.kind {
                                case .schedule:
                                    if case let .showingContent(left, right) = item.state {
                                        return "Planned wake-up at \(left), bedtime at \(right)"
                                    } else {
                                        return ""
                                    }
                                case .sun:
                                    if case let .showingContent(left, right) = item.state {
                                        return "Sunrise at \(left), sunset at \(right)"
                                    } else {
                                        return ""
                                    }
                                }
                            }()
                        )
                    )
                    cell.configure(with: item)
                    cell.repeatButtonHandler = { [weak self] id in
                        self?.repeatButtonHandler(identifier: id)
                    }

                    return cell
                },
                sectionTitles: [
                    Text.yesterday,
                    Text.today,
                    Text.tomorrow
                ]
            )

            setState(state)
            
            DispatchQueue.main.async { [self] in
                rootView.centerItems()
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            refreshSchedule()
            refreshSunTimes(allowPermissionAlert: false)
        }

        func refreshSchedule() {
            state = state.changing {
                $0.yesterdaySchedule = deps.getSchedule.yesterday()
                $0.todaySchedule = deps.getSchedule.today()
                $0.tomorrowSchedule = deps.getSchedule.tomorrow()
            }
        }

        func setState(_ state: State) {
            guard let currentSnapshot = rootView.snapshot else {
                log(.error, "Skipping state \(state) because currentSnapshot is nil")
                return
            }

            var snapshot = Snapshot()
            snapshot.appendSections([.yesterday, .today, .tomorrow])
            snapshot.appendItems(
                makeItems(
                    for: state,
                    day: .yesterday,
                    snapshot: currentSnapshot
                ),
                toSection: .yesterday
            )
            snapshot.appendItems(
                makeItems(
                    for: state,
                    day: .today,
                    snapshot: currentSnapshot
                ),
                toSection: .today
            )
            snapshot.appendItems(
                makeItems(
                    for: state,
                    day: .tomorrow,
                    snapshot: currentSnapshot
                ),
                toSection: .tomorrow
            )

            rootView.applySnapshot(snapshot)

            if case let .loaded(data) = state.sunTime {
                rootView.applyLegal(data.legal)
            } else {
                rootView.applyLegal(nil)
            }
        }

        // MARK: - Actions

        private func repeatButtonHandler(identifier: Item.ID) {
            log(.info, "Repeat button pressed on cell: \(identifier)")
            guard identifier.kind == .sun else { return }
            state = state.changing {
                $0.sunTime = .loading
            }
            refreshSunTimes(allowPermissionAlert: true)
        }

        // MARK: - Refresh sun times

        private func refreshSunTimes(allowPermissionAlert: Bool = false) {
            state = state.changing { $0.sunTime = .loading }

            deps.getSunTime(
                numberOfDays: 3,
                since: NoonedDay.yesterday.date,
                permissionRequestProvider: { [weak self] openSettingsHandler in
                    if !allowPermissionAlert {
                        openSettingsHandler(false)
                        return
                    }
                    DispatchQueue.main.async {
                        self?.presentLocationPermissionAccessAlert { didOpenSettings in
                            openSettingsHandler(didOpenSettings)
                        }
                    }
                }
            ) { [weak self] result in
                guard let self = self else { return }
                if case .success (let data) = result {
                    self.state = self.state.changing {
                        $0.sunTime = .loaded(
                            data: .init(
                                days: Dictionary(
                                    uniqueKeysWithValues: zip(
                                        NoonedDay.allCases, data.0
                                    )
                                ),
                                legal: data.1
                            )
                        )
                    }
                }
                if case let .failure(error) = result {
                    self.state = self.state.changing {
                        $0.sunTime = .failed(
                            error: {
                                if error as? PermissionError == .locationAccessDenied {
                                    return Text.locationAccessMissing
                                } else {
                                    return Text.failedToLoadTime
                                }
                            }()
                        )
                    }
                }
            }
        }

        // MARK: - Make items

        private func transformScheduleItem(_ item: Item, applying state: State) -> Item {
            guard state.yesterdaySchedule != nil
                    || state.todaySchedule != nil
                    || state.tomorrowSchedule != nil else {
                return item.changing { $0.state = .showingInfo(info: Text.youDontHaveAScheduleYet) }
            }

            let schedule: Schedule? = {
                switch item.id.day {
                case .yesterday:
                    return state.yesterdaySchedule
                case .today:
                    return state.todaySchedule
                case .tomorrow:
                    return state.tomorrowSchedule
                }
            }()

            if let schedule = schedule {
                return item.changing {
                    $0.state = .showingContent(
                        left: schedule.wakeUp.HHmmString,
                        right: schedule.toBed.HHmmString
                    )
                }
            } else {
                return item.changing {
                    $0.state = .showingInfo(info: Text.noScheduleForTheDay)
                }
            }
        }

        private func transformSunTimeItem(_ item: Item, applying state: State.LoadState<Days.Controller.State.Data>) -> Item {
            switch state {
            case .loading:
                return item.changing { $0.state = .loading }
            case .loaded(let sunTimes):
                guard let sunTime = sunTimes.days[item.id.day] else { return item }
                return item.changing {
                    $0.state = .showingContent(
                        left: sunTime.sunrise.HHmmString,
                        right: sunTime.sunset.HHmmString
                    )
                }
            case .failed (let error):
                return item.changing { $0.state = .showingError(error: error) }
            case .noData:
                return item.changing { $0.state = .showingInfo(info: Text.timeNotFound) }
            }
        }

        private func transformItems(with state: State, items: [Item]) -> [Item] {
            return items.map { item in
                switch item.id.kind {
                case .schedule:
                    return self.transformScheduleItem(item, applying: state)
                case .sun:
                    return self.transformSunTimeItem(item, applying: state.sunTime)
                }
            }
        }

        private func makeItems(for state: State, day: NoonedDay, snapshot: Snapshot) -> [Item] {
            if snapshot.numberOfSections == 0 {
                return makeDefaultItems(for: day)
            } else {
                return transformItems(with: state, items: snapshot.itemIdentifiers(inSection: day))
            }
        }

        // MARK: - Default items -

        private func makeDefaultItems(for day: NoonedDay) -> [Item] {
            [ .init(
                state: .showingInfo(info: Text.youDontHaveAScheduleYet),
                image: (
                    left: Asset.wakeup.image,
                    right: Asset.fallasleep.image
                ),
                title: (
                    left: Text.wakeUp,
                    middle: Text.scheduledSleep,
                    right: Text.toBed
                ),
                id: Item.ID(kind: .schedule, day: day)
            ),
                .init(
                    state: .loading,
                    image: (
                        left: .init(
                            systemName: "sunrise.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)
                        ) ?? UIImage(),
                        right: .init(
                            systemName: "sunset.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)
                        ) ?? UIImage()
                    ),
                    title: (
                        left: Text.sunrise,
                        middle: Text.sunPosition,
                        right: Text.sunset
                    ),
                    id: Item.ID(kind: .sun, day: day)
                )
            ]
        }
    }
}

extension Days.Controller.State: Changeable {
    init(copy: ChangeableWrapper<Days.Controller.State>) {
        self.init(
            sunTime: copy.sunTime,
            yesterdaySchedule: copy.yesterdaySchedule,
            todaySchedule: copy.todaySchedule,
            tomorrowSchedule: copy.tomorrowSchedule
        )
    }
}

extension Days.CollectionCell.Model: Changeable {
    init(copy: ChangeableWrapper<Days.CollectionCell.Model>) {
        self.init(state: copy.state, image: copy.image, title: copy.title, id: copy.id)
    }
}

extension Days.Controller {
    enum NoonedDay: String, CaseIterable {
        case yesterday
        case today
        case tomorrow

        var date: Date {
            Date().addingTimeInterval(days: numberOfDaysFromToday).noon
        }

        private var numberOfDaysFromToday: Int {
            switch self {
            case .yesterday:
                return -1
            case .today:
                return 0
            case .tomorrow:
                return 1
            }
        }
    }
}
