import Combine
import Foundation


// MARK: - 1. 기본적인 커스텀 Publisher (인터벌 기반)

// 일정 간격으로 값을 생성하는 커스텀 Publisher
final class IntervalPublisher: Publisher {
    typealias Output = Int
    typealias Failure = Never
    
    private let startValue: Int
    private let count: Int
    private let interval: TimeInterval
    private let scheduler: DispatchQueue
    
    init(
        startValue: Int = 0,
        count: Int = 10,
        interval: TimeInterval = 1.0,
        scheduler: DispatchQueue = .main
    ) {
        self.startValue = startValue
        self.count = count
        self.interval = interval
        self.scheduler = scheduler
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        // 구독 로직을 담당할 구독 객체 생성
        let subscription = IntervalSubscription(
            subscriber: subscriber,
            startValue: startValue,
            count: count,
            interval: interval,
            scheduler: scheduler
        )
        
        // 구독 시작
        subscriber.receive(subscription: subscription)
    }
}

// IntervalPublisher용 구독 객체
final class IntervalSubscription<S: Subscriber>: Subscription where S.Input == Int, S.Failure == Never {
    private var subscriber: S?
    private var startValue: Int
    private var current: Int
    private var count: Int
    private var interval: TimeInterval
    private var scheduler: DispatchQueue
    private var timer: DispatchSourceTimer?
    private var demand: Subscribers.Demand = .none
    
    init(
        subscriber: S,
        startValue: Int,
        count: Int,
        interval: TimeInterval,
        scheduler: DispatchQueue
    ) {
        self.subscriber = subscriber
        self.startValue = startValue
        self.current = startValue
        self.count = count
        self.interval = interval
        self.scheduler = scheduler
    }
    
    func request(_ demand: Subscribers.Demand) {
        guard demand > 0, self.timer == nil else { return }
        self.demand += demand
        
        // 타이머 생성
        let timer = DispatchSource.makeTimerSource(queue: scheduler)
        timer.schedule(deadline: .now(), repeating: interval)
        
        timer.setEventHandler { [weak self] in
            guard let self = self, let subscriber = self.subscriber else { return }
            
            guard self.demand > 0 else { return }
            
            // 최대 카운트에 도달했거나 구독이 취소된 경우
            if self.current >= self.startValue + self.count {
                subscriber.receive(completion: .finished)
                self.cancel()
                return
            }
            
            // 값 전달
            let newDemand = subscriber.receive(self.current)
            self.demand += newDemand
            self.demand -= 1
            self.current += 1
        }
        
        // 타이머 시작
        timer.resume()
        self.timer = timer
    }
    
    func cancel() {
        timer?.cancel()
        timer = nil
        subscriber = nil
    }
}

// MARK: - 2. 배열 기반 커스텀 Publisher

// 배열 요소를 변환하여 발행하는 커스텀 Publisher
struct TransformingArrayPublisher<Element, Output, Failure: Error>: Publisher {
    let array: [Element]
    let transform: (Element) -> Output?
    
    init(array: [Element], transform: @escaping (Element) -> Output?) {
        self.array = array
        self.transform = transform
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = TransformingArraySubscription<Element, Output, Failure, S>(
            subscriber: subscriber,
            array: array,
            transform: transform
        )
        subscriber.receive(subscription: subscription)
    }
}

// TransformingArrayPublisher용 구독 객체
final class TransformingArraySubscription<Element, Output, Failure: Error, S: Subscriber>: Subscription
where S.Input == Output, S.Failure == Failure {
    private var subscriber: S?
    private let array: [Element]
    private let transform: (Element) -> Output?
    private var index = 0
    
    init(subscriber: S, array: [Element], transform: @escaping (Element) -> Output?) {
        self.subscriber = subscriber
        self.array = array
        self.transform = transform
    }
    
    func request(_ demand: Subscribers.Demand) {
        var remainingDemand = demand
        
        while let subscriber = self.subscriber, remainingDemand > 0, index < array.count {
            let element = array[index]
            index += 1
            
            // 변환 시도
            if let output = transform(element) {
                let newDemand = subscriber.receive(output)
                remainingDemand += newDemand
                remainingDemand -= 1
            }
        }
        
        // 모든 항목을 처리한 경우
        if index >= array.count {
            subscriber?.receive(completion: .finished)
            subscriber = nil
        }
    }
    
    func cancel() {
        subscriber = nil
    }
}

// MARK: - 3. 네트워크 요청 커스텀 Publisher

// URL 요청 결과를 발행하는 커스텀 Publisher
struct NetworkPublisher<Output>: Publisher {
    typealias Failure = Error
    
    let url: URL
    let transform: (Data) throws -> Output
    
    init(url: URL, transform: @escaping (Data) throws -> Output) {
        self.url = url
        self.transform = transform
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 에러 체크
            if let error = error {
                subscriber.receive(completion: .failure(error))
                return
            }
            
            // 응답 코드 체크
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                subscriber.receive(completion: .failure(URLError(.badServerResponse)))
                return
            }
            
            // 데이터 체크
            guard let data = data else {
                subscriber.receive(completion: .failure(URLError(.cannotDecodeContentData)))
                return
            }
            
            // 데이터 변환
            do {
                let output = try transform(data)
                _ = subscriber.receive(output)
                subscriber.receive(completion: .finished)
            } catch {
                subscriber.receive(completion: .failure(error))
            }
        }
        
        // 구독 객체 생성 및 태스크 시작
        let subscription = NetworkSubscription(subscriber: subscriber, task: task)
        subscriber.receive(subscription: subscription)
        task.resume()
    }
}

// NetworkPublisher용 구독 객체
final class NetworkSubscription<S: Subscriber>: Subscription where S.Failure == Error {
    private var subscriber: S?
    private var task: URLSessionDataTask?
    
    init(subscriber: S, task: URLSessionDataTask) {
        self.subscriber = subscriber
        self.task = task
    }
    
    func request(_ demand: Subscribers.Demand) {
        // URLSessionDataTask는 demand와 관계없이 한 번만 실행됨
    }
    
    func cancel() {
        task?.cancel()
        task = nil
        subscriber = nil
    }
}

// MARK: - 사용 예시

// 1. 인터벌 Publisher 사용
print("===== 인터벌 Publisher 테스트 =====")
let intervalPub = IntervalPublisher(startValue: 1, count: 5, interval: 0.5)

let subscription1 = intervalPub
    .sink(receiveCompletion: { completion in
        print("완료: \(completion)")
    }, receiveValue: { value in
        print("값 수신: \(value)")
    })

// 2. 변환 배열 Publisher 사용
print("\n===== 변환 배열 Publisher 테스트 =====")
let numbers = [1, 2, 3, 4, 5]
let transformPub = TransformingArrayPublisher<Int, String, Error>(array: numbers) { num -> String? in
    guard num % 2 == 0 else { return nil }  // 짝수만 변환
    return "짝수: \(num)"
}

let subscription2 = transformPub
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("변환 완료")
        case .failure(let error):
            print("변환 오류: \(error.localizedDescription)")
        }
    }, receiveValue: { value in
        print("변환 결과: \(value)")
    })

// 3. 네트워크 Publisher 사용
print("\n===== 네트워크 Publisher 테스트 =====")

// JSON 응답을 파싱하기 위한 구조체
struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

// JSON 데이터를 Post로 변환하는 네트워크 Publisher
let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
let networkPub = NetworkPublisher<Post>(url: url) { data -> Post in
    let decoder = JSONDecoder()
    return try decoder.decode(Post.self, from: data)
}

let subscription3 = networkPub
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("네트워크 요청 완료")
        case .failure(let error):
            print("네트워크 오류: \(error.localizedDescription)")
        }
    }, receiveValue: { post in
        print("포스트 수신:")
        print("제목: \(post.title)")
        print("내용: \(post.body)")
    })

// 모든 구독 유지
let subscriptions = [subscription1, subscription2, subscription3]

// Playground에서 비동기 작업이 완료될 수 있도록 충분한 시간 유지

