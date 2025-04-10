//
//  Publisher+Dump.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-08.
//

import Foundation
import Combine

extension Publisher {
    func dump() -> AnyPublisher<Self.Output, Self.Failure> {
        self.handleEvents(receiveRequest:  { value in
            Swift.dump(value)
        })
        .eraseToAnyPublisher()
    }
}
