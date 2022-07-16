import Foundation

public struct Schedule: Equatable {

  public let sleepDuration: Int
  public let intensity: Intensity
  public let toBed: Date
  public let wakeUp: Date
  public let targetToBed: Date
  public let targetWakeUp: Date

  public init(
    sleepDuration: Int,
    intensity: Schedule.Intensity,
    toBed: Date,
    wakeUp: Date,
    targetToBed: Date,
    targetWakeUp: Date
  ) {
    self.sleepDuration = sleepDuration
    self.intensity = intensity
    self.toBed = toBed
    self.wakeUp = wakeUp
    self.targetToBed = targetToBed
    self.targetWakeUp = targetWakeUp
  }
}

public extension Schedule {

  enum Intensity: Int16 {
    case low = 0
    case normal = 1
    case high = 2

    public var description: String {
      switch self {
      case .low:
        return "Low"
      case .normal:
        return "Normal"
      case .high:
        return "High"
      }
    }

    public var index: Int { Int(rawValue) }
  }
}