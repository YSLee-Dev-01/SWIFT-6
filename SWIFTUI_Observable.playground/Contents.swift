import SwiftUI

/// 하단 내용은 Swift5.9부터 적용된 기능입니다.
/// @Observable
///
/// 기존 ObservableObject
/// - 객체에서 발생하는 속성 변화에 View가 업데이트 되었는데, 그 값을 View에서 사용하지 않더라도 View가 다시 렌더링 됐음
/// - 옵셔널 객체, 컬렉션 객체가 트래킹 되지 않았음
/// - 추적을 원하는 프로퍼티에는 모두 @Published 키워드를 붙여야 했음
///
/// @Observable
/// - iOS17(Swift5.9)부터 도입된 매크로로 SwiftUI에서 데이터 변화를 관찰하는데 효율적인 방법을 제공함
/// - Class에서만 사용할 수 있고, 구독 가능한 Class가 되어 속성이 변경되면 View를 업데이트 함
///
/// @Observable는
/// - 실제로 View에서 사용 중인 값만 렌더링됨 (사용 중인 부분만 렌더링)
/// - 옵셔널 객체, 컬렉션 객체가 트래킹 가능함 (컬렉션의 경우 변경된 아이템만 렌더링)
/// - @Published 키워드를 붙이지 않고 모든 값을 추적함
/// -> 추적을 원하지 않는 경우 @ObservationIgnored를 붙임

class OldViewModel: ObservableObject {
    @Published var name = "ABC"
    @Published var old = 25
}

struct OldView: View {
    @StateObject var viewModel: OldViewModel = .init()
    var body: some View {
        VStack {
            Text("\(viewModel.name)")
            Button {
                viewModel.old += 1 // old를 증가시켰지만, name도 다시 렌더링됨
            } label: {
                Text("나이 증가")
            }

        }
    }
}

@Observable class NewViewModel {
    var name = "ABC"
    var old = 25
}

struct NewView: View {
    @State var viewModel: NewViewModel = .init()
    var body: some View {
        VStack {
            Text("\(viewModel.name)")
            Button {
                viewModel.old += 1 // name을 다시 렌더링 시키지 않음
            } label: {
                Text("나이 증가")
            }

        }
    }
}

/// @Observable를 사용할 때는 View에서 사용하는 방식도 변경됨
///
/// 기존 ObservableObject
/// - @StateObject로 객체를 생성하고, 외부에서 받을 때는 @ObservedObject로 사용
///
/// @Observable
/// - @State로 생성하고, 외부에서 받을 때는 일반 객체로 받음 (Binding이 필요 없을 때)
///
/// @State, @StateObject
/// - iOS17 이전에는 @State가 값 타입만 사용이 가능했음 (참조타입은 @StateObject 사용)
/// - iOS17 이후로는 참조 타입도 @State를 사용할 수 있도록 확장됨 (@Observable 클래스로 인해 가능해짐)
/// -> @Observable 키워드가 붙은 클래스는 Observation 프레임워크가 변경 감지를 지원함
/// -> @State 래퍼가 매커니즘을 인식해서 클래스 인스턴스를 저장소에 넣고 추적이 가능해진 것
///
/// @State 값을 외부에서 받을 때는 별다른 프로퍼티 래퍼가 없더라도, @Observable 처리된 객체이기 때문에 알아서 트레킹 (렌더링) 하게됨
/// - 다만, 기존 @ObservedObject로 받을 경우 각 속성에 Binding을 제공했음
/// - 일반 객체를 받을 경우 @Observable가 되어 있어도 Binding을 제공하지는 않음
/// -> @Observable의 인스턴스를 넘기는 것이 아닌 그 속성을 넘기는 것이기 때문
/// -> 해당 속성의 binding이 필요할 때 (TextField, Toggle)는 @Bindable 프로퍼티 래퍼를 사용해야함
///
/// @Bindable
/// - @Observable, Environment로 표기된 객체의 각 속성들에 Binding 처리를 해주는 프로퍼티 래퍼
/// -> 외부에서 @Observable 값을 받아 사용할 때 Binding이 필요한 경우 @Bindable 프로퍼티 래퍼를 사용함
///  + 참조타입으로 만들어진 객체가 Binding으로 변화한 것을 View에게 알려야 할 때도 사용
///  ex) View에 그리고 있는 타입이 컬렉션 형태의 참조타입일 때, Binding이 필요한 SwiftUI View를 사용할 때

@Observable class Data: Identifiable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

struct ParentView: View {
    @State var viewModel = NewViewModel()
    @State var list = [Data(name: "A"), Data(name: "B"), Data(name: "C")]
    
    var body: some View {
        VStack {
            Text("부모 View")
            ChildView(viewModel: viewModel)
            
            ForEach(self.list, id: \.name) { data in
                @Bindable var newData = data
                
                TextField(text: $newData.name) {
                    Text("데이터 입력")
                }
            }
        }
    }
}

struct ChildView: View {
    @Bindable var viewModel: NewViewModel
    
    var body: some View {
        TextField(text: $viewModel.name) {
            Text("이름 입력")
        }
    }
}
