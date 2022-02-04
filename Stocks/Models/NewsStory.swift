import Foundation

struct NewsStory : Codable {
    let category: String
    let datetime: Int
    let headline: String
    let id: Int
    let image : String
    let related: String
    let source: String
    let summary : String
    let url: String 
}
