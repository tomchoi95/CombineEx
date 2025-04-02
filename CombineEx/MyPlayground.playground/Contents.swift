import Combine

let pizzaToppings: Publishers.Sequence<[String], Never> = ["Peperoni", "Mushrooms", "Onions", "Salami", "Bacon", "Extra cheese", "Black olives", "Green peppers"].publisher

// sequence를 publisher로 만들음.
// 타입은 Publishers.Sequence<[String], Never>임.
