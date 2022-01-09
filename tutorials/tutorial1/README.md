# Preparation

## STEP 1

pod 'RIBs' 설치

```swift
pod 'RIBs', '~> 0.9'
```

## STEP 2 

https://github.com/uber/RIBs로 들어간 뒤, 우측 버튼에서 `download zip`

이후, cmd에서 `<RIBs path>/ios/tooling` 경로로 이동 후 아래와 같이 입력하여 template 설치

```markdown
$./install-xcode-template.sh
```

# [iOS] RIB Arichitecture Tutorial 1

## 목표

<img width=60% src="https://user-images.githubusercontent.com/42789819/148684045-b1986cc5-e03c-4fe9-8186-3dcf78ee30c5.gif">

이번 튜토리얼의 목표는 다양한 RIB의 구성요소들을 이해하고, 특히 그들이 서로 어떻게 상호작용, 소통하는지 이해하는데에 있습니다. 이 튜토리얼이 끝나면, 사용자가 플레이어 이름들을 입력하고 로그인 버튼을 탭할 수 있는 화면을 가진 앱이 만들어져있을 것입니다. 로그인 버튼은 탭했을 때 Xcode 콘솔에 사용자가 입력한 플레이어의 이름이 출력될 것입니다.

## 프로젝트 구조

우리가 제공하는 상용구 코드에는 두 개의 RIB(Root, LoggedOut)로 구성된 iOS 프로젝트가 포함되어 있습니다. 앱이 시작되면 `AppDelegate`는 `루트 RIB`를 빌드하고 애플리케이션에 대한 제어를 `루트 RIB`로 넘깁니다. `루트 RIB`의 목적은 RIB 트리의 루트 역할을 하는것과 필요할 때 자식에게 제어를 전달하는 것입니다. `루트 RIB`의 코드는 대부분 Xcode 템플릿에 의해 자동 생성되므로 이 코드를 이해하는 것은 지금 딱히 필요하지 않습니다.

TicTacToe 앱의 두 번째 RIB는 `LoggedOut`이라고 하며, 로그인 인터페이스를 포함하고 인증 관련 이벤트를 관리해야 합니다. `루트 RIB`가 `AppDelegate`에서 앱에 대한 제어 권한을 얻으면 즉시 이를 `LoggedOut RIB`로 전송하여 로그인 양식을 표시합니다. `LoggedOut RIB`를 빌드하고 표시하는 코드는 이미 제공되었으며 `RootRouter`에서 찾을 수 있습니다.

현재 `LoggedOut RIB`는 구현되어 있지 않습니다. `LoggedOut` 폴더를 열면 코드를 컴파일하는 데 필요한 일부 스텁이 포함된 DELETE_ME.swift 파일만 찾을 수 있습니다. 이 튜토리얼에서는 `LoggedOut RIB`의 적절한 구현을 만들 것입니다.

## LoggedOut RIB 생성

<img width=49% alt="image" src="https://user-images.githubusercontent.com/42789819/148683810-5f092a35-3a21-42b2-b5aa-de100f60e751.png"><img width=49% alt="image" src="https://user-images.githubusercontent.com/42789819/148683795-9d169138-7406-4512-9661-cd7e852bc0cf.png">

LoggedOut 폴더에서 아까 설치한 RIB 템플릿을 골라 LoggedOut이라는 이름으로 폴더 내에 생성

## 생성된 코드 이해하기

![image7](https://user-images.githubusercontent.com/42789819/148684020-58e17cca-95dc-42d5-8a72-1b9a7abaf386.jpg)
LoggedOut RIB를 구성하는 모든 클래스가 생성되었습니다.

* **LoggedOutBuilder**는 **LoggedOutBuildable**을 준수하므로 빌더를 사용하는 다른 RIB는 빌드 가능한 프로토콜을 준수하는 모의 인스턴스를 사용할 수 있습니다.

* **LoggedOutInteractor**는 **LoggedOutRouting** 프로토콜을 사용하여 **Router**와 통신합니다. 이것은 Interactor가 필요한 것을 선언하고 이 경우 LoggedOutRouter와 같은 다른 단위가 구현을 제공하는 종속성 반전 원칙을 기반으로 합니다. 빌드 가능한 프로토콜과 유사하게 이를 통해 인터랙터가 단위 테스트될 수 있습니다. **LoggedOutPresentable**은 인터랙터가 뷰 컨트롤러와 통신할 수 있도록 하는 동일한 개념입니다.

* **LoggedOutRouter**는 Interactor와 통신하기 위해 **LoggedOutInteractable**에서 필요한 것을 선언합니다.

  **LoggedOutViewControllable**을 사용하여 뷰 컨트롤러와 통신합니다.

* **LoggedOutViewController**는 **LoggedOutPresentableListener**를 사용하여 동일한 종속성 반전 원칙에 따라 상호 작용자와 통신합니다.

## Login logic

사용자가 "Login" 버튼을 탭한 뒤, `LoggedOutViewController`는 사용자가 로그인하고싶어 하는 것을 알리기 위해 자신의 listener(`LoggedOutViewController`)를 호출해야 할 것입니다. listener는 로그인 요청 처리하기 위해 게임에 참가하려는 player들의 이름을 받아야 할 것입니다.

이 로직을 수행하기 위해서, 우리는 listener가 뷰 컨트롤러로부터 로그인 요청을 받을 수 있도록 업데이트 해주어야 합니다.

`LoggedOutViewController.swift` 에서`LoggedOutPresentableListener` 프로토콜을 다음과 같이 수정하세요

```swift
protocol LoggedOutPresentableListener: class {
    func login(withPlayer1Name player1Name: String?, player2Name: String?)
}
```

> 사용자가 플레이어 이름을 아무 것도 입력하지 않을 수 있으므로 두 플레이어 이름은 모두 선택 사항입니다. 두 이름을 모두 입력할 때까지 로그인 버튼을 비활성화할 수 있지만 이 연습에서는 LoggedOutInteractor가 빈 이름을 처리하도록 합니다. 플레이어 이름이 비어 있으면 구현에서 기본적으로 "플레이어 1" 및 "플레이어 2"로 설정됩니다.

이제 다음 메서드를 추가하여 수정된 `LoggedOutPresentableListener` 프로토콜을 준수하도록 `LoggedOutInteractor`를 수정합니다.

```swift
// MARK: - LoggedOutPresentableListener

func login(withPlayer1Name player1Name: String?, player2Name: String?) {
    let player1NameWithDefault = playerName(player1Name, withDefaultName: "Player 1")
    let player2NameWithDefault = playerName(player2Name, withDefaultName: "Player 2")

    print("\(player1NameWithDefault) vs \(player2NameWithDefault)")
}

private func playerName(_ name: String?, withDefaultName defaultName: String) -> String {
    if let name = name {
        return name.isEmpty ? defaultName : name
    } else {
        return defaultName
    }
}
```

지금은 사용자가 로그인할 때 사용자 이름만 인쇄합니다.

마지막으로 로그인 버튼을 눌렀을 때 리스너 메서드를 호출하도록 뷰 컨트롤러를 연결합니다. `LoggedOutViewController.swift`에서 `didTapLoginButton` 메서드를 다음과 같이 변경합니다.

```swift
@objc private func didTapLoginButton() {
    listener?.login(withPlayer1Name: player1Field?.text, player2Name: player2Field?.text)
}
```

## Tutorial 1 완성

축하합니다! 첫 번째 RIB를 만들었습니다. 지금 프로젝트를 빌드하고 실행하면 대화형 버튼이 있는 로그인 인터페이스가 표시됩니다. 버튼을 탭하면 Xcode 콘솔에 플레이어 이름이 인쇄된 것을 볼 수 있습니다.

요약하자면, 이 튜토리얼에서는 Xcode 템플릿에서 새 RIB를 생성하고 인터페이스를 업데이트했으며 사용자가 입력한 데이터를 뷰 컨트롤러에서 인터랙터로 전달하는 버튼 탭 이벤트에 대한 핸들러를 추가했습니다. 이를 통해 이 두 단위 간의 책임을 분리하고 코드의 테스트 가능성을 개선할 수 있습니다.