//
//  SetupPlanPresenter.swift
//  Rise
//
//  Created by Владимир Королев on 29/09/2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

struct DataForPicker { // TODO: - Picker input and output need refactoring
    static let daysArray = ["Hardcore - 10 days", "Normal - 15 days", "Recommended - 30 days", "Calm - 50 days"]
    static let hoursArray = ["7 hours", "7.5 hours", "Recommended - 8 hours", "8.5 hours", "9 hours"]
    
    private init() { }
}

class SetupPlanPresenter: SetupPlanViewOutput, SectionedTableViewCellDelegate {
    weak var view: SetupPlanViewInput!
    
    private let savePersonalPlanUseCase: SavePersonalPlanUseCase = sharedUseCaseManager
    
    private var dataSource: SectionedTableViewDataSource!
    private let datePickerModel = PickerDataModel(tag: 0, headerText: "What time do you wish to wake up?",
                                                  labelText: "Choose time", type: .datePicker)
    private let hoursPickerModel = PickerDataModel(tag: 1, headerText: "How long do you wish to sleep?",
                                                   labelText: "Choose hours", type: .pickerView,
                                                   titleForRowArray: DataForPicker.hoursArray, defaultRow: 2)
    private let secondDatePickerModel = PickerDataModel(tag: 2, headerText: "When did you fall asleep yesterday?",
                                                        labelText: "Choose time", type: .datePicker)
    private let durationPickerModel = PickerDataModel(tag: 3, headerText: "Duration", labelText: "Choose duration",
                                                      type: .pickerView,
                                                      titleForRowArray: DataForPicker.daysArray, defaultRow: 2)
    
    private var wakeUpForModel: Date?
    private var sleepDurationForModel: String?
    private var lastTimeWentSleepForModel: Date?
    private var planDurationForModel: String?
    
    init(view: SetupPlanViewInput) { self.view = view }
    
    // MARK: - SetupPlanViewOutput
    func viewDidLoad() {

    }
    
    func viewWillAppear() {
        dataSource = SectionedTableViewDataSource(dataSources:
            [TableViewDataSource.make(for: [datePickerModel], output: self),
             TableViewDataSource.make(for: [hoursPickerModel], output: self),
             TableViewDataSource.make(for: [secondDatePickerModel], output: self),
             TableViewDataSource.make(for: [durationPickerModel], output: self)])
//        view?.configureTableView(with: dataSource)
    }
    
    func schedulePressed() {
        view.endStory()
    }
    
    // MARK: - ExpandingCellDelegate
    func cellValueUpdated(with value: PickerOutputValue, cell: SectionedTableViewCell) {
        switch cell.tag
        {
        case 0: wakeUpForModel = value.dateValue
        case 1: sleepDurationForModel = value.stringValue
        case 2: lastTimeWentSleepForModel = value.dateValue
        case 3: planDurationForModel = value.stringValue
        default: fatalError("cell with this tag doesnt exist")
        }
        
        guard let wakeUp = wakeUpForModel,
            let sleepDuration = sleepDurationForModel,
            let wentSleep = lastTimeWentSleepForModel,
            let planDuration = planDurationForModel else { return }
        
//        view?.enableScheduleButton(true)
        
        let personalPlan = PersonalPlanConfigurator.configure(wakeUpTime: wakeUp, sleepDuration: sleepDuration,
                                                              planDuration: planDuration, wentSleepTime: wentSleep)
        savePersonalPlanUseCase.save(plan: personalPlan)
    }
}