//
//  Collect.swift
//
//
//  Created by 최범수 on 2025-04-06.
//
/*
 문제: 온라인 쇼핑몰 주문 묶음 처리 시스템
 
 주어진 주문 데이터 스트림에서 다음과 같은 처리를 수행하세요:
 
 1. 모든 주문을 수집하여 한 번에 처리하는 "일괄 처리" 기능 구현
 2. 주문을 2개씩 묶어서 "묶음 배송" 목록으로 처리
 3. 각 카테고리별로 주문을 그룹화하여 "카테고리별 통계" 작성
 
 Combine의 collect 연산자를 사용하여 구현하세요.
 */

import Foundation
import Combine

public class CollectOperator {
    // 주문 데이터 모델
    struct Order: Decodable, Hashable {
        let id: String
        let productName: String
        let category: String
        let price: Int
        let quantity: Int
        let timestamp: Date
    }
    
    // JSON 데이터
    let jsonString = """
[
  {"id": "ORD-001", "productName": "스마트폰", "category": "전자기기", "price": 850000, "quantity": 1, "timestamp": "2025-04-01T09:30:00Z"},
  {"id": "ORD-002", "productName": "노트북", "category": "전자기기", "price": 1250000, "quantity": 1, "timestamp": "2025-04-01T10:15:00Z"},
  {"id": "ORD-003", "productName": "이어폰", "category": "전자기기", "price": 95000, "quantity": 2, "timestamp": "2025-04-01T11:45:00Z"},
  {"id": "ORD-004", "productName": "책상", "category": "가구", "price": 150000, "quantity": 1, "timestamp": "2025-04-02T14:20:00Z"},
  {"id": "ORD-005", "productName": "의자", "category": "가구", "price": 75000, "quantity": 3, "timestamp": "2025-04-02T15:10:00Z"},
  {"id": "ORD-006", "productName": "커피머신", "category": "주방용품", "price": 220000, "quantity": 1, "timestamp": "2025-04-03T09:05:00Z"},
  {"id": "ORD-007", "productName": "전기밥솥", "category": "주방용품", "price": 125000, "quantity": 1, "timestamp": "2025-04-03T10:30:00Z"},
  {"id": "ORD-008", "productName": "태블릿", "category": "전자기기", "price": 450000, "quantity": 1, "timestamp": "2025-04-03T16:45:00Z"}
]
"""
    var cancellables: Set<AnyCancellable> = []
    
    // JSON 데이터를 디코딩하는 Publisher 생성
    lazy var ordersPublisher = Just(jsonString)
        .tryMap { string -> Data in
            if let data = string.data(using: .utf8) {
                return data
            } else {
                throw NSError(domain: "JSONError", code: 1, userInfo: nil)
            }
        }
        .tryMap { data -> [Order] in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Order].self, from: data)
        }
        .map { orders -> AnyPublisher<Order, Never> in
            Publishers.Sequence<[Order], Never>(sequence: orders).eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    
    public init() {
        // 1. 모든 주문을 수집하여 한 번에 처리 - collect() 연산자 사용
       ordersPublisher
            .collect()
            .sink(receiveCompletion: {_ in} ) { collection in
                print("===== 일괄 처리 주문 목록 (총 \(collection.count)건) =====")
                collection.forEach { order in
                    print("\(order.id): \(order.productName) - \(order.price.formatted(.number))원")
                }
                print("총 주문 금액: \(collection.reduce(0, { first, second in first + second.price * second.quantity }).formatted(.number))원\n")
            }
            .store(in: &cancellables)

        // 2. 주문을 2개씩 묶어서 처리 - collect(2) 연산자 사용
        ordersPublisher
            .collect(2)
            .sink(receiveCompletion: {_ in}) { collection in
                print("배송 묶음 [\(collection.map(\.id).joined(separator: ", "))]")
                collection.forEach { item in
                    print("- \(item.productName) (\(item.quantity)개)")
                }
               print("")
            }
            .store(in: &cancellables)
        
        // 3. 카테고리별로 주문 그룹화 - collect()와 함께 Dictionary 그룹핑 사용
       
            
        /**
         실행 결과는 다음과 같아야 합니다:
         
         ===== 일괄 처리 주문 목록 (총 8건) =====
         ORD-001: 스마트폰 - 850,000원
         ORD-002: 노트북 - 1,250,000원
         ...
         ORD-008: 태블릿 - 450,000원
         총 주문 금액: 3,490,000원
         
         ===== 묶음 배송 주문 =====
         배송 묶음 [ORD-001, ORD-002]
         - 스마트폰 (1개)
         - 노트북 (1개)
         
         배송 묶음 [ORD-003, ORD-004]
         - 이어폰 (2개)
         - 책상 (1개)
         ...
         
         ===== 카테고리별 주문 통계 =====
         전자기기 카테고리:
         - 주문 건수: 4건
         - 총 상품 수량: 5개
         - 총 금액: 2,645,000원
         
         가구 카테고리:
         - 주문 건수: 2건
         - 총 상품 수량: 4개
         - 총 금액: 375,000원
         
         주방용품 카테고리:
         - 주문 건수: 2건
         - 총 상품 수량: 2개
         - 총 금액: 345,000원
         */
    }
}

let collect = CollectOperator()
