//
//  DefaultUserData.swift
//  Rise
//
//  Created by Vladimir Korolev on 11.09.2021.
//  Copyright © 2021 VladimirBrejcha. All rights reserved.
//

import Foundation

final class DefaultUserData: UserData {
    @NonNilUserDefault("onboarding_completed", defaultValue: false)
    var onboardingCompleted: Bool

    @NonNilUserDefault("schedule_on_pause", defaultValue: false)
    var scheduleOnPause: Bool

    @UserDefault("latest_app_usage_date")
    var latestAppUsageDate: Date?

    @UserDefault<Date>("preferred_wakeup_time")
    var preferredWakeUpTime: Date?
    
    @NonNilUserDefault("keep_app_opened_suggested", defaultValue: false)
    var keepAppOpenedSuggested: Bool
}
