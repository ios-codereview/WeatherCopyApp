# 애플 날씨앱 따라만들기

애플 기본날씨앱 따라 만들기 프로젝트

<br>

## 개요

애플날씨앱 만들기 프로젝트입니다. 스토리보드 없이 코드로만 진행하여 클래스 별 간단한 사용목적을 정리했습니다.

<br>
<br>

### Model

**WeatherAPI**
* WeatherAPI : 날씨 API는 DarkSky를 활용, API를 처리하고 결과에 따른 결과값을 반환하는 싱글턴 클래스
* WeatherAPIData : 날씨 API Codable 데이터 포맷

* CommonData : 전반적인 앱 실행 간 활용 될 수 있는 공용 싱글턴 클래스
* WeatherData : 날씨관련 수치를 표현하는 구조체 모음
  - SubWeatherData, SubLocationData는 UserDefault를 통한 데이터 저장 시 사용하는 포맷

**Constant**
* 변하지 않는 데이터 값 그룹

**Extension**
* 범용으로 사용되는 Extension 그룹

**Protocol**
* UIViewSettingProtocol : 서브뷰 추가, 제약값 설정 등 중복되는 메서드를 정리한 프로토콜
* WeatherAPIDelegate : Weather API 요청 간 다양한 시점을 감지하기 위한 델리게이트 프로토콜
* CellSettingProtocol : 셀 셋팅 관련 중복 메서드를 정리한 프로토콜 

<br>
<br>
  
### Controller

* MainNavigationController : 메인으로 사용하는 네비게이션 뷰 컨트롤러
* WeatherMainViewController : 설정한 도시 별 날씨 정보를 보여주는 뷰 컨트롤러
  -  WeatherMainTableView의 프로토콜을 채택해 사용한다.
* WeatherInfoViewController : 도시 별 상세 날씨정보를 보여주는 뷰 컨트롤러
  -  WeatherInfoTableView의 프로토콜을 채택해 사용한다.
  -  페이지뷰 기능을 관리
* WeatherContentViewController : 페이지뷰 컨텐츠 뷰컨트롤러
* WeatherCitySearchViewController : 도시 검색 및 날씨정보 추가를 하는 뷰 컨트롤러
  -  CitySearchTableView의 프로토콜을 채택해 사용한다.
  
<br>
<br>
  
### View

**WeatherCitySearchView** 도시검색기능, WeatherCitySearchViewController 뷰
* CitySearchTableView : 도시 검색결과를 보여주는 테이블 뷰
* CitySearchTableViewCell : 도시 검색결과를 보여주는 테이블 뷰 셀

**WeatherCityListView** 도시 별 날씨정보, WeatherMainViewController 뷰
* WeatherActivityIndicatorView : 네트워킹 작업 진행 중 실행되는 중앙 인디케이터<br>
    **WeatherCityListTableView**
    * WeatherCityListTableViewCell : 도시 별 간략정보를 표시하는 테이블 뷰 셀
    * WeatherCityListTableFooterView : 테이블 뷰 하단 여백을 주기 위한 테이블 푸터뷰

**WeatherDetailView** 도시 세부 날씨정보, WeatherMainViewController 뷰
* WeatherTitleView : 뷰 최상단의 도시명과 날씨요약정보를 표시하는 뷰<br>
    **WeatherInfoTableView** 날씨세부정보를 보여주는 메인 테이블 뷰
    * WeatherDetailTableHeaderView : 스크롤 시 높이가 변동되는 상단 Stretched 헤더뷰
    * WeatherHourInfoTableViewCell : 서브 콜렉션 뷰를 가진 시간 별 날씨정보 테이블 뷰 셀
     -  DayInfoCollectionView의 프로토콜을 사용한다.<br>
        **DayInfoCollectionView** 시간 별 날씨정보 컬렉션 뷰
        * HourInfoCollectionViewCell : 시간 별 날씨정보을 수평으로 배치하는 컬렉션 뷰 셀
    * WeatherSubInfoTableViewCell : 시간 별 날씨정보 하단의 세부 날씨정보 서브 테이블뷰<br>
        **WeatherSubInfoTableView** 뷰 하단 세부 날씨정보 테이블 뷰<br>
            **WeekInfoTableViewCell** 일주일 간 요약 날씨정보 테이블 뷰 셀<br>
            * WeekSubInfoView : WeekInfoTableViewCell의 날씨 정보 컨텐츠를 가진 뷰<br>
            **TodayInfoTableViewCell** 금일 세부 날씨지표 테이블 뷰 셀<br>
            * TodayInfoTableView 상단의 오늘의 날씨를 요약설명하는 헤더뷰<br>

**WeatherSeparatorView** 셀 간 여백 구현 목적 사용, WeatherSeparatorView 뷰
* WeatherSeparatorTableViewCell : 여백 구현 목적으로 사용한 테이블 셀 

<br>
<br>
  
### 날씨 앱 실행 예시
* **-> 기능구현 완료, 코드 구조 / 알고리즘 등에 대한 추가 리펙토링 진행 중**

<div>
<img width="300" src="https://user-images.githubusercontent.com/4410021/62603585-32e64a80-b931-11e9-88c3-86c960f40922.jpeg">      <img width="300" src="https://user-images.githubusercontent.com/4410021/62603608-3bd71c00-b931-11e9-8b46-ea0c7b2dfc79.jpeg"> 
</div>
<p>
<div>
<img width="300" src="https://user-images.githubusercontent.com/4410021/62603632-4691b100-b931-11e9-886e-3933d241a495.jpeg">      <img width="300" src="https://user-images.githubusercontent.com/4410021/62603642-4db8bf00-b931-11e9-9a8b-b8d58566f60a.jpeg">
</div>
