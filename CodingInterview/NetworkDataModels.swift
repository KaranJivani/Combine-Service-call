
import Foundation

struct MemberResponse: Codable {
    var data: [Member]?
}

struct Member: Codable {
    var id: Int?
    var name: String?
    var email: String?
    var gender: String?
    var status: String?
}

