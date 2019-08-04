//
//  WeatherCitySearchViewController.swift
//  WeatherApp
//
//  Created by MinKyeongTae on 03/08/2019.
//  Copyright © 2019 MinKyeongTae. All rights reserved.
//

import CoreLocation
import UIKit

class WeatherCitySearchViewController: UIViewController {
    let locationManager = CLLocationManager()

    // MARK: - UI

    let weatherCitySearchView: WeatherCitySearchView = {
        let weatherCitySearchView = WeatherCitySearchView()
        return weatherCitySearchView
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setCitySearchViewController()
        setButtonTarget()
    }

    override func loadView() {
        super.loadView()
        view = weatherCitySearchView
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        weatherCitySearchView.citySearchBar.becomeFirstResponder()
        requestLocationAuthority()
    }

    // MARK: - Set Method

    func setButtonTarget() {
        weatherCitySearchView.backToMainButton.addTarget(self, action: #selector(backToMainButtonPressed(_:)), for: .touchUpInside)
    }

    // MARK: Set Location Method

    func requestLocationAuthority() {
        // 현재 위치권한이 있는지 유무를 확인한다.
        let locationAuthStatus = CLLocationManager.authorizationStatus()
        switch locationAuthStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways: WeatherCommonData.shared.setLocationAuthData(isAuth: true)
        case .authorizedWhenInUse: WeatherCommonData.shared.setLocationAuthData(isAuth: true)
        default:
            presentLocationAuthAlertController()
        }
    }

    func setCitySearchViewController() {
        view.backgroundColor = .black
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func presentLocationAuthAlertController() {
        guard let appSettingURL = URL(string: UIApplication.openSettingsURLString) else { return }

        let authAlertController = UIAlertController(title: "위치 권한 요청", message: "날씨정보를 받기 위해 위치권한이 필요합니다. 위치권한을 설정하시겠습니까?", preferredStyle: .alert)
        let goToAuthSettingAlertAction = UIAlertAction(title: "네 알겠습니다.", style: .default) { _ in
            UIApplication.shared.open(appSettingURL, options: [:], completionHandler: nil)
        }
        let cancelAlertAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
        authAlertController.addAction(goToAuthSettingAlertAction)
        authAlertController.addAction(cancelAlertAction)
        present(authAlertController, animated: true, completion: nil)
    }

    // MARK: - Button Event

    @objc func backToMainButtonPressed(_: UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - CLLocationManager Protocol

extension WeatherCitySearchViewController: CLLocationManagerDelegate {
    /// * **위치가 업데이트 될 때마다 실행 되는 델리게이트 메서드**
    func locationManager(_ manager: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        if let nowCoordinate = manager.location?.coordinate {
            //  print("latitude: \(nowCoordinate.latitude), longitude: \(nowCoordinate.longitude)" )
        }
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        let locationAuthStatus = CLLocationManager.authorizationStatus()
        switch locationAuthStatus {
        case .authorizedAlways: WeatherCommonData.shared.setLocationAuthData(isAuth: true)
        case .authorizedWhenInUse: WeatherCommonData.shared.setLocationAuthData(isAuth: true)
        default:
            break
        }
    }
}
