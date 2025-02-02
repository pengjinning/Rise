import Foundation
import Core
import Combine

final class ScheduleRepositoryImpl: ScheduleRepository {

    private let localDataSource: ScheduleLocalDataSource

    init(_ localDataSource: ScheduleLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func publisher() -> AnyPublisher
    <([(LocalDataSourceObjectChange, Schedule)]), Never>
    {
        localDataSource.publisher(for: ScheduleObject.self)
            .map { (changes: [(LocalDataSourceObjectChange, ScheduleObject)]) -> [(LocalDataSourceObjectChange, Schedule)] in
                return changes.compactMap {
                    guard let schedule = Schedule.init(object: $1)
                    else { return nil }
                    return ($0, schedule)
                }
            }
            .eraseToAnyPublisher()
    }

    func get(for date: Date) -> Schedule? {
        log(.info, "date: \(date)")

        do {
            return try localDataSource.get(for: date)
        } catch ScheduleLocalDataSourceError.noScheduleForTheDate {
            return nil
        } catch ScheduleLocalDataSourceError.failedToRecreateSchedule {
            log(.error, "failedToRecreateSchedule")
            do {
                try localDataSource.delete(for: date)
            } catch (let error) {
                assertionFailure(error.localizedDescription)
                log(.error, "deleting error: \(error.localizedDescription)")
            }
            return nil
        } catch (let error) {
            assertionFailure(error.localizedDescription)
            log(.error, "error: \(error.localizedDescription)")
            return nil
        }
    }

    func getLatest() -> Schedule? {
        log(.info)

        do {
            return try localDataSource.getLatest()
        } catch ScheduleLocalDataSourceError.noScheduleForTheDate {
            return nil
        } catch ScheduleLocalDataSourceError.failedToRecreateSchedule {
            log(.error, "failedToRecreateSchedule")
            do {
                try localDataSource.deleteLatest()
            } catch (let error) {
                assertionFailure(error.localizedDescription)
                log(.error, "deleting error: \(error.localizedDescription)")
            }
            return nil
        } catch (let error) {
            assertionFailure(error.localizedDescription)
            log(.error, "error: \(error.localizedDescription)")
            return nil
        }
    }

    func save(_ schedule: Schedule) {
        log(.info, "schedule: \(schedule)")

        do {
            try localDataSource.save(schedule)
        } catch (let error) {
            assertionFailure(error.localizedDescription)
            log(.error, "saving error: \(error.localizedDescription)")
        }
    }

    func delete(for date: Date) {
        log(.info, "date: \(date)")

        do {
            try localDataSource.delete(for: date)
        } catch (let error) {
            assertionFailure(error.localizedDescription)
            log(.error, "deleting error: \(error.localizedDescription)")
        }
    }

    func deleteAll() {
        log(.info)

        do {
            try localDataSource.deleteAll()
        } catch (let error) {
            assertionFailure(error.localizedDescription)
            log(.error, "deleting error: \(error.localizedDescription)")
        }
    }
}
