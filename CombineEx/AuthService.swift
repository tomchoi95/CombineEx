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
    case transportError(Error)
    case invalidResponse
    case validationError(String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
            case .invalidRequestError(let message):
                return "Invalid request: \(message)"
            case .transportError(let error):
                return "Transport error: \(error)"
            case .invalidResponse:
                return "Invalid response"
            case .validationError(let reason):
                return "Validation Error \(reason)"
            case .decodingError:
                return "The server returned data in an unexpected format. Try updating the app."
        }
    }
}

struct APIErrorMessage: Decodable {
    var error: Bool
    var reason: String
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
            .mapError { APIError.transportError($0)}
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
                
                if (200..<300).contains(httpResponse.statusCode) {
                    return data
                } else {
                    let decoder = JSONDecoder()
                    let apiError = try decoder.decode(APIErrorMessage.self, from: data)
                    
                    if httpResponse.statusCode == 400 {
                        throw APIError.validationError(apiError.reason)
                    }
                    throw APIError.invalidResponse
                }
            }
            .decode(type: UserNameAvailableMessage.self, decoder: JSONDecoder())
            .map(\.isAvailable)
            .eraseToAnyPublisher()
            
    }
}
