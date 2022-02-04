import Foundation


struct SearchReponse: Codable {
    let count : Int
    let result : [SearchResult]
}
struct SearchResult : Codable {
    var description: String
    var displaySymbol: String
    var symbol: String
    var type: String
}
