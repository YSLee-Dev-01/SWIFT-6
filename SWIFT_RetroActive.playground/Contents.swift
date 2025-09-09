import Foundation

/// @retroactive
///
/// Identifiable, Equatable 등 프로토콜을 채택하면 공통된 함수, 프로퍼티 등을 사용할 수 있음
/// - 외부 모듈, 라이브러리에서 제공하는 타입은 특정 프로토콜을 준수하지 않는 경우가 있음
/// -> 타입을 Extension으로 확장하여 프로토콜을 채택해서 사용해왔음
/// Swift에서는 동일한 프로토콜을 동일한 타입에 2개 이상 채택할 경우 에러가 발생함

protocol MyProtocol {}
extension String: MyProtocol {}

//extension String: MyProtocol{} 에러 발생

extension Date: Identifiable {
    public var id: TimeInterval {timeIntervalSince1970}
}

/// 위 코드는 Date를 확장하여 Identifiable를 준수하도록 하는 코드 (예시)
/// - 이 때 Swift가 업데이트 되어 Date 타입이 Identifiable를 준수하도록 업데이트 될 경우, 에러가 발생하게 됨
/// -> 이로인해 예기치 않은 버그가 발생할 수 있으며, 라이브러리 내부에 선언된 경우 라이브러리를 사용하는 모든 코드에 영향을 주기 때문에 큰 문제가 발생함
///
/// -> 이를 통해 타입 Extension과 함께 적용된 소급 프로토콜은 위험성이 있다는 것을 알 수 있음
///
/// Swift6에서는 소급 프로토콜이 문제를 일으킬 수 있다는 것을 경고하게 됨
/// - 컴파일에서 경고를 발생시킴
/// -> 해당 경고를 없애기 위해서 사용하는 키워드가 @retroactive

extension String: @retroactive Error {}

/// @retroactive를 사용할 경우 소급 프로토콜이 의도된 것이라는 것을 명시함
/// - Swift6부터는 소급 프로토콜 준수에 대해 컴파일러가 경고를 발생시킴
/// -> 기본 타입에 소급 적용한 프로토콜이 기본 제공될 경우, 에러가 발생하게 됨
///
/// + 소급 프로토콜에 대한 경고는 @retroactive 키워드 뿐만 아니라,
/// 타입의 전체 경로를 명시한 경우에도 경고를 받지 않을 수 있음
///
/// + 소급 프로토콜로 인해 문제가 생길 것을 예상하는 경우 struct, class 등 객체로 감싸서 사용하거나, 제네릭으로 사용할 경우 간접적으로 우회 사용할 수 있음

struct IdentifiableDate: Identifiable {
    let date: Date
    var id: TimeInterval { date.timeIntervalSince1970 }
}
