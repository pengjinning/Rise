import DataLayer

public final class UseCaseLocator: UseCases {
  
  private let scheduleRepository: ScheduleRepository
  private let sunTimeRepository: SunTimeRepository
  private let locationRepository: LocationRepository
  private let userData: UserData
  
  public init(
    scheduleRepository: ScheduleRepository,
    sunTimeRepository: SunTimeRepository,
    locationRepository: LocationRepository,
    userData: UserData
  ) {
    self.scheduleRepository = scheduleRepository
    self.sunTimeRepository = sunTimeRepository
    self.locationRepository = locationRepository
    self.userData = userData
  }
  
  public var createSchedule: CreateSchedule {
    CreateScheduleImpl()
  }
  
  public var updateSchedule: UpdateSchedule {
    UpdateScheduleImpl(createSchedule, scheduleRepository)
  }
  
  public var deleteSchedule: DeleteSchedule {
    DeleteScheduleImpl(scheduleRepository, userData)
  }
  
  public var getSunTime: GetSunTime {
    GetSunTimeImpl(locationRepository, sunTimeRepository)
  }
  
  public var refreshSunTime: RefreshSunTime {
    RefreshSunTimeImpl(locationRepository, sunTimeRepository)
  }
  
  public var manageOnboardingCompleted: ManageOnboardingCompleted {
    ManageOnboardingCompletedImpl(userData)
  }
  
  public var adjustSchedule: AdjustSchedule {
    AdjustScheduleImpl(scheduleRepository, userData)
  }
  
  public var getSchedule: GetSchedule {
    GetScheduleImpl(scheduleRepository, createNextSchedule)
  }
  
  public var pauseSchedule: PauseSchedule {
    PauseScheduleImpl(userData)
  }
  
  public var manageActiveSleep: ManageActiveSleep {
    ManageActiveSleepImpl(userData)
  }
  
  public var suggestKeepAppOpened: SuggestKeepAppOpened {
    SuggestKeepAppOpenedImpl(userData)
  }
  
  public var preferredWakeUpTime: PreferredWakeUpTime {
    PreferredWakeUpTimeImpl(userData)
  }
  
  public var preventAppSleep: PreventAppSleep {
    PreventAppSleepImpl()
  }
  
  public var changeScreenBrightness: ChangeScreenBrightness {
    ChangeScreenBrightnessImpl()
  }
  
  public var prepareMail: PrepareMail {
    PrepareMailImpl()
  }
  
  public var getAppVersion: GetAppVersion {
    GetAppVersionImpl()
  }
  
  public var createNextSchedule: CreateNextSchedule {
    CreateNextScheduleImpl(userData)
  }
  
  public var saveSchedule: SaveSchedule {
    SaveScheduleImpl(scheduleRepository)
  }
}