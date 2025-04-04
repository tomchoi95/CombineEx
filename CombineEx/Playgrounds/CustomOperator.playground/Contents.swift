import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
// MARK: - Triplicate 커스텀 연산자 구현
// 스트림의 각 요소를 세 번 반복하는 연산자

extension Publishers {
    // 1. Publisher 구조체 정의
    struct Triplicate<Upstream: Publisher>: Publisher {
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        
        private let upstream: Upstream
        
        init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        // 2. Publisher 프로토콜 구현
        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .flatMap { value -> AnyPublisher<Output, Failure> in
                    // 각 값을 세 번 반복
                    return Publishers.Sequence(sequence: [value, value, value])
                        .setFailureType(to: Failure.self)
                        .eraseToAnyPublisher()
                }
                .subscribe(subscriber)
        }
    }
}

// 3. Publisher에 확장 메서드 추가
extension Publisher {
    func triplicate() -> Publishers.Triplicate<Self> {
        return Publishers.Triplicate(upstream: self)
    }
}

// MARK: - 사용 예시

// 테스트용 Publisher 생성
let subject = PassthroughSubject<Int, Never>()

// triplicate 연산자 적용
let subscription = subject
    .triplicate()
    .sink { value in
        print("받은 값: \(value)")
    }

// 값 전송
print("===== triplicate 연산자 테스트 =====")
subject.send(1)
print("---")
subject.send(42)
print("---")
subject.send(100)

// 배열에도 적용 가능
print("\n===== 배열에 적용한 triplicate 연산자 테스트 =====")
let numbers = [5, 10]
let arraySubscription = numbers.publisher
    .triplicate()
    .collect()
    .sink { values in
        print("원본 배열: \(numbers)")
        print("변환 결과: \(values)")
    }

// 문자열에도 적용 가능
print("\n===== 문자열에 적용한 triplicate 연산자 테스트 =====")
let stringSubscription = "ABC".publisher
    .triplicate()
    .collect()
    .map { String($0) }
    .sink { result in
        print("원본 문자열: ABC")
        print("변환 결과: \(result)")
    }

// 스트림에서 특정 조건에 맞는 값만 변환
print("\n===== 조건부 triplicate 연산자 테스트 =====")
let mixedNumbers = [1, 2, 3, 4, 5]
let conditionalSubscription = mixedNumbers.publisher
    .filter { $0 % 2 == 0 } // 짝수만 선택
    .triplicate()
    .collect()
    .sink { values in
        print("원본 배열: \(mixedNumbers)")
        print("짝수만 세 번 반복: \(values)")
    }

// 구독 유지를 위한 저장
let subscriptions = [subscription, arraySubscription, stringSubscription, conditionalSubscription]
