import Foundation
import PlaygroundSupport
import Combine

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables: Set<AnyCancellable> = []
// 하나의 값만 발행하는 publisher
let disposablePublisher = Just("Hi There!")
//    .eraseToAnyPublisher()
// 이 publisher는 무조건 성공울 보장하고, 성공값을 보여주는 것 같다.
// 그렇다면 이 publisher를 구독해 보자.

disposablePublisher.sink { completion in
    switch completion {
        case .finished:
            print("finished")
        case .failure(let e):
            print("I never fail, that's how i set")
    }
} receiveValue: { input in
    print(input)
}.store(in: &cancellables)
// 갑자기 궁금해짐. cancellables을 print해 보자.



enum TomError: Error {
    case somethingWrong
}

// 그럼 무조건 실패하는 경우도 있겠네? 무조건 실패를 해 보자.
let verifiedFailPublisher = Fail(outputType: TomError.self, failure: TomError.somethingWrong).eraseToAnyPublisher()

verifiedFailPublisher.sink { completion in
    switch completion {
        case .finished :
            print("It will never happen, maybe?")
        case .failure(let error):
            print(error)
    }
} receiveValue: { sth in
    print(sth)
}.store(in: &cancellables)

