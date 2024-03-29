//
//  WeatherAPI.swift
//  WeatherApp
//
//  Created by MinKyeongTae on 04/08/2019.
//  Copyright © 2019 MinKyeongTae. All rights reserved.
//

import UIKit

final class WeatherAPI {
    static let shared = WeatherAPI()

    // STEP 1) JSON데이터를 받기 위해 사용할 변수와 API토큰을 준비한다.
    // Review: [Refactroing] 외부에서 접근할 수 없도록 private 로 설정하는 것이 캡슐화에 도움이 됩니다.
    public let urlSession = URLSession(configuration: .default)
    public var dataTask = URLSessionDataTask()
    public var baseURL = "https://api.darksky.net/forecast/"
    public let APIToken = "447da2f0774b0e23418285c52c5ec67b/" // 자신의 날씨 API+'/'를 사용합니다.
    // 447da2f0774b0e23418285c52c5ec67b
    public let APISubURL = "?lang=ko&exclude=minutely,alerts,flags"
    public var errorMessage = ""
    // Review: [경고] weak 키워드를 붙이지 않으면 강한 상호 참조가 됩니다.
    internal var delegate: WeatherAPIDelegate?

    init() {
        // STEP 2) BaseURL에 API토큰을 추가한다.
        setBaseURL(token: APIToken)
    }

    // completion: @escaping weatherResult
    // Result<WeatherAPIData, Error> 로 정리하는 것이 어떨까요?
    // delegate 를 사용하면 다른 곳에서 사용하게 된다면 문제가 발생합니다.
    public func requestAPI(latitude: Double, longitude: Double, completion: @escaping (WeatherAPIData) -> Void) {
        delegate?.weatherAPIDidRequested(self)
        let APIUrlString = "\(baseURL)\(latitude),\(longitude)\(APISubURL)"
        guard let APIUrl = URL(string: APIUrlString) else { return }

        // STEP 4-1) URLSessionDataTash 초기화
        dataTask = urlSession.dataTask(with: APIUrl) { data, response, error in
            // STEP 4-2) 데이터 요청 간 에러유무를 판별한다.
            if let error = error {
                self.errorMessage = "\(error.localizedDescription)"
                self.delegate?.weatherAPIDidError(self)
            }

            // STEP 4-2) HTTP URL 요청 시 응답이 있는지 확인한다.
            if let response = response as? HTTPURLResponse {
                // 응답 결과에 따라 데이터 처리를 시도한다.
                if (200 ... 299).contains(response.statusCode) {
                    guard let data = data else { return }
                    do {
                        let weatherAPIData = try JSONDecoder().decode(WeatherAPIData.self, from: data)
                        self.delegate?.weatherAPIDidFinished(self)
                        completion(weatherAPIData)
                    } catch DecodingError.keyNotFound(_, _) {
                        self.delegate?.weatherAPIDidError(self)
                    } catch DecodingError.typeMismatch(_, _) {
                        self.delegate?.weatherAPIDidError(self)
                    } catch {
                        self.delegate?.weatherAPIDidError(self)
                    }
                } else {
                    self.delegate?.weatherAPIDidError(self)
                }
            } else {
                // Review: [사용성] error 처리가 필요해 보입니다~
                // 관련된 코드: https://github.com/start-rxswift/MVVMGithubTDD/blob/master/TddMVVMGithub/Networking/Reqeusts.swift
            }

            // STEP 5) 데이터 처리 결과를 completion handler을 통해 반환한다.
        }

        // STEP 6) 정지된 상태에서 dataTask를 실행시킨다.
        dataTask.resume()
    }

    public func setBaseURL(token _: String) {
        baseURL.append(APIToken)
    }
}
