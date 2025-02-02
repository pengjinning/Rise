import Foundation
import DataLayer
import Core

public protocol HasCreateNextSchedule {
  var createNextSchedule: CreateNextSchedule { get }
}

/*
 * Creates schedule for the next day
 *
 * Returns the same schedule if `targetToBed` already reached
 */
public protocol CreateNextSchedule {
  func callAsFunction(from schedule: Schedule) -> Schedule
}

final class CreateNextScheduleImpl: CreateNextSchedule {

  private let userData: UserData

  init(_ userData: UserData) {
    self.userData = userData
  }

  func callAsFunction(from schedule: Schedule) -> Schedule {
    if userData.scheduleOnPause {
      return .init(
        sleepDuration: schedule.sleepDuration,
        intensity: schedule.intensity,
        toBed: incrementDay(old: schedule.toBed),
        wakeUp: incrementDay(old: schedule.wakeUp),
        targetToBed: incrementDay(old: schedule.targetToBed),
        targetWakeUp: incrementDay(old: schedule.targetWakeUp)
      )
    }

    let nextToBed = calculateNextToBed(
      current: schedule.toBed,
      target: schedule.targetToBed,
      intensity: schedule.intensity
    )
    return .init(
      sleepDuration: schedule.sleepDuration,
      intensity: schedule.intensity,
      toBed: incrementDay(
        old: nextToBed
      ),
      wakeUp: calculateNextWakeUp(
        currentToBed: nextToBed,
        sleepDuration: schedule.sleepDuration
      ),
      targetToBed: incrementDay(
        old: schedule.targetToBed
      ),
      targetWakeUp: incrementDay(
        old: schedule.targetWakeUp
      )
    )
  }

  private func calculateNextWakeUp(
    currentToBed: Date,
    sleepDuration: Int
  ) -> Date {
    currentToBed
      .addingTimeInterval(minutes: sleepDuration)
  }

  private func calculateNextToBed(
    current: Date,
    target: Date,
    intensity: Schedule.Intensity
  ) -> Date {
    var timeShift = selectTimeShift(
      total: calculateDiff(
        current: current,
        target: target
      ),
      intensity: intensity
    )

    // handle both directions of time shifting
    if current > target {
      timeShift = -timeShift
    }

    let nextToBed = createNewCurrentToBed(
      old: current,
      timeShift: timeShift
    )

    // prevent overlapping
    if (current > target && target > nextToBed)
        || (current < target && target < nextToBed) {
      return target
    }

    return nextToBed
  }

  private func calculateDiff(
    current: Date,
    target: Date
  ) -> Int {
    .init(
      timeInterval: abs(
        current.timeIntervalSince1970 - target.timeIntervalSince1970
      )
    )
  }

  private func selectTimeShift(
    total: Int,
    intensity: Schedule.Intensity
  ) -> Int {
    if total <= 0 { return 0 }
    let shift = total / intensity.divider
    return max(shift, intensity.minTimeShift)
  }

  private func createNewCurrentToBed(
    old: Date,
    timeShift: Int
  ) -> Date {
    old.addingTimeInterval(minutes: timeShift)
  }

  private func incrementDay(old: Date) -> Date {
    old.addingTimeInterval(days: 1)
  }
}

extension Schedule.Intensity {
  var divider: Int {
    switch self {
    case .low:
      return 40
    case .normal:
      return 25
    case .high:
      return 10
    }
  }

  var minTimeShift: Int {
    switch self {
    case .low:
      return 3
    case .normal:
      return 6
    case .high:
      return 9
    }
  }
}

fileprivate extension Int {
  init(timeInterval: TimeInterval) {
    self = Int(timeInterval) / 60
  }
}
