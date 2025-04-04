import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let numbersPublisher = [1, 2, 3, 4, 5].publisher

let squaredNumber = numbersPublisher.map { number in
    number * number
}.sink { number in
    print(number)
}
