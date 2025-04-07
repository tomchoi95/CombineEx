// The Swift Programming Language
// https://docs.swift.org/swift-book

import Vapor
import Dispatch

// 응답 구조체 정의
struct UsernameResponse: Content {
    let isAvailable: Bool
    let userName: String
}

// 사용 불가능한 사용자 이름 목록
let unavailableUsernames = ["jmbae", "johnnyappleseed", "page", "johndoe", "tomchoi", "TomChoi"]

// 서버 실행 함수
func runServer() async throws {
    // Vapor 애플리케이션 생성
    let app = try await Application.make()
    defer { app.shutdown() }
    
    // 포트 설정
    app.http.server.configuration.port = 8080
    
    // 라우트 설정
    app.get("isUserNameAvailable") { req -> UsernameResponse in
        // 쿼리 파라미터에서 userName 가져오기
        guard let username = req.query[String.self, at: "userName"] else {
            throw Abort(.badRequest, reason: "Missing userName parameter")
        }
        
        // 요청 로깅
        app.logger.info("Checking availability for username: \(username)")
        
        // 사용자 이름이 사용 불가능한 목록에 있는지 확인
        let isAvailable = !unavailableUsernames.contains(username)
        
        // 응답 반환
        return UsernameResponse(
            isAvailable: isAvailable,
            userName: username
        )
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

