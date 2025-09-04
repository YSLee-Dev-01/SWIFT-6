import Foundation

/// Noncopyable, Copyable
///
/// Swift 5.9부터 ~Copyable 프로토콜을 통해 복사를 억제하는 기능을 제공함
/// Swift 6부터는 제네릭에서도 ~Copyable 사용이 가능해지고, 패턴 매칭에서 borrowing을 지원하는 등 기능이 확대됨
///
/// 복사?
/// - Swift에서 복사는 값 타입, 참조타입일 때 다르게 일어남
///
/// 값 타입
/// - 복사 후에도 각각의 객체가 서로 영향을 받지 않음
///
/// 참조타입
/// - 복사 시 각각의 객체가 같은 주소를 바라보기 때문에 서로 영향을 받음 (얕은 복사)
/// - 참조 타입에서도 init을 통해 타입을 받아 처리한 경우 서로 영향을 받지 않는 깊은 복사를 할 수 있음 (내부속성이 값타입의 한해)

struct Player {
    var name: String
}

let player1 = Player(name: "유재석")
var player2 = player1
player2.name = "박명수"

// 유재석, 박명수
print(player1.name, player2.name)

class Game { // 참조타입
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(_ game: Game) { // 깊은 복사를 하기 위한 Init
        self.name = game.name
    }
}

let game1 = Game(name: "리그오브레전드")
var game2 = game1 // 얕은 복사
game2.name = "발로란트"

// 발로란트, 발로란트
print(game1.name, game2.name)

var game3 = game2
game3 = Game(game3) // 깊은 복사
game3.name = "오버워치"

// 발로란트, 발로란트, 오버워치
print(game1.name, game2.name, game3.name)

/// Copyable
/// - 유형이 복사될 수 있는 프로토콜
/// - 디폴트로 구현되어 있음
///
/// Noncopyable (~Copyable)
/// - 유형이 복사될 수 없는 프로토콜
/// - Copyable 프로토콜을 억제하여, 복사를 할 수 없는 타입이 됨
///
/// ~Copyable은 복사가 불가능한 것이며, 이동 자체가 불가능 한 것은 아님
/// - A 변수에서 B 변수로 값 이동은 가능함
/// -> 이 때 B로 값이 이동한 경우 A 변수는 초기화 되지 않은 상태로 유지됨
/// -> 접근 시 오류가 발생하게 됨
/// - consume은 명시적으로 이동을 지시하는 키워드로 생략이 가능함
/// - 단 전역변수는 consume로 이동이 불가능함

struct BankAccount: ~Copyable {
    var number: Int
}

let bankAccount = BankAccount(number: 1234) // 전역변수
//var bankAccount2 =  bankAccount // 오류 발생 (전역변수는 consume로 이동 불가)

func test() {
    let bankAccount1 = BankAccount(number: 1234)
    var bankAccount2 =  bankAccount1
    print(bankAccount2.number)
    // print(bankAccount1) // 오류 발생
}

test()

/// 복사할 수 없는 값(~Copyable)이 매개변수인 경우
/// - 함수가 값에 대해 갖는 소유권을 지정해야함
///
/// consuming (소비)
/// - 함수 호출자로부터 인수 (값)을 가져간다는 키워드
/// - 함수 호출자는 인수로 값을 넘긴 후 사용할 수 없음
///
/// Borrowing (빌림)
/// - 일시적으로 접근하여 사용하는 키워드
/// - 원본은 그대로 유지되며, 읽기권한만 가져올 수 있음 (소비, 변이 불가)
///
/// inout
/// - 값의 주소 값 자체를 받아와서 사용하는 키워드
/// -> 기존 사용 방식과 동일

func processBankAccount(_ account: consuming BankAccount) -> BankAccount {
    var newAccount = account
    newAccount.number += 1
    return newAccount
}

func readBankAccount(_ account: borrowing BankAccount)  {
    // 소비 및 변이가 불가하기 때문에 하단 작업 불가
    // var newAccount = account
    // newAccount.number += 1
    print(account.number)
}

func updateBankAccount(_ account: inout BankAccount)  {
    account.number = 100
}

func main() {
    let companyBankAccount = BankAccount(number: 1)
    readBankAccount(companyBankAccount)
    
    var newBankAccount = processBankAccount(companyBankAccount)
    // print(companyBankAccount) 소유권이 없기 때문에 접근 불가
    
    readBankAccount(newBankAccount)
    updateBankAccount(&newBankAccount)
    readBankAccount(newBankAccount)
}

main()

/// ~Copyable는 프로토콜이기 때문에 제네릭의 제약조건에도 사용할 수 있음
/// - 일반적인 제네릭은 Copyable를 준수하고 있음
///
/// 프로토콜을 정의할 때도 ~Copyable를 채택할 수 있음
/// - 이 때 ~Copyable는 일반적인 프로토콜과 달리 제약조건이지 요구사항은 아님
/// -> 상위 프로토콜에서 ~Copyable를 채택하더라도 이 프로토콜을 채택하는 객체에서는 자동으로 ~Copyable이 되지 않음
/// -> 이 때는 ~Copyable을 강제하는 것이 아닌 Copyable 요구를 제거하는 것
/// -> 그럼에 따라 ~Copyable 일 수도 있고, Copyable도 있다는 걸 의미
/// - 기존 Copyable와의 하위호환성을 위해 위 방식을 채택했으며, ~Copyable를 원할 경우 명시적으로 선언해야함

protocol Animal: ~Copyable {
    var name: String { get set }
    func signatureAction()
}

struct Dog: Animal {
    var name: String = "개"
    
    func signatureAction() {
        print("\(name): 월~ 월!")
    }
}

struct Cat: Animal, ~Copyable {
    var name: String = "고양이"
    
    func signatureAction() {
        print("\(name): 냐옹 ~~ 냐옹 ~~")
    }
}

func playWithAnimal<T: Animal>(_ animal: T) {
    var newAnimal = animal
    newAnimal.name = "변이된 상어"
    newAnimal.signatureAction()
}

func playWithAnimal<T: Animal & ~Copyable>(_ animal: borrowing T) {
    // 소비 및 변이가 불가하기 때문에 하단 작업 불가
//    var newAnimal = animal
//    newAnimal.name = "상어"
    animal.signatureAction()
}

let dog = Dog(name: "코코")
let cat = Cat(name: "보리")

playWithAnimal(dog)
playWithAnimal(cat)
