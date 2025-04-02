import Combine

let pizzaToppings: Publishers.Sequence<[String], Never> = ["Peperoni", "Mushrooms", "Mushrooms","Mushrooms", "Onions", "Salami", "Bacon", "Extra cheese", "Black olives", "Green peppers"].publisher

// sequence를 publisher로 만들음.
// 타입은 Publishers.Sequence<[String], Never>임.
// 이걸 구독하고, 데이터를 받아서 print해 보자.

pizzaToppings
    .removeDuplicates()
    .sink { print($0) }

// sink는 데이터를 구독하는 함수. 
// removeDuplicates 연산자?는 연속된 값? 데이터?를 무시할 수 있음.
