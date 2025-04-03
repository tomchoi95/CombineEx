//
//  File.swift
//  
//
//  Created by 최범수 on 2025-04-04.
//

import Foundation
import Combine

public class PizzaExample {
    let pizzaToppings: Publishers.Sequence<[String], Never> = ["Peperoni", "Mushrooms", "Onions", "Salami", "Bacon", "Extra cheese", "Black olives", "Green peppers"].publisher
    
    public func subscribe() {
        pizzaToppings.sink { topping in
                print("topping is \(topping)")
        }
    }
    
    public init() {}
}
