import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//// Just: 하나의 값을 발행하고 완료되는 가장 단순한 Publisher
//let helloPublisher = Just("안녕하세요")
//
//let helloSubscriber = helloPublisher.sink { value in
//  print("Hello, \(value)!")
//}
//
//// 배열을 Publisher로 변환 - 배열의 각 요소를 순차적으로 발행
//let pizzaToppings = ["Pepperoni", "Mushrooms", "Onions",
//                     "Salami", "Bacon", "Extra cheese",
//                     "Black olives", "Green peppers"].publisher
//
//pizzaToppings.sink { topping in
//  print("\(topping) is a popular topping for pizza")
//}

// CurrentValueSubject: 현재 값을 저장하고, 새 구독자에게 즉시 현재 값을 전달
// <값 타입, 에러 타입> - Never는 에러가 발생하지 않음을 의미
//let temperatureSubject = CurrentValueSubject<Double, Never>(20.0)
//
//// 온도 값을 구독
//print("첫번째 Subscriber 등록")
//let temperatureSubscription = temperatureSubject.sink { temp in
//  print("👉 온도: \(temp)°C")
//}
//
//// 새로운 값 발행
//print("온도를 변경합니다...")
//temperatureSubject.send(22.5)
//
//print("중간 온도 Subscriber 등록")
//temperatureSubject.sink { temp in
//  print("중간 온도: \(temp)°C")
//}
//
//temperatureSubject.send(25.0)
//
//print("현재 저장된 온도: \(temperatureSubject.value)°C")
//
//print("마지막 구독자 등록")
//temperatureSubject.sink { temp in
//  print("최종 온도: \(temp)°C")
//}
//
//// ===== 예제 4: PassthroughSubject - 이벤트 전달용 Publisher =====
//print("\n4️⃣ PassthroughSubject - 값을 저장하지 않는 Publisher")
//print("------------------------------------------------------")
//
//// PassthroughSubject: 값을 저장하지 않고 단순히 전달만 하는 Publisher
//let notificationSubject = PassthroughSubject<String, Never>()
//
//print("알림 메시지를 구독합니다...")
//// 알림 메시지를 구독
//let notificationSubscription = notificationSubject.sink { message in
//  print("👉 알림: \(message)")
//}
//
//// 새로운 알림 발행
//print("알림을 보냅니다...")
//
//notificationSubject.send("새로운 메시지가 도착했습니다")
//
//// 알림을 취소
//notificationSubscription.cancel()
//
//// 알림 메시지 구독을 취소했기 때문에, 이 메시지는 출력되지 않음
//notificationSubject.send("앱이 업데이트 되었습니다")
//
//print("\n5️⃣ @Published - 속성 값 변경을 자동으로 발행하기")
//print("------------------------------------------------")
//
//class WeatherStation {
//  // @Published 속성은 자동으로 Publisher를 생성합니다
//  @Published var temperature: Double = 15.0
//  @Published var weatherCondition: String = "맑음"
//}
//
//let station = WeatherStation()
//let stationTempSubscription = station.$temperature.sink { temp in
//    print("현재 온도: \(temp)")
//}
//
//let stationConditionSubscription = station.$weatherCondition.sink { condition in
//    print("날씨 상태: \(condition)")
//}

let numbersPublisher = [1, 2, 3, 4, 5, 6].publisher

let basicSink = numbersPublisher.sink { int in
    print("I received value of \(int)")
}

let completionSink = numbersPublisher.sink { completion in
    switch completion {
        case .finished:
            print("모든 값 수신 완료.")
        case .failure(let error):
            print("Error Occoured")
    }
} receiveValue: { number in
    print("값 수신: \(number)")
}

