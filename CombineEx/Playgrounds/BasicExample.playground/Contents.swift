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

print("------------------------------------------- 다음은 배열을 발행 할 거고, 배열을 받아봅시다. -------------------------------------------")

let pizzaToppings: Publishers.Sequence<[String], Never> = [
    "Pepperoni", "Mushrooms", "Onions",
    "Salami", "Bacon", "Extra cheese",
    "Black olives", "Green peppers"
].publisher

pizzaToppings.sink { competion in
    switch competion {
        case .finished:
            print("I'm done my job")
        case .failure(let error):
            print("I failed")
    }
} receiveValue: { input in
    print(input)
}
.store(in: &cancellables)

print("------------------------------------------- CurrentValueSubject -------------------------------------------")

let currentValueSubjectPublisher: CurrentValueSubject<Double, Never> = .init(20)
// 현재값 즉, 마지막 값을 항상 쥐고 있음. 그래서 구독 시에 쥐고 있는 값이 떨어지고 시작.

currentValueSubjectPublisher
    .dropFirst() // 하지만 이 메서드를 사용한다면 초기값 한 번을 버릴 수 있음.
    .sink(receiveValue: { print($0) })
    .store(in: &cancellables)

(0..<10).forEach { number in
    currentValueSubjectPublisher.send(Double(number))
}

let passthroughSubjectPublisher: PassthroughSubject<Int, Never> = .init()


print("------------------------------------------- PassthroughSubject -------------------------------------------")

passthroughSubjectPublisher
    .sink(receiveValue: { print($0) })
    .store(in: &cancellables)

// 이 친구는 구독 시에 마지막 값을 던지고 시작하지 않음.

(0..<10).forEach { number in
    passthroughSubjectPublisher.send(number)
}

print("------------------------------------------- assign -------------------------------------------")

class Profile {
    let name: String
    @Published var age: Int
    var cancellable: Set<AnyCancellable> = []
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
        reaction()
    }
    
    func reaction() {
        $age.sink { int in
            print("나 이제 \(int)로 바뀜.")
        }.store(in: &cancellable)
    }
}

let tomProfile = Profile(name: "Tom", age: 30)

passthroughSubjectPublisher
    .assign(to: \.age, on: tomProfile)
    .store(in: &cancellables)

(0..<10).forEach { number in
    passthroughSubjectPublisher.send(number)
}
