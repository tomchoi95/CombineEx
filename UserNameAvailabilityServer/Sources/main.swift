// The Swift Programming Language
// https://docs.swift.org/swift-book

import Vapor
import Dispatch

// 응답 구조체 정의
struct UsernameResponse: Content {
    let isAvailable: Bool
    let userName: String
}

// 에러 응답 구조체 정의
struct ErrorResponse: Content {
    let error: Bool
    let reason: String
}

// 사용 불가능한 사용자 이름 목록
let unavailableUsernames = ["jmbae", "johnnyappleseed", "page", "johndoe", "tomchoi", "TomChoi"]

// 유지보수 카운터
var maintenanceCounter = 0

// 서버 실행 함수
func runServer() async throws {
    // Vapor 애플리케이션 생성
    let app = try await Application.make()
    defer { app.shutdown() }
    
    // 포트 설정
    app.http.server.configuration.port = 8080
    
    // 라우트 설정
    app.get("isUserNameAvailable") { req -> Response in
        // 쿼리 파라미터에서 userName 가져오기
        guard let username = req.query[String.self, at: "userName"] else {
            return try await ErrorResponse(error: true, reason: "Missing userName parameter")
                .encodeResponse(status: .badRequest, for: req)
        }
        
        // 요청 로깅
        app.logger.info("Checking availability for username: \(username)")
        
        // 금지된 사용자 이름 확인
        if ["admin", "superuser"].contains(username) {
            return try await ErrorResponse(error: true, reason: "Username is not valid: \(username).")
                .encodeResponse(status: .badRequest, for: req)
        }
        
        // 서버 에러 시뮬레이션
        if username == "servererror" {
            return try await ErrorResponse(error: true, reason: "The database is corrupted")
                .encodeResponse(status: .internalServerError, for: req)
        }
        
        // 유지보수 에러 시뮬레이션
        if username == "maintenance" {
            maintenanceCounter += 1
            if maintenanceCounter % 3 != 0 {
                return try await ErrorResponse(error: true, reason: "Temporarily unavailable for maintenance")
                    .encodeResponse(status: .serviceUnavailable, headers: ["Retry-After": "120"], for: req)
            }
        }
        
        // 항상 유지보수 에러
        if username == "maintenance!" {
            return try await ErrorResponse(error: true, reason: "Temporarily unavailable for maintenance")
                .encodeResponse(status: .serviceUnavailable, headers: ["Retry-After": "120"], for: req)
        }
        
        // 잘못된 응답 형식 시뮬레이션
        if username == "illegalresponse" {
            return try await UsernameResponse(isAvailable: false, userName: username)
                .encodeResponse(for: req)
        }
        
        // 사용자 이름이 비어있는지 확인
        if username.isEmpty {
            return try await ErrorResponse(error: true, reason: "userName 이 비어있습니다.")
                .encodeResponse(status: .badRequest, for: req)
        }
        
        // 사용자 이름이 3자 이상인지 확인
        if username.count < 3 {
            return try await ErrorResponse(error: true, reason: "userName은 최소 3자 이상이어야 합니다.")
                .encodeResponse(status: .badRequest, for: req)
        }
        
        // 사용자 이름이 사용 불가능한 목록에 있는지 확인
        let isAvailable = !unavailableUsernames.contains(username)
        
        // 응답 반환
        return try await UsernameResponse(isAvailable: isAvailable, userName: username)
            .encodeResponse(for: req)
    }

    // 서버 시작 정보 출력
    print("Starting username availability server at http://127.0.0.1:8080")
    print("Available endpoints:")
    print("  GET http://127.0.0.1:8080/isUserNameAvailable?userName=<username>")
    print("\nUnavailable usernames for testing:")
    for name in unavailableUsernames {
        print("  - \(name)")
    }
    print("\n서버를 중지하려면 Ctrl+C를 누르세요.")

    // 서버 실행
    try await app.run()
}

// 비동기 실행
Task {
    do {
        try await runServer()
    } catch {
        print("오류 발생: \(error)")
    }
}
// 메인 스레드 유지
RunLoop.main.run()

