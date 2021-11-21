//
//  DefaultLocationRemoteDataSource.swift
//  Rise
//
//  Created by Vladimir Korolev on 10.11.2019.
//  Copyright © 2019-2020 VladimirBrejcha. All rights reserved.
//

import CoreLocation

protocol LocationRemoteDataSource {
    func get(_ completion: @escaping (Result<Location, Error>) -> Void)
    func requestPermissions(
        permissionRequestProvider: @escaping (@escaping (Bool) -> Void) -> Void,
        _ completion: @escaping (Bool) -> Void
    )
}

final class DefaultLocationRemoteDataSource:
    NSObject,
    CLLocationManagerDelegate,
    LocationRemoteDataSource
{
    private let locationManager = CLLocationManager()
    private var requestPermissionsCompletion: ((Bool) -> Void)?
    private var requestLocationCompletion: ((Result<Location, Error>) -> Void)?
    private var permissionRequestProvider: (() -> Void)?
    @UserDefault("authorization_status")
    private var authorizationStatusStorage: Int32?
    private var authorizationStatus: CLAuthorizationStatus? {
        get {
            if let status = authorizationStatusStorage {
                return .init(rawValue: status)
            }
            return nil
        }
        set {
            authorizationStatusStorage = newValue?.rawValue
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func get(_ completion: @escaping (Result<Location, Error>) -> Void) {
        log(.info)
        requestLocationCompletion = completion
        locationManager.requestLocation()
    }
    
    func requestPermissions(
        permissionRequestProvider: @escaping (@escaping (Bool) -> Void) -> Void,
        _ completion: @escaping (Bool) -> Void
    ) {
        log(.info, "current status = \(String(describing: authorizationStatus?.rawValue))")
        if authorizationStatus == nil {
            requestPermissionsCompletion = completion
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .notDetermined
                    || authorizationStatus == .denied
                    || authorizationStatus == .restricted {
            requestPermissionsCompletion = completion
            permissionRequestProvider { [weak self] proceedToSettings in
                if !proceedToSettings {
                    self?.requestPermissionsCompletion?(false)
                    self?.requestPermissionsCompletion = nil
                }
            }
        } else {
            completion(true)
        }
    }
    
    //MARK: - CLLocationManagerDelegate -

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log(.info)
        guard let completion = requestLocationCompletion else { return }
        
        if let newLocation = locations.last {
            completion(
                .success(
                    Location(
                        latitude: newLocation.coordinate.latitude.description,
                        longitude: newLocation.coordinate.longitude.description)
                )
            )
        } else {
            completion(.failure(NetworkError.noDataReceived))
        }
        requestLocationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log(.error, error.localizedDescription)
        requestPermissionsCompletion?(false)
        requestPermissionsCompletion = nil
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        log(.info, "status = \(status.rawValue)")
        authorizationStatus = status

        guard let completion = requestPermissionsCompletion else { return }

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            completion(true)
        default:
            completion(false)
        }
        requestPermissionsCompletion = nil
    }
}
