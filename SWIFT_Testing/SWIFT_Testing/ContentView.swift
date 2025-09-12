//
//  ContentView.swift
//  SWIFT_Testing
//
//  Created by 이윤수 on 9/12/25.
//

import SwiftUI

/// 본 앱은 SwiftTesting을 학습하기 위한 프로젝트 입니다.
/// SWIFT_TestingTests > SWIFT_TestingTests.swift 파일에 학습 내용이 적혀있습니다.

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
