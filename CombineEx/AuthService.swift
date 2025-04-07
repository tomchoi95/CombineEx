//
//  AuthService.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-07.
//

import Foundation
import Combine

enum APIError: LocalizedError {
    case invalidRequestError(String)
}

enum NetworkError: Error {
    case invalidRequestError(String)
    case transportError(Error)
    case serverError(statusCode: Int)
    case decodingError(Error)
    case noData
}

struct UserNameAvailableMessage: Codable {
    let isAvailable: Bool
    let userName: String
}

actor AuthService {
    // Old School
    func checkUserNameAvailableOldSchool(userName: String, completion: @Sendable @escaping (Result<Bool, NetworkError>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8080/isUserNameAvailable?userName=\(userName)") else {
            completion(.failure(.invalidRequestError("URL invalid")))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(.transportError(error)))
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let userAvailableMessage = try decoder.decode(UserNameAvailableMessage.self, from: data)
                completion(.success(userAvailableMessage.isAvailable))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
    
    // Combine
    func checkUserNameAvailableNaive(userName: String) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: "http://127.0.0.1:8080/isUserNameAvailable?userName=\(userName)") else {
            return Fail(error: APIError.invalidRequestError("URL invalid")).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: UserNameAvailableMessage.self, decoder: JSONDecoder())
            .map(\.isAvailable)
            .eraseToAnyPublisher()
            
    }
}
