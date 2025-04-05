import Combine
import Foundation

class CustomSubscriber<Input, Failure: Error>: Subscriber {
    // Subscriber를 채택. Input, Failure, receieve method를 정의해야함.
//    typealias Input = Int
//    typealias Failure = Never
    
    func receive(subscription: any Subscription) {
        print("연결되었습니다.")
        subscription.request(.unlimited)
        // 아래의 print구문은 모든 데이터가 지나가고 불리는 것을 알 수 있음.
        // func receive(completion: Subscribers.Completion<Never>) 의 completion보다 나중에 실행되는 것을 볼 수 있음.
        print("마지막에 끝나고 찍히는듯.")
        // 위의 함수는 subscriber가 pub에 연결될 때 호출이 됨.
        // 여기서 받은 파라메터는 Subscription의 프로토콜을 채택함.
        // 따라서 func request(Subscribers.Demand) 가 구현되어 있어야 함.
        // 이 메서드는 Subscribers.Demand를 파라메터로 받아야 하는 걸 알 수 있음.
        //         subscription.request(.none)
        //         subscription.request(.unlimited)
        //         subscription.request(.max(<#T##value: Int##Int#>))
        // 위와 같이 3개의 옵션? 이 있고, .none은 알람을 받지 않겠다. 라는 의미.. 이럴거면 왜...?
        // .unlimited는 이름과 같이 무조건적으로 다 받을 것.
        // .max()는 갯수 제한을 둠.
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        print(input)
        // 여기에선 수신하게 되는 값을 어떻게 처리할지 처리 흐름을 정의할 수 있음.
        
        return .max(1)
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        print("이건 뭘까? - third")
        switch completion {
            case .finished:
                print("who's the first?")
            case .failure(let failure):
                print("who's the first?")

        }
    }
    
}


let customSubscriber = CustomSubscriber<Int, Never>()
[100, 200, 300].publisher.subscribe(customSubscriber)
// 100, 200 ,300의 3개의 값을 방출하고 어떻게 받아낼 지 확인 해 보자.

