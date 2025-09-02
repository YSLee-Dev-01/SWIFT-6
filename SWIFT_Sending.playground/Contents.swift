import Foundation

/// Sending, Disconnected, Connected
///
/// Swift6부터는 영역, 소유권, sending 키워드를 통해 동시성 환경에서 데이터를 안전하게 전달할 수 있는 방법을 제공함
///
/// Swift6 이전

class Procedure {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

actor Reservation {
    private var list: [String] = []
    private var proceduredList: [Procedure] = []
    
    func pop(_  procedure: [Procedure]) -> String {
        proceduredList += procedure
        return list.removeFirst()
    }
    
    func add(_ person: String) {
        list.append(person)
    }
}

var procedureList: [Procedure] = [Procedure(name: "cut"), Procedure(name: "perm")]
let reservation = Reservation()

Task {
    await reservation.add("LYS")
    //let name1 = await reservation.pop(procedureList) // 접근 1
}

for item in procedureList {
    print(item) // 접근 2
}

/// 같은 procedureList를 다른 곳에서도 사용이 가능하여 데이터 경쟁이 유발될 수 있음
/// Actor 내부에서는 list, proceduredList만 관리하기 때문에 매개변수는 따로 관리되지 않음
/// -> Actor 내부에서 모든 값을 처리하기에는 부담이 크며 성능 문제도 발생됨
///
/// Swift6에서는 영역, 소유권, sending을 통해 위 문제를 해결함
///
/// 영역?
/// - Swift6에서 모든 값은 특정 격리 영역에 속하게 됨
/// - 영역은 데이터 경쟁을 방지하고, 격리를 보장하기 위해 사용됨

actor Person {
    let name = "LYS" // Person 영역
}

struct Animal {
    let name = "Dog" // Animal 영역
}

/// Disconnected, Connected Region(영역)
/// - Disconnected는 특정 actor나 격리 도메인에 속해있지 않은 영역
/// - Connected는 특정 actor나 격리 도메인에 속해있는 영역
///
/// 언제 Disconnected가 될까?
/// - 일반적인 값을 생성할 때
/// - sending 함수의 반환 값
/// - 매개변수로 값을 받을 때 (할당 전)
///
/// 언제 Connected가 될까?
/// - Actor 프로퍼티에 값을 할당할 때
/// - 다른 Connected 값과 조합될 때 (튜플 등으로 인해)

class Product {}
actor ProductManager {
    private var data: Product = .init() // 생성과 동시에 Connected
    
    func createProduct()  {
        let newProduct: Product = .init() // Disconnected
        data = newProduct  // 할당됨에 따라 Connected
    }
}

/// 소유권
/// - 함수의 값 소유권이 변경된 경우 더 이상 데이터에 접근하여 수정, 열람 등이 불가함
/// - sending 키워드는 이 값을 함수에 넘겨주고 난 후로는 더 이상 사용하지 않겠다고 약속하는 것
/// -> 영역을 벗어난 것
/// -> 함수 호출 시 매개변수가 sending 타입인 경우 해당 함수를 호출할 경우 소유권을 상실하게 됨
///
/// sending
/// - 매개변수 앞, 리턴 타입 앞에 정의해서 사용
/// - sending 키워드 자체는 소유권 이전을 위한 키워드임으로 class, struct 등 모두 사용 가능함
/// - inout 키워드와 같이 사용할 수 있음
///
/// sending을 사용하는 이유?
/// - sendable을 준수하지 않는 값을 동시성 환경에서도 안전하게 사용하기 위해 사용됨
///
/// sending 파라미터와 반환 타입
/// - 파라미터로 사용할 경우 호출자 쪽에서 소유권을 넘기고, 받아서 사용하는 쪽은 Disconnected 상태로 전달받음
/// - 반환타입으로 사용할 경우 반환시점에 함수와의 연결을 끊고 호출자에게 돌려줌 (호출자는 Disconnected로 받음)
///
/// 소유권과 영역
/// - 소유권은 이 값을 사용, 관리할 권한이 있는지
/// - 영역은 이 값이 현재 어느 영역에 있는지
/// -> 영역이 변경되면 소유권도 자연스럽게 변경됨
/// -> sending 키워드는 영역을 변경하면서 소유권도 같이 변경함
///
/// Actor와 Sending
/// - Actor에 값을 할당한다고 해서 자동으로 sending이 되는 것은 아님
/// -> 파라미터나 반환타입에 sending을 명시해야만 소유권이 변경됨
/// - Actor에 값을 대입하는 경우 그 값이 actor영역에 Connected 되는 것
///
/// + 추가 개념
/// - 서로 다른 actor 간에 값을 교환할 때에는 아래와 같은 규칙을 지켜야함
/// -> 값이 sendable을 준수해야함
/// -> sendable을 준수하지 않는 경우 sending으로 소유권을 이전하여 사용해야 함

class Box{}
func exampleBox() {
    let box = Box() // Disconnected & exampleBox()
    print(box) // 소유권이 있기 때문에 사용 가능 & exampleBox() 내부 영역
    processBox(box) // box에 대한 소유권 상실 & exampleBox() -> processBox() 영역으로 변경
    //print(box) // 오류 발생 (소유권이 없음) & 영역 다름
}

func processBox(_ box: sending  Box) {
    // box를 Disconnected 상태로 전달받음
    print(box)
}

class MyData {}
actor MyActor {
    private var data: MyData = .init()
    
    init(data: MyData) {
        self.data = data
    }
    
    func sendData(_ data: sending MyData) {
        self.data = data
    }
    
//    func sendData(_ data: MyData) { // sendable 타입이 아닌 타입을 다른 actor로 전달할 때는 sending 키워드를 무조건 사용해야함
//        self.data = data
//    }
}
