import Foundation

/// TypedThrows
///
/// Swift6 이전에는 함수가 어떤 에러를 방출할 지 알 수 없었음
/// Swift6에 도입된 TypedThrows를 사용하면 특정 에러 타입을 명시할 수 있음
/// -> 함수가 내뱉는 Error 타입을 정할 수 있게 됨

enum ProcessError: Error {
    case fileNotFound
    case randomError
}

extension String: @retroactive Error {}
func processFile1() throws -> String {
    throw "에러 발생"
}

func processFile2() throws(ProcessError) -> String {
    // throw "에러 발생" // 에러 발생
    throw .fileNotFound
}

/// TypedThrows이 도입되기 전에는 값과 Error를 Result, Task로 변환할 때 Error 타입 정보가 손상되었음
/// -> Any Error로 내뱉었기 때문에 무조건 타입캐스팅을 해야했음
/// - TypedThrows이 도입되고 나서는 Error 타입 자체를 지정하기 때문에 해당 문제가 없어짐
/// - Error 타입을 지정할 수 있게 되면서 명확성을 높이고, 특정 에러에 대한 처리가 쉬워짐
/// + 기존 Any Error는 런타임에서 Error 정보를 확인하기 때문에 오버헤드가 발생할 수 있는데, TypedThrows를 사용할 경우 컴파일 시 정보를 확인하여 오버헤드가 줄어들 수 있음

func reloadFile() throws(ProcessError) -> Bool {
    if Bool.random() {
        return true
    } else {
        throw .randomError
    }
}

func reloadProcess() -> Result<Bool, ProcessError> {
    do {
        let tryResult = try reloadFile()
        return .success(tryResult)
    } catch {
        return .failure(error) // swift6부터는 바로 사용할 수 있지만, 6 이전에는 분기처리가 필요함 (AnyError를 주기 때문)
    }
}

/// TypedThrows은 상황에 맞게 사용해야 함
/// - API에서 구체적인 Error 타입을 정할 경우 API 발전에 저해될 수 있음
/// -> Error 타입이 변경될 수 있는 유연성을 유지해야할 때는 UntypedThrows가 좋을 수 있음
