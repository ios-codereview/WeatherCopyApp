//
//  ViewController.swift
//  WeatherApp
//
//  Created by MinKyeongTae on 31/07/2019.
//  Copyright © 2019 MinKyeongTae. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class WeatherDetailViewController: UIViewController {
    // MARK: - Property

    let locationManager = CLLocationManager()
    var isAppearViewController = false

    // MARK: - UI

    /// WeatherPageViewController
    /// * 설정한 지역 별 날씨정보를 보여준다.
    // Review: [Refactoring] optional 인 이유는 뭘까요...? ㅠㅠ
    var weatherPageViewController: UIPageViewController?

    lazy var weatherCityListViewController: WeatherCityListViewController = {
        let weatherCityListViewController = WeatherCityListViewController()
        return weatherCityListViewController
    }()

    let weatherPageControl: UIPageControl = {
        let weatherPageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY, width: UIScreen.main.bounds.width, height: 50))
        weatherPageControl.numberOfPages = 1 + CommonData.shared.weatherDataList.count
        weatherPageControl.hidesForSinglePage = false
        weatherPageControl.currentPage = 0
        weatherPageControl.tintColor = .black
        weatherPageControl.pageIndicatorTintColor = .black
        weatherPageControl.currentPageIndicatorTintColor = .blue
        return weatherPageControl
    }()

    let linkBarButton: UIButton = {
        let linkBarButton = UIButton(type: .custom)
        linkBarButton.setImage(UIImage(named: AssetIdentifier.Image.weatherLink), for: .normal)
        return linkBarButton
    }()

    let listBarButton: UIButton = {
        let listBarButton = UIButton(type: .custom)
        listBarButton.setImage(UIImage(named: AssetIdentifier.Image.weatherList), for: .normal)
        return listBarButton
    }()

    let weatherDetailView: WeatherDetailView = {
        let weatherDetailView = WeatherDetailView()
        return weatherDetailView
    }()

    // MARK: - Life Cycle

    override func loadView() {
        view = weatherDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ** 날씨데이터 저장 방식 **
        CommonData.shared.initWeatherDataListSize() // 맨 처음 메인데이터가 들어갈 크기를 공간 설정하고,
        CommonData.shared.setUserDefaultsData() // 저장 된 서브 날씨데이터를 추가한다.

        makeSubviews()
        setDetailViewController()
        setButtonTarget()
        setToolBarButtonItem()
        makeConstraints()
        presentToCityListView()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        // 페이지뷰 컨트롤러 갱신
        setWeatherPageViewController()
    }

    // MARK: - Set Method

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setWeatherPageViewController() {
        let mainPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        mainPageViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        weatherPageViewController = mainPageViewController

        // 뷰 컨트롤러 하나만 먼저 준비, 데이터소스에서 나머지 컨텐츠 뷰 컨트롤러를 설정한다.
        guard let contentViewController = makeContentViewController(index: CommonData.shared.selectedMainCellIndex) else { return }

        let unWrappingPageViewController = weatherPageViewController

        unWrappingPageViewController?.setViewControllers([contentViewController], direction: .reverse, animated: true, completion: nil)

        mainPageViewController.view.addSubview(linkBarButton)
        // Review: [Refactoring] ViewController Event를 좀더 구체적으로 하는건 어떨까요?
        /*
        to.willMove(toParent: self)
        addChild(to)
        from.willMove(toParent: nil)
        to.didMove(toParent: self)
        from.removeFromParent()
        from.didMove(toParent: nil)
        */
        view.addSubview(mainPageViewController.view)
        addChild(mainPageViewController)
        mainPageViewController.didMove(toParent: self)
        mainPageViewController.delegate = self
        mainPageViewController.dataSource = self
        mainPageViewController.view.backgroundColor = .black
    }

    func setPageControl() {}

    func makeContentViewController(index: Int) -> WeatherDetailContentViewController? {
        let contentViewController = WeatherDetailContentViewController()
        if index >= CommonData.shared.weatherDataList.count {
            contentViewController.pageViewControllerIndex = CommonData.shared.selectedMainCellIndex
        } else {
            contentViewController.pageViewControllerIndex = index
        }

        contentViewController.setWeatherData()
        // Review: [성능] layoutIfNeeded 는 신중히 사용하셔야 합니다.
        // https://miro.medium.com/max/1218/1*qRxIjIzHomLae-tmI0QXgQ.png
        // 위 그림 과정을 전체 수행합니다
        contentViewController.weatherDetailContentView.weatherDetailTitleView.layoutIfNeeded()
        return contentViewController
    }

    func setDetailViewController() {
        view.backgroundColor = CommonColor.weatherDetailView
        setWeatherPageViewController()
    }

    func setButtonTarget() {
        linkBarButton.addTarget(self, action: #selector(linkButtonPressed(_:)), for: .touchUpInside)
        listBarButton.addTarget(self, action: #selector(listButtonPressed(_:)), for: .touchUpInside)
    }

    func setToolBarButtonItem() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let barButtonItem = UIBarButtonItem(customView: linkBarButton)
        let barButtonItem3 = UIBarButtonItem(customView: listBarButton)
        let toolBarItems = [barButtonItem, flexibleSpace, flexibleSpace, flexibleSpace, barButtonItem3]
        toolbarItems = toolBarItems
        navigationController?.setToolbarHidden(false, animated: false)
        hidesBottomBarWhenPushed = false
    }

    func makeWeatherInfoTableHeaderViewScrollEvent(_ scrollView: UIScrollView, offsetY _: CGFloat) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset.y = CGFloat.zero
        }

        let height = CGFloat(max(0, WeatherCellHeight.detailTableHeaderCell - max(0, scrollView.contentOffset.y)))
        let alphaValue = pow(height / WeatherCellHeight.detailTableHeaderCell, 10)
        weatherDetailView.weatherDetailTableHeaderView.setTableHeaderViewAlpha(alpha: CGFloat(alphaValue))
    }

    func makeLinkBarButtonConstraint() {
        linkBarButton.activateAnchors()
        NSLayoutConstraint.activate([
            linkBarButton.heightAnchor.constraint(equalToConstant: CommonSize.defaultButtonSize.height),
            linkBarButton.widthAnchor.constraint(equalTo: linkBarButton.heightAnchor, multiplier: 1.0),
        ])
    }

    func makeListBarButtonConstraint() {
        listBarButton.activateAnchors()
        NSLayoutConstraint.activate([
            listBarButton.heightAnchor.constraint(equalToConstant: CommonSize.defaultButtonSize.height),
            listBarButton.widthAnchor.constraint(equalTo: listBarButton.heightAnchor, multiplier: 1.0),
        ])
    }

    // MARK: Check Event

    func presentToCityListView() {
        present(weatherCityListViewController, animated: true)
    }

    // MARK: - Button Event

    @objc func linkButtonPressed(_: UIButton) {
        // ✭ URL 링크주소는 파싱구현 이후 다시 수정한다.
        let latitude = CommonData.shared.mainCoordinate.latitude
        let longitude = CommonData.shared.mainCoordinate.longitude
        CommonData.shared.openWeatherURL(latitude: latitude, longitude: longitude)
    }

    @objc func listButtonPressed(_: UIButton) {
        present(weatherCityListViewController, animated: true, completion: nil)
    }
}

// MARK: - PageView Protocol

extension WeatherDetailViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted completed: Bool) {
        if completed {}
    }
}

extension WeatherDetailViewController: UIPageViewControllerDataSource {
    // 이전으로 넘길때 컨텐츠 뷰 컨트롤러 데이터 전달
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let targetViewController = viewController as? WeatherDetailContentViewController else { return nil }
        let previousIndex = targetViewController.pageViewControllerIndex

        if previousIndex == 0 {
            return nil
        } else {
            CommonData.shared.setSelectedMainCellIndex(index: previousIndex - 1)
            return makeContentViewController(index: previousIndex - 1)
        }
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let targetViewController = viewController as? WeatherDetailContentViewController else { return nil }

        let contentViewControllerMaxIndex = CommonData.shared.weatherDataList.count - 1
        let nextIndex = targetViewController.pageViewControllerIndex

        if nextIndex == contentViewControllerMaxIndex {
            return nil
        } else {
            CommonData.shared.setSelectedMainCellIndex(index: nextIndex + 1)
            return makeContentViewController(index: nextIndex + 1)
        }
    }

    func presentationCount(for _: UIPageViewController) -> Int {
        return CommonData.shared.weatherDataList.count
    }

    // 인디케이터의 초기 값
    func presentationIndex(for _: UIPageViewController) -> Int {
        return CommonData.shared.selectedMainCellIndex
    }
}

// MARK: - Custom View Protocol

extension WeatherDetailViewController: UIViewSettingProtocol {
    func makeSubviews() {
        view.addSubview(weatherPageControl)
    }

    func makeConstraints() {
        makeLinkBarButtonConstraint()
        makeListBarButtonConstraint()
    }
}
