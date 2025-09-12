//
//  SWIFT_TestingTests.swift
//  SWIFT_TestingTests
//
//  Created by 이윤수 on 9/12/25.
//

import Testing
@testable import SWIFT_Testing

struct SWIFT_TestingTests {
    /// SwiftTesting
    /// - Swift 6에 나온 테스트 라이브러리
    /// - 기존 XCTest는 복잡한 문법을 이용해야 했으나, SwiftTesting은 Swift 문법과 같이 간단하게 사용할 수 있음
    /// - SwiftTesting은 XCTest와 같이 사용할 수 있음
    /// -> SwiftTesting은 XCUIApplication, XCTMetric 등을 지원하지 않음
    ///
    /// XCTest
    /// - Class에 XCTestCase를 상속받아 사용
    /// - setUp(), tearDown()으로 테스트 전후 로직 설정
    /// - "test" 키워드를 접두사로 사용
    /// - Main 스레드에서 순차적으로 실행
    ///
    /// SwiftTesting
    /// - class, struct, actor, 전역 등 모두 사용 가능
    /// - init, deinit으로 테스트 전후 로직 설정
    /// - 이름의 제한은 없으며 @Test를 붙여서 사용
    /// - 임의 Task로 병렬 실행됨
    ///
    /// @Test
    /// - 테스트 함수를 지정할 때 사용하는 어노테이션
    /// - @Test와 함께 @MainActor, @available를 조합하여 실행 조건을 변경할 수 있음
    ///
    /// @Test(arguments:)
    /// - 테스트 함수에 매개변수를 하나씩 넣어서 테스트 할 수 있게 함
    /// -> 테스트 함수에 arguments 값을 하나씩 넣어서 검증함
    /// -> 함수가 여러 타입을 받고, 매개변수로 여러개인 경우 모든 조합을 검증함
    /// -> 쌍으로 묶어서 테스트 하고 싶을 때는 zip으로 사용 (모든 조합이 아닌 arguments 수 만큼만 검증됨)
    /// - arguments 값은 독립/병렬적으로 실행됨
    /// -> 순차적으로 테스트하고 싶다면 .serialized 옵션 사용 (하단 참고)
    ///
    /// #expect
    /// - 값을 테스트 할 때 사용하는 기능
    /// - 에러를 테스트 할 때는 (throws: 에러 타입.self)로 테스트 가능
    ///
    /// #require
    ///- 전체 조건을 검증하고, 실패 시 테스트를 중단하는 기능
    ///- expect는 실패하도 테스트를 계속 진행하지만, require는 중간에 실패가 발생한 경우 즉시 테스트를 중단함
    ///
    /// @Suite
    /// - 테스트 함수를 모아놓은 모음을 말함
    /// -> 관련된 기능의 테스트를 묶기 위해 사용
    /// -> Suite > Struct/Class/Actor > func 구조
    /// - 특정 Suite만 실행하거나 제외할 수 있음
    
    init() {
        
    }
    
    @Test
    func test1() {
        try? #require(1 == 1)
        #expect(1 == 1)
    }
    
    @Test(arguments: [2, 4, 6, 8, 10])
    func test2(_ num: Int) {
        #expect(num % 2 == 0)
    }
    
    @Test(arguments: zip( [2, 4, 6], [4, 16, 36])) // zip으로 묶지 않으면 모든 조합을 검증하기 때문에 실패
    func test3(_ num1: Int, _ num2: Int) {
        #expect((num1 * num1) == num2)
    }
    
    @Test
    func test4() {
        #expect(throws: MyError.self) {
            try errorProcess()
        }
    }
    
    /// 다양한 설정
    /// .enabled, disabled(if)
    /// - 다른 조건들을 통해 테스트 함수의 실행을 결정할 수 있음
    /// -> 런타임 조건, 디버그 여부, 환경변수 여부 등
    ///
    /// .timeLimit()
    /// - 테스트 함수에 시간 제한을 줄 수 있음
    /// - > 만약 테스트 모음(Suite)에 시간 제한을 할 경우 모든 함수가 시간 제한을 받게 됨 (함수별 시간)
    ///
    /// .seialized()
    /// - 테스트 실행을 순차적으로 직렬화함
    /// -> 실행 순서만 보장할 뿐 같은 인스턴트를 공유하지는 않음
    ///
    /// .tag()
    /// - 비슷한 테스트를 묶어서 관리하기 위해 사용함
    /// - tag를 정의할 때는 extension으로 tag를 확장해서 정의
    ///
    /// CustomStringConvertible
    /// - 테스트 실패 시 더 읽기 쉬운 메세지를 보기 위해 사용
    /// -> 객체에 프로토콜을 채택해서 사용
    /// -> 여러 프로퍼티가 있는 객체에서 특정 값만 보고 싶을 때 사용
    
    @Test(.enabled(if: isDevSetting))
    func test5() {
        #expect(true)
    }
    
    @Test(.disabled(if: isDevSetting))
    func test6() {
        #expect(false)
    }
    
    @Suite("Test Suite", .serialized) struct TestSuite {
        static var isFirstOk = false
        
        @Test(.tags(.testTag))
        mutating func test7() {
            Self.isFirstOk = true
            #expect(Self.isFirstOk)
        }
        
        @Test(.tags(.testTag))
        func test8() {
            #expect(Self.isFirstOk)
        }
    }
    
    @Test(arguments: [Person(name: "Swift", old: 6), Person(name: "아이폰17", old: 17)])
    func test9(_ item: Person) {
        #expect(item == Person(name: "Swift", old: 6))
    }
}

 extension SWIFT_TestingTests {
    enum MyError: Error {
        case error1
    }
    
    func errorProcess() throws {
        throw MyError.error1
    }
    
    static let isDevSetting = true
    
    struct Person: CustomStringConvertible, Equatable {
        var name: String
        var old: Int
        
        var description: String {
            return "이름: \(name), 나이: \(old)"
        }
    }
}

extension Tag {
    @Tag static var testTag: Tag
}
