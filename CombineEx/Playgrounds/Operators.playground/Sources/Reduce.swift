//
//  Reduce.swift
//
//
//  Created by 최범수 on 2025-04-06.
//
/*
 문제: 온라인 쇼핑몰 매출 집계 및 분석 시스템
 
 주어진 주문 데이터 스트림에서 다음과 같은 처리를 수행하세요:
 
 1. 총 매출액 계산: 모든 주문의 총 금액을 계산
 2. 카테고리별 최고가 상품 찾기: 각 카테고리에서 가장 비싼 상품 식별
 3. 주문 수량 통계: 전체 주문 수량 및 평균 주문 가격 계산
 
 Combine의 reduce 연산자를 사용하여 구현하세요.
 */

import Foundation
import Combine

public class ReduceOperator {
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
        // 1. 총 매출액 계산 - reduce() 연산자 사용
        ordersPublisher
            .handleEvents(receiveRequest:  { _ in
                print("===== 총 매출액 계산 =====")
            })
            .reduce(0, { $0 + $1.price * $1.quantity } )
            .sink(receiveCompletion: { _ in },
                  receiveValue: { total in
                print("총 매출액: \(total.formatted(.number))원\n")
            })
            .store(in: &cancellables)
        
        // 2. 카테고리별 최고가 상품 찾기 - collect()와 Dictionary grouping 연산자 조합 사용
        ordersPublisher
            .handleEvents(receiveRequest:  { _ in
                print("===== 카테고리별 최고가 상품 =====")
            })
            .collect()
            .tryMap { orders -> [String: Order] in
                let orderedDict = Dictionary(grouping: orders) { $0.category }
                return orderedDict.mapValues { ordersInCategory in // [Order] 여기서 최댓값을 가지는 order로 매핑해야 함.
                    guard let maxVal = ordersInCategory.max(by: { $0.price < $1.price }) else { fatalError() }
                    return maxVal
                }
            }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { dict in
                dict.forEach { (key: String, value: Order) in
                    print("\(key) 카테고리 최고가 상품: \(value.productName) - \(value.price.formatted(.number))원")
                }
                print("")
            })
            .store(in: &cancellables)
        
        // 3. 주문 수량 통계 - reduce() 연산자를 이용한 복합 통계 계산
       
        
        /**
         실행 결과는 다음과 같아야 합니다:
         
         ===== 총 매출액 계산 =====
         총 매출액: 3,460,000원
         
         ===== 카테고리별 최고가 상품 =====
         전자기기 카테고리 최고가 상품: 노트북 - 1,250,000원
         가구 카테고리 최고가 상품: 책상 - 150,000원
         주방용품 카테고리 최고가 상품: 커피머신 - 220,000원
         
         ===== 주문 수량 통계 =====
         총 주문 건수: 8건
         총 상품 수량: 11개
         평균 주문 가격: 432,500원
         상품당 평균 가격: 314,545원
         */
    }
} 
