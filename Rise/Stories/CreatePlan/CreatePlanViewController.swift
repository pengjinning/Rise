//
//  CreatePlanViewController.swift
//  Rise
//
//  Created by Vladimir Korolev on 25/05/2019.
//  Copyright © 2019-2020 VladimirBrejcha. All rights reserved.
//

import UIKit

final class CreatePlanViewController:
    UIViewController,
    UIAdaptivePresentationControllerDelegate
{
    @IBOutlet private var createPlanView: CreatePlanView!
    
    private var pageController: UIPageViewController!
    
    var makePlan: MakePlan! // DI
    var stories: [Story]! // DI
    
    private var choosenSleepDuration: Int?
    private var choosenWakeUpTime: Date?
    private var choosenPlanDuration: Int?
    private var choosenLastTimeWentSleep: Date?
    private var planGenerated = false
    
    private var currentPage = 0
    private var currentStory: Story { stories[currentPage] }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPlanView.setBackground(
            GradientHelper.makeDefaultStaticGradient(for: view.bounds)
        )
        createPlanView.model = CreatePlanView.Model(
            backButtonTitle: "",
            nextButtonTitle: "Start",
            closeHandler: { [weak self] in
                self?.dismiss()
            },
            backHandler: { [weak self] in
                guard let self = self else { return }
                if self.stories.indices.contains(self.currentPage - 1) {
                    self.currentPage -= 1
                    self.updateButtons(story: self.currentStory)
                    self.show(views: [self.currentStory.configure()], forwardDirection: false)
                }
            },
            nextHandler: { [weak self] in
                guard let self = self else { return }
                if case .planCreatedSetupPlan = self.currentStory {
                    self.dismiss()
                    return
                }
                
                if case .wentSleepCreatePlan = self.currentStory {
                    if !self.planGenerated {
                        self.planGenerated = self.generatePlan()
                    }
                }
                
                if self.stories.indices.contains(self.currentPage + 1) {
                    self.currentPage += 1
                    self.show(views: [self.currentStory.configure()], forwardDirection: true)
                    self.updateButtons(story: self.currentStory)
                }
            }
        )
        updateButtons(story: currentStory)
        show(views: [currentStory.configure()], forwardDirection: true)
        
        presentationController?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageController = segue.destination as? UIPageViewController {
            self.pageController = pageController
        }
    }
    
    // opened for DI into PageController controllers
    func sleepDurationValueChanged(_ value: Int) {
        choosenSleepDuration = value
        updateButtons(story: currentStory)
    }
    
    func wakeUpTimeValueChanged(_ value: Date) {
        choosenWakeUpTime = value
        updateButtons(story: currentStory)
    }
    
    func planDurationValueChanged(_ value: Int) {
        choosenPlanDuration = value
        updateButtons(story: currentStory)
    }
    
    func lastTimeWentSleepValueChanged(_ value: Date) {
        choosenLastTimeWentSleep = value
        updateButtons(story: currentStory)
    }
    //
    
    func show(views: [UIViewController], forwardDirection: Bool) {
        pageController.setViewControllers(
            views,
            direction: forwardDirection ? .forward : .reverse,
            animated: true, completion: nil
        )
    }
    
    // MARK: - UIAdaptivePresentationControllerDelegate -
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        false
    }
    
    // MARK: - Private -
    private func dismiss() {
        dismiss(animated: true)
    }
    
    private func updateButtons(story: Story) {
        switch story {
        case .welcomeCreatePlan:
            createPlanView.state = CreatePlanView.State(
                nextButtonEnabled: true,
                backButtonHidden: true
            )
            createPlanView.model = createPlanView.model?.changing{ model in
                model.backButtonTitle = ""
                model.nextButtonTitle = "Start"
            }
        case .sleepDurationCreatePlan:
            createPlanView.state = CreatePlanView.State(
                nextButtonEnabled: choosenSleepDuration != nil,
                backButtonHidden: true
            )
            createPlanView.model = createPlanView.model?.changing{ model in
                model.backButtonTitle = ""
                model.nextButtonTitle = "Next"
            }
        case .wakeUpTimeCreatePlan:
            createPlanView.state = CreatePlanView.State(
                nextButtonEnabled: choosenWakeUpTime != nil,
                backButtonHidden: false
            )
            createPlanView.model = createPlanView.model?.changing{ model in
                model.backButtonTitle = "Previous"
                model.nextButtonTitle = "Next"
            }
        case .planDurationCreatePlan:
            createPlanView.state = CreatePlanView.State(
                nextButtonEnabled: choosenPlanDuration != nil,
                backButtonHidden: false
            )
            createPlanView.model = createPlanView.model?.changing{ model in
                model.backButtonTitle = "Previous"
                model.nextButtonTitle = "Next"
            }
        case .wentSleepCreatePlan:
            createPlanView.state = CreatePlanView.State(
                nextButtonEnabled: choosenLastTimeWentSleep != nil,
                backButtonHidden: false
            )
            createPlanView.model = createPlanView.model?.changing{ model in
                model.backButtonTitle = "Previous"
                model.nextButtonTitle = "Create"
            }
        case .planCreatedSetupPlan:
            createPlanView.state = CreatePlanView.State(
                nextButtonEnabled: true,
                backButtonHidden: true
            )
            createPlanView.model = createPlanView.model?.changing{ model in
                model.backButtonTitle = ""
                model.nextButtonTitle = "Great!"
            }
        default:
            break
        }
    }
    
    private func generatePlan() -> Bool {
        guard let choosenSleepDuration = choosenSleepDuration,
            let choosenWakeUpTime = choosenWakeUpTime,
            let choosenPlanDuration = choosenPlanDuration,
            let choosenLastTimeWentSleep = choosenLastTimeWentSleep
            else {
                return false
        }
        
        do {
            try makePlan.execute(sleepDurationMin: choosenSleepDuration,
                                 wakeUpTime: choosenWakeUpTime,
                                 planDurationDays: choosenPlanDuration,
                                 firstSleepTime: choosenLastTimeWentSleep)
            return true
        } catch {
            // todo handle error
            return false
        }
    }
}

