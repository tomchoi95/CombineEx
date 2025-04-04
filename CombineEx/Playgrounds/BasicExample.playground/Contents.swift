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
