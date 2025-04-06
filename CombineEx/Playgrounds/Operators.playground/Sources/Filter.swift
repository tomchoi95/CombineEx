//
//  Filter.swift
//  
//
//  Created by 최범수 on 2025-04-05.
//
/*
 문제: 온라인 쇼핑몰 주문 필터링 시스템
 
 주어진 주문 데이터에서 다음 조건에 맞는 주문만 필터링하는 코드를 작성하세요.
 
 1. 10만원 이상인 주문만 필터링하여 "고가 주문" 목록으로 출력
 2. 수량이 2개 이상인 주문만 필터링하여 "대량 주문" 목록으로 출력
 3. "전자기기" 카테고리에 속한 상품 주문만 필터링하여 출력
 
 Combine의 filter 연산자를 사용하여 구현하세요.
 */

import Foundation
import Combine

public class FilterOperator {
    // 주문 데이터 모델
    struct Order: Decodable {
        let id: String
        let productName: String
        let category: String
        let price: Int
        let quantity: Int
    }
    
    // JSON 데이터
    let jsonString = """
[
  {"id": "ORD-001", "productName": "스마트폰", "category": "전자기기", "price": 850000, "quantity": 1},
  {"id": "ORD-002", "productName": "노트북", "category": "전자기기", "price": 1250000, "quantity": 1},
  {"id": "ORD-003", "productName": "이어폰", "category": "전자기기", "price": 95000, "quantity": 2},
  {"id": "ORD-004", "productName": "책상", "category": "가구", "price": 150000, "quantity": 1},
  {"id": "ORD-005", "productName": "의자", "category": "가구", "price": 75000, "quantity": 3},
  {"id": "ORD-006", "productName": "커피머신", "category": "주방용품", "price": 220000, "quantity": 1}
]
"""
    var cancellables: Set<AnyCancellable> = []
    
    // JSON 데이터를 디코딩하는 Publisher 생성
    lazy var ordersPublisher = Just(jsonString)
        .compactMap { $0.data(using: .utf8) }
        .decode(type: [Order].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    
    public init() {
        // 1. 10만원 이상인 주문만 필터링 - filter 연산자 사용
        ordersPublisher
            .map { orders in
                orders.filter { order in
                    order.price * order.quantity >= 100_000
                    
                }
            }
            .sink { completion in
                switch completion {
                    case .failure(let e):
                        print(e)
                    case .finished:
                        print("1번 문제 종료.\n")
                }
            } receiveValue: { orders in
                orders.forEach { order in
                    let total = order.price * order.quantity
                    print("\(order.id): \(order.productName) (\(total.formatted(.number))원)")
                }
            }
            .store(in: &cancellables)

        // 2. 수량이 2개 이상인 주문만 필터링 - filter 연산자 사용
        ordersPublisher
            .map { orders in
                orders.filter { $0.quantity >= 2}
            }
            .sink { completion in
                switch completion {
                    case .failure(let e):
                        print(e)
                    case .finished:
                        print("2번 문제 종료.\n")
                }
            } receiveValue: { orders in
                orders.forEach { order in
                    print("\(order.id): \(order.productName) (\(order.quantity)개)")
                }
            }
            .store(in: &cancellables)
        
        // 3. "전자기기" 카테고리에 속한 상품 주문만 필터링 - filter 연산자 사용
        ordersPublisher
            .map { orders in
                orders.filter { $0.category == "전자기기"}
            }
            .sink { completion in
                switch completion {
                    case .failure(let e):
                        print(e)
                    case .finished:
                        print("3번 문제 종로.")
                }
            } receiveValue: { orders in
                orders.forEach { order in
                    print("\(order.id): \(order.productName)")
                }
            }
            .store(in: &cancellables)
        /**
         필터링 결과는 다음과 같이 나와야 합니다:
         10만원 이상인 주문 (고가 주문):
         ORD-001: 스마트폰 (850,000원)
         ORD-002: 노트북 (1,250,000원)
         ORD-004: 책상 (150,000원)
         ORD-006: 커피머신 (220,000원)
         수량이 2개 이상인 주문 (대량 주문):
         ORD-003: 이어폰 (2개)
         ORD-005: 의자 (3개)
         "전자기기" 카테고리 주문:
         ORD-001: 스마트폰
         ORD-002: 노트북
         ORD-003: 이어폰
         */
    }
    
}

