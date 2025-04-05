/**
 문제 설명:
 
 Combine을 활용하여 정수를 배치(batch) 단위로 처리하는 CustomSubscriber를 구현해보세요. 이 subscriber는 publisher로부터 전달받은 정수들을 미리 지정한 배치 크기만큼 모았다가, 배치가 완성되면 다음과 같이 처리해야 합니다.
 
 배치 수집:
 subscriber 내부에 배열(예: [Int])을 선언하여 입력되는 값을 저장합니다.
 배치 크기를 상수로 지정합니다. (예: let batchSize = 3)
 
 배치 처리:
 배열에 저장된 요소의 개수가 batchSize에 도달하면, 해당 배치를 처리합니다.
 처리 예시: 배치에 포함된 정수들의 합을 계산하여 출력하고, 배치 배열을 비웁니다.
 
 마지막 미완성 배치 처리:
 publisher가 완료(completion)되었을 때, 만약 배치 배열에 아직 미처리된 값이 있다면 해당 배치도 처리해야 합니다.
 
 backpressure 제어:
 receive(subscription:)에서 처음에 .max(batchSize) 만큼의 demand를 요청하고,
 배치 처리 후에는 다음 배치를 위해 다시 .max(batchSize) 만큼의 demand를 요청하도록 구현해 보세요.
 
 예시 시나리오:
 
 Publisher가 [10, 20, 30, 40, 50, 60, 70]를 순차적으로 방출한다고 가정하면,
 첫 번째 배치: [10, 20, 30] → 합: 60
 두 번째 배치: [40, 50, 60] → 합: 150
 마지막 배치: [70] → 합: 70
 */

import Foundation
import Combine

class Sub: Subscriber {
    
    typealias Input = Int
    typealias Failure = Never
    
    
    private var arrayWillBeSummed: [Int] = []
    private var isFull: Bool { arrayWillBeSummed.count == 3 }
    private let batchSize = 3
    
    func receive(subscription: any Subscription) {
        print("Sub will be startd")
        subscription.request(.max(batchSize)) // 초기에 몇개를 받을지 결정. 3개를 받고 스타트를 할 예정.
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        arrayWillBeSummed.append(input)
        
        if isFull {
            print(arrayWillBeSummed.reduce(0) { $0 + $1 } )
            arrayWillBeSummed.removeAll()
            return .max(batchSize)
        } else {
            return .none
        }
        
    }
    
    
    func receive(completion: Subscribers.Completion<Never>) {
        switch completion {
            case .finished:
                print(arrayWillBeSummed.reduce(0) { $0 + $1 } )
            case .failure(let failure):
                fatalError(failure.localizedDescription)
        }
    }
}

let pub = [10, 20, 30, 40, 50, 60, 70].publisher
pub.receive(subscriber: Sub())
