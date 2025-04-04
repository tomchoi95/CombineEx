import Combine
import Foundation

class CustomSubscriber: Subscriber {
    // Subscriber를 채택. Input, Failure, receieve method를 정의해야함.
    typealias Input = Int
    typealias Failure = Never
    
    
    func receive(subscription: any Subscription) {
        print("이건 뭘까? - first")
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        print("이건 뭘까? - second")
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("이건 뭘까? - third")
    }
    
}


let customSubscriber = CustomSubscriber()
[100, 200, 300].publisher.subscribe(customSubscriber)
// 100, 200 ,300의 3개의 값을 방출하고 어떻게 받아낼 지 확인 해 보자.
