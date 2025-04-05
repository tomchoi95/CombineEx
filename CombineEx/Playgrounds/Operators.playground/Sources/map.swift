//
//  map.swift
//
//
//  Created by 최범수 on 2025-04-05.
//
/*
 문제: 온라인 쇼핑몰 주문 시스템
 
 다음 JSON 데이터가 API에서 반환되었습니다. 이 데이터는 주문 목록을 나타냅니다.
 주문 ID만 추출하여 출력하는 코드를 작성하세요.
 그리고 모든, 주문 금액에 배송비 3000원을 더한 최종 금액을 계산하여 출력하세요.
 
 Combine의 map 연산자를 사용하여 구현하세요.
 */

import Foundation
import Combine

public class MapOperator {
    // 주문 데이터 모델
    struct Order: Decodable {
        let id: String
        let productName: String
        let price: Int
        let quantity: Int
    }
    
    // JSON 데이터
    let jsonString = """
[
  {"id": "ORD-001", "productName": "스마트폰", "price": 850000, "quantity": 1},
  {"id": "ORD-002", "productName": "노트북", "price": 1250000, "quantity": 1},
  {"id": "ORD-003", "productName": "이어폰", "price": 220000, "quantity": 2}
]
"""
    var cancellables: Set<AnyCancellable> = []
    // JSON 데이터를 디코딩하는 Publisher 생성
    lazy var ordersPublisher = Just(jsonString)
        .compactMap { $0.data(using: .utf8) }
        .decode(type: [Order].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    
    public init () {
        // 1. map 연산자를 사용하여 주문 ID만 추출하여 출력하세요
        ordersPublisher
            .map { orders -> [String] in
                orders.map { $0.id }
            }
            .sink { _ in
                
            } receiveValue: { ids in
                print(ids)
            }.store(in: &cancellables)
        
        // 2. map 연산자를 사용하여 각 주문의 총액(가격 * 수량 + 배송비 3000원)을 계산하여 출력하세요
    }
}
