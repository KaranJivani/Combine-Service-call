
import Foundation
import Combine

enum NetworkServiceError: Error {
    case invalidURL
    case decodingError(String)
    case genericError(String)
    case invalidResponseCode(Int)
    
    var errorMessageString: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .decodingError:
            return "Decoding error"
        case .genericError(let message):
            return message
        case .invalidResponseCode(let responseCode):
            return "Invalid response"
        }
    }
}

final class CombineNetworkService {
    
    let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func getPublisherForResponse<T: Decodable>(endpoint: String) -> AnyPublisher<T, NetworkServiceError> {
        
        guard let url = URL(string: endpoint) else {
            return Fail(error: NetworkServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200..<300) ~= httpResponse.statusCode else {
                        throw NetworkServiceError.invalidResponseCode(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                if let decodingError = error as? DecodingError {
                    return NetworkServiceError.decodingError((decodingError as NSError).debugDescription)
                }
                return NetworkServiceError.genericError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
