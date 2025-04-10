//
//  Publisher+retry.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-08.
//

import Combine

extension Publisher {
    func retry() -> AnyPublisher<Output, Failure> {
        self
            .retry(3)
            .eraseToAnyPublisher()
    }
}
