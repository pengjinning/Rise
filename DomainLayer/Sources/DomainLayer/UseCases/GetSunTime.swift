import Foundation
import Core
import DataLayer

public protocol HasGetSunTime {
  var getSunTime: GetSunTime { get }
}

public typealias GetSunTimeCompletion = (Result<[SunTime], Error>) -> Void

public protocol GetSunTime {
  func callAsFunction(
    numberOfDays: Int,
    since date: Date,
    completionQueue: DispatchQueue?,
    permissionRequestProvider: @escaping (@escaping (Bool) -> Void) -> Void,
    completion: @escaping GetSunTimeCompletion
  )
}

final class GetSunTimeImpl: GetSunTime {
  private let locationRepository: LocationRepository
  private let sunTimeRepository: SunTimeRepository
  private let queue = DispatchQueue(label: String(describing: GetSunTimeImpl.self))
  private var completionQueue: DispatchQueue?

  init(_ locationRepository: LocationRepository, _ sunTimeRepository: SunTimeRepository) {
    self.locationRepository = locationRepository
    self.sunTimeRepository = sunTimeRepository
  }

  func callAsFunction(
    numberOfDays: Int,
    since date: Date,
    completionQueue: DispatchQueue? = nil,
    permissionRequestProvider: @escaping (@escaping (Bool) -> Void) -> Void,
    completion: @escaping GetSunTimeCompletion
  ) {
    let dates = makeDates(since: date, numberOfDays: numberOfDays)
    queue.async { [weak self] in
      self?.completionQueue = completionQueue
      self?.locationRepository.get(
        permissionRequestProvider: permissionRequestProvider
      ) { [weak self] result in
        if case .success (let location) = result {
          self?.getSunTimes(dates: dates, location: location, completion: completion)
        }
        if case .failure (let error) = result {
          self?.resolveCompletion(completion, with: .failure(error))
        }
      }
    }
  }

  private func getSunTimes(
    dates: [Date],
    location: Location,
    completion: @escaping GetSunTimeCompletion
  ) {
    sunTimeRepository.requestSunTimes(
      dates: dates,
      location: location,
      completion: { [weak self] result in
        if case .success (let sunTimes) = result {
          self?.resolveCompletion(
            completion,
            with: .success(
              sunTimes.sorted { $0.sunrise < $1.sunrise }
            )
          )
        }
        if case .failure (let error) = result {
          self?.resolveCompletion(completion, with: .failure(error))
        }
      }
    )
  }

  private func resolveCompletion(
    _ completion: @escaping GetSunTimeCompletion,
    with result: Result<[SunTime], Error>
  ) {
    if let queue = completionQueue {
      queue.async {
        completion(result)
      }
    } else {
      completion(result)
    }
  }

  private func makeDates(since date: Date, numberOfDays: Int) -> [Date] {
    guard numberOfDays > 0 else { return [] }
    return (0...numberOfDays - 1).map {
      date.addingTimeInterval(days: $0)
    }
  }
}
