import Foundation

/// GlobalActor
///
/// Swift6에서는 전역변수나 static 프로퍼티가 여러 스레드에서 동시에 접근할 수 있는 상황을 엄격하게 관리함
/// - Swift5에서는 오류가 발생하지 않았던 코드도 오류가 발생할 수 있음

class SettingManager {
    //static let shared = SettingManager() // swift6에서는 오류 발생
    private init() {}
    var theme = "light"
}

/// 이 문제는 GlobalActor, Sendable 프로토콜 채택, Actor 사용 등으로 해결할 수 있음
///
/// GlobalActor
/// - 기본 Actor는 특정 영역 안에서 상태를 보호했음 (실행 순서를 보장했음)
///- GlobalActor는 앱 전체에서 공통으로 사용하는 직렬 실행 컨텍스트를 보장하고 싶을 때 사용함
/// -> 앱 전체에서 사용하는 싱글톤 패턴에서 처리 순서를 보장하고 싶을 때 사용 (파일 시스템 등)
///
/// Actor
/// - 인스턴스 단위 별로 격리되는 구조
/// -> 인스턴스 마다 별도로 직렬화됨
///
/// GlobalActor
/// - 앱 전역 단위로 격리되는 구조
/// -> 항상 같은 전역 직렬 컨텍스트를 가짐
///
/// @MainActor 또한 GlobalActor 중 하나로 MainThread에서의 동작을 보장함
/// - 기본 GlobalActor는 MainThread의 동작을 보장하지 않음
///
/// GlobalActor를 만들 때는 내부에 shared 객체를 선언해야함
/// - 처리순서를 보장하고 싶은 객체, 함수에 GlobalActor 이름을 붙여서 사용함
/// - GlobalActor를 사용한 함수를 호출할 때는 Task{}, await를 통해 호출해야함


@globalActor
actor MemoManager {
    static let shared = MemoManager()
}

@MemoManager
func getMemo() -> String {
    return "memo"
}

Task {
   print("1: \(await getMemo())")
}

// getMemo() // 오류 발생

/// nonisolated
/// - Actor, GlobalActor에 속한 함수, 프로퍼티는 그 Actor의 격리 영역 안에서만 실행됨
/// -> 접근, 사용시 마다 await가 필요하고, 직렬화된 컨텍스트를 거쳐야함
/// - 굳이 Actor의 격리에 묶일 필요가 없을 때는 nonisolated 키워드를 사용하여 격리에서 제외할 수 있음
/// -> 동시에 사용해도 안전한 let, 순수함수 등에서 사용함
///
/// - 키워드가 붙으면 일반함수, 일반 프로퍼티처럼 동작할 수 있음 (await X)
/// -> 다만 키워드가 붙은 함수 내부에서는 격리된 상태 값 (actor.self)에 접근할 수 없음
/// - 프로토콜은 동기적인 접근을 요구하기 때문에 프로퍼티에 nonisolated를 붙여야 하는 경우가 있음

actor MyActor {
    nonisolated let actorName = "MyActor"
    var count: Int = 0
    
    func getCount() -> Int {
        self.count
    }
    
    func plusCount() {
        self.count += 1
    }
    
//    nonisolated func minusCount() { // 오류 발생 (nonisolated가 붙으면 actor 내부프로퍼티 접근 불가)
//        self.count -= 1
//    }
}

let actor = MyActor()
print("2: \(actor.actorName)")
//print(actor.getCount()) // 오류 발생

Task {
    await print("3: \(actor.getCount())")
}

Task {
    await actor.plusCount()
}

Task {
    await print("4: \(actor.getCount())")
    print("5: \(actor.actorName)")
}

/// isolated
/// - 함수가 특정 Actor의 격리영역에서 실행됨을 명시하는 키워드
/// -> 함수가 특정 Actor에서 실행되기를 원할 때 Actor의 매개변수로 전달하게 됨
/// - 함수 내부에서 Actor를 받아서 처리하기 때문에 함수 내부에서는 await를 사용하지 않아도 됨
///
/// UIKit, SwiftUI의 타입을 넣을 경우 자동으로 MainActor로 동작하게 됨
/// - 각 컴포넌트가 이미 @MainActor로 매핑되어 있기 때문
///
/// 단, 함수를 호출할 때는 격리영역으로 진입해야 하기 때문에 task, await 필요

func isolatedFunction(_ myActor: isolated MyActor) {
    myActor.actorName
    myActor.plusCount()
    print("6: \(myActor.getCount())")
}

Task {
    await isolatedFunction(actor)
}
