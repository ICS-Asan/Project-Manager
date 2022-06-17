![](https://i.imgur.com/kBNgrIa.png)
# 🗓프로젝트 매니저
- 프로젝트 기간: 2022-02-28 ~ 2022-03-25
- 로컬 저장 기능이 있는 일정 관리 어플리케이션

## 목차
- [구현 내용](#구현_내용)
    - [화면](#화면)
    - [주요 구현 내용](#주요구현내용)
- [STEP1: 적용 기술 선정 및 세팅](#STEP1)
    - [STEP 구현 내용](#STEP1-1)
    - [Trouble Shooting](#STEP1-2)
- [STEP2: View 구현](#STEP2)
    - [STEP 구현 내용](#STEP2-1)
    - [Trouble Shooting](#STEP2-2)
- [STEP3: ViewModel 구현](#STEP3)
    - [STEP 구현 내용](#STEP3-1)
    - [Trouble Shooting](#STEP3-2)
- [STEP4: CoreData를 활용한 로컬 저장 기능 구현](#STEP4)
    - [STEP 구현 내용](#STEP4-1)
    - [Trouble Shooting](#STEP4-2)

<a name="구현_내용"></a>
## 구현 내용
<a name="화면"></a>
### 📱 화면
|메인화면|프로젝트 추가|
|:---:|:---:|
|<img src="https://i.imgur.com/vjdY8iT.gif">|<img src="https://i.imgur.com/wkeJhvk.gif">|

|프로젝트 수정|프로젝트 상태변경|
|:---:|:---:|
|<img src="https://i.imgur.com/qvVEzwe.gif">|<img src="https://i.imgur.com/jnLZvWs.gif">|

|프로젝트 삭제|날짜 선택|
|:---:|:---:|
|<img src="https://i.imgur.com/uH34Hve.gif">|<img src="https://i.imgur.com/Odawtrd.gif">|

<a name="주요구현내용"></a>
### 💻 주요 구현 내용
- MVVM 디자인 패턴 적용
    - View와 ViewModel을 분리하여 비즈니스 로직은 ViewModel이 담당하고 View는 화면에 그려지는 역할만 하도록 구현
    - [Clean architecture with RxSwift](https://github.com/sergdort/CleanArchitectureRxSwift#application-1)의 방법을 참고하여 View와 ViewModel 사이의 커뮤니케이션 방법을 설계
    - Repository를 생성하여 각 ViewModel에서 데이터관련 기능을 요청할 수 있도록 구현
- CoreData를 활용하여 로컬에 데이터 저장
    - CoreData는 Apple이 제공하는 First-party framework라서 다른 환경보다 더 안정적으로 운용 가능할 것이라 판단하여 선정
    - extension내부에 CoreData를 모델 타입으로 변환하는 메서드를 구현하여 DTO(Data Transfer Object)의 역할을 할 수 있도록 구현
- 의존성 관리도구로 SPM 사용
    - 애플에서 제공해주는 First-party Tool
    - Xcode에서 다운 및 관리가 가능하기 때문에 CocoaPods에 비해 직관적임
    - 라이브러리의 버전은 업데이트 변경사항을 최소화 하기 위해 Minor 기준으로 버전을 맞춤

<a name="STEP1"></a>
## 1️⃣ STEP1: 적용 기술 선정 및 세팅
<a name="STEP1-1"></a>
### 💻 STEP 구현 내용
#### < SPM을 사용하여 라이브러리 적용 >
- 의존성 관리도구로 SPM을 선정
- 라이브러리 업데이트 변경사항을 최소화 하기 위해 Minor 기준으로 버전을 맞춤
 <img src="https://i.imgur.com/Qs1ORhW.png" height="200">
 
- RxSwift, Firebase 라이브러리 설치
    - Firebase 추후 적용 계획이 있어 미리 설치

#### < CoreData 생성 >
- codegen: Manual/None으로 생성
    - Class, Properties 파일 모두 수정 가능
    - 추후 필요한 기능 추가를 위해 Manual/None 선택

#### < CoreData CRUD 기능 모듈화 >
- 확장성 및 재사용성을 고려하여 CRUD 기능을 모듈화
    - 제네릭 타입의 Class로 구현하여 추후 CoreData의 타입이 추가되더라도 재사용 가능하도록 함

<a name="STEP1-2"></a>
### 🔫 Trouble Shooting
#### git pull 할 때마다 Resolving Package Graph 진행되는 현상
- 문제
    -  git push 이후에 팀원이 pull 받아올때마다 package가 resolving되는 현상 발생
    <img src="https://i.imgur.com/aVryjTm.png" height="70">

- 해결
    - gitignore파일 내부 .xcodeproj 확장자를 추가해주는 방법으로 해결

<a name="STEP2"></a>
## 2️⃣ STEP2: View 구현
<a name="STEP2-1"></a>
### 💻 STEP 구현 내용
#### < CellManagable프로토콜 구현 >
- 프로토콜 기본구현을 통해 기존 Cell의 등록 및 재사용에 identifier를 매개변수로 받지 않도록 구현
    - 기존 `register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)`,`dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell` 메서드는 String타입의 `identifier`를 매개변수로 받음
    - static let으로 `identifier`를 선언할 수도 있지만 확인 및 관리가 용이하지 못함
    - cell의 class명을 사용한다면 변경사항에 간단하게 대응할 수 있을 것이라 판단
    - `String(describing:)`을 사용하여 cell의 클래스를 받아 `identifier`로 사용될 수 있도록 구현
- 메서드를 제네릭으로 구현하여 어떠한 UITableViewCell이라도 사용할 수 있도록 함
    - `<T: UITableViewCell>`로 선언하여 `UITableViewCell`이라면 모두 사용가능
    - cell이 추가되더라도 바로 적용할 수 있음

#### < ProjectListTablaView/HeaderView의 재사용 >
- 내용은 다르지만 같은 모양의 TableView 구현하기 위해 공통 Cell을 구현하여 재사용
    - ToDo, Doing, Done의 목록을 위한 TableView의 Cell이 같은 모양을 가지고 있음
    - `ProjectListCell`을 구현한 뒤 각 TableView에서 사용
- 각 TableView의 HeaderView 또한 공통 View를 구현하여 재사용
    - 제목과 프로젝트의 개수를 나타내는 부분이 같은 위치와 크기를 가지고 있어 재사용하기에 좋을 것이라 판단
    - 각 TableView의 제목과 개수를 받아서 View를 완성할 수 있도록 구현

#### < ProjectFormView의 재사용 >
- 프로젝트 추가 및 수정 화면이 같은 화면에 기능이 달라 공통뷰를 구현
    - 공통뷰를 생성한 뒤 각 ViewController를 구현하여 View를 할당하는 방식으로 구현
    - View를 구현하는 코드가 따로 분리되어 있어서 관리 및 가독성의 측면에서 이점이 있다고 판단함


<a name="STEP2-2"></a>
### 🔫 Trouble Shooting
#### Cell 사이의 간격 설정 
- 문제 
    - TableView의 Header의 크기를 설정해도 간격이 줄지 않는 문제
    - <img src="https://i.imgur.com/pw1mTwF.png" height="300">

- 해결
    - TableView의 style을 grouped로 하면 header, footer 공간이 자동으로 생성되어서 사용하지 않을 부분을 nil로 설정
    - tableView의 `sectionFooterHeight/sectionHeaderHeight`를 0으로 설정
    - <img src="https://i.imgur.com/o1WYRbN.png" height="300">

#### Navigation의 RightBarButton에 Action이 등록되지 않는 문제
- 문제
    - 연산 프로퍼티로 Button생성 시 이니셜라이저에 action을 할당해주어도 동작하지 않는 문제
- 해결
    - Button이 생성되는 시점이 문제가 될 것이라 생각되어 두가지 방법으로 Button을 생성 및 할당
        - 방법 1: Button을 `let button: UIBarButtonItem{}()`에서 `lazy var`로 변경
        - 방법 2: 버튼을 할당 할 때 구현된 프로퍼티를 할당하는 것이 아닌 해당 시점에 생성하여 할당하도록 구현
            - `navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem systemItem:,target:,action:)`
    - 두 방법중 방법 2를 사용하여 구현
    
#### NavigationBar 넣기
- 문제
    - 프로젝트 추가 및 수정 화면에 NavigationController에 연결하지 않고 NavigationBar를 추가할 때 정상적으로 보이지 않는 문제
- 해결
    - 처음 NavigationBar를 생성 할 때 사이즈를 zero로 한 후 AutoLayout(크기 및 위치)를 설정

#### Cell을 long press 했을 때 AlertController가 두번 등장하는 에러
- 문제 
    - 셀을 꾹 눌렀을 때 아래와같은 로그가 출력됨
    <img src="https://i.imgur.com/mxRfxyJ.png" width="500">
    - cell을 long press 했을 때 확인해 본 결과 내부 구현된 로직이 두번 진행되는 문제가 있었음
- 해결 
    - 꾹 누르면 `.began` , 누른채로 커서를 움직이면 `.changed`, 클릭 끝난 시점 `.ended`의 시점으로 나누어져 있음`
    - 시점에 따른 분기처리를 하지않으면 구현한 로직이 `.began`, `.ended`의 시점에서 진행
    - 원하는 시점에만 longpress에 대한 action을 하도록 하기 위해서는 각 조건문을 이용하여 로직을 구현해야 함

#### StackView내부 요소의 AutoLayout이 잡히지 않는 문제
- 문제 
    - StackView의 요소는 따로 AutoLayout을 잡지 않아도 문제가 없었는데 예기치 못한 문제가 발생함
    (각 요소의 높이와 Y position이 모호하다는 에러 발생)
    <img src="https://i.imgur.com/ZgR9Y4L.png" width="500">
- 해결
    - cell의 `contentView`의 사이즈를 직접 줄이는 과정에서 문제가 발생한 것으로 생각됨
        - `contentView` 내부에 하위 View를 넣고 그 내부에 기존에 구현한 StackView를 넣음
        - 기존에 조정하고자 했던 `contentView`의 크기만큼 내부 View의 크기를 조정
    - `contentView`의 경우 UIKit에서 자동으로 생성되는 View이기 때문에 직접 조작하는 것은 지양하는 것이 좋을 것이라고 생각됨


<a name="STEP3"></a>
## 3️⃣ STEP3: ViewModel 구현
<a name="STEP3-1"></a>
### 💻 STEP 구현 내용
#### < ViewModel 구현 >
- MVVM 패턴을 적용하기 위해 각 View별 ViewModel을 생성
    - View와 ViewModel사이에 주고 받아야 할 시점을 파악하여 `Observable` 타입 구현
    - 각 시점별 수행해야 할 기능을 `transform`, `bind` 메서드 내부에 구현
- View와 ViewModel간의 역할을 명확하게 분리
    - View: 이벤트 시점 전달, View업데이트 등의 역할만을 수행할 수 있도록 구현
    - ViewModel: Business 로직 처리, View업데이트 시점 전달 등의 역할만을 수행할 수 있도록 구현
- ProjectRepository 생성
    - 여러 ViewModel에서 데이터 관련 작업을 요청할 수 있도록 하기 위해 데이터 관련 기능을 담당하는 Repository 생성

#### < Delegate 패턴 적용 >
- Cell에서 `LongPressGesture`를 인식하도록 구현
    - TableView에서 인식 후에 어떤 Cell이 눌렸는지 계산하는 것 보다 효율적이라고 판단
- MainViewController에 Delegate를 채택해줌
    - Cell에서 직접 특정 역할을 수행하기에는 한계가 있다고 판단
    - popover로 띄운 메뉴에 대한 기능을 MaingViewController가 수행할 수 있도록 구현
- 강한 순환 참조를 방지하기 위해 `weak` 로 선언

#### < DateFormatter 싱글턴 패턴 적용 >
- 싱글턴 패턴 적용 근거: DateFormatter는 Thread Safe 함
<img src="https://i.imgur.com/TzRxvrh.png" width="400">

- DateFormatter의 extension에 싱글턴으로 DateFormatter로 구현하여 필요한 기능 추가
    - cell을 만드는 과정에서 자주 호출 될 것으로 판단해 필요할 때마다 계속 DateFormatter를 생성하는 것 보다는 싱글턴으로 구현해놓는 것이 더 효율적이라고 생각
    
<a name="STEP3-2"></a>
### 🔫 Trouble Shooting
#### 프로젝트 기한 만료시 textColor = .systemRed가 작동하지 않는 문제
- 문제
    - `setupDateLabel(with:)` 메서드로 프로젝트 기한이 만료되면 `dateLabel.textColor = .systemRed`로 표기되도록 조건문을 걸어주었으나 제대로 작동하지 않음
    - `setSelected()` 메서드에서 else문을 타면서 셀이 선택되지 않은 상태에서는 `dateLabel.textColor = .label`로 지정되는 것이 문제

- 해결 
    - `setSelected()` 메서드 내부의 dateLabel을 지정해주는 부분에 `setupDateLabel(with:)` 메서드를 호출해서 프로젝트 날짜를 기반으로 색상이 변경되록 구현

<a name="STEP4"></a>
## 4️⃣ STEP4: CoreData를 활용한 로컬 저장 기능 구현
<a name="STEP4-1"></a>
### 💻 STEP 구현 내용
#### < CoreData 적용 >
- CoreData를 통해 로컬로 데이터를 저장할 수 있도록 구현
    - `ProjectData`(CoreData)->`Project`(Model타입)로 변환하는 메서드를 구현하여 저장된 데이터를 내부에서 사용되는 Model타입으로 사용할 수 있도록 구현
- `NSPredicate`를 통해 CoreData에서 원하는 데이터를 검색할 수 있도록 구현
    - 특정 프로젝트를 수정, 삭제 하기 위해서 id를 통해 같은 찾을 수 있도록 함
    - 수정, 삭제시 `searchData()`메서드를 통해 필요한 데이터를 검색
- `Project`(Model타입) 프로퍼티들을 Dictionary로 return하는 연산 프로퍼티 생성
    - `Project`타입을 CoreData로 저장하기 위해 `CoreDataManager`내부 로직에 Dictionary, for-in 구문 활용
    - 매개변수로 바로 전달할 수 있도록 내부 연산프로퍼티를 구현하여 사용

<a name="STEP4-2"></a>
### 🔫 Trouble Shooting
#### CoreData타입 <-> Model타입 전환 로직
- 문제
    - CoreData로 저장된 데이터를 Model타입으로 전환해서 사용하고자 할 때마다 특정 메서드를 구현해서 매번 호출하는 것은 비효율적이라고 판단함
    -  하지만 변환과정은 불가피한 상황이기 때문에 한번만 변환할 수 있도록 로직을 구현

- 해결
    - CoreData class가 DTO의 역할을 할 수 있도록 내부`translateToModelType() -> Project` 메서드를 구현
    - 처음 데이터를 불러올 때 해당 메서드를 통해 변환 후 Repository의 프로퍼티에 별도로 저장
    - 이후 변경사항을 Repository의 프로퍼티와 CoreData에 모두 적용
    - 앱이 처음 켜질때에만 CoreData타입->Model타입의 변환이 이루어지기 때문에 이후 작업에서 수정, 삭제시에 새 인스턴스를 생성하지 않아도 되는 장점이 있음

