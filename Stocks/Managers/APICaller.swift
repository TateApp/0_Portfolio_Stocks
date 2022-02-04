import Foundation

final class APICaller  {
    
static let shared = APICaller()
    
private init() {}
    private struct Constants {
        static let apiKey = "c7tepo2ad3i8dq4u1go0"
        static let sandboxApiKey = "sandbox_c7tepqiad3i8dq4u1gq0"
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day : TimeInterval = 3600 * 24
    }
    private enum EndPoint : String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case finanicalMetrics = "stock/metric"
    }
    
    public func search (query: String, completion: @escaping (Result<SearchReponse, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        request(url: url(endpoint: .search, queryParams: ["q": safeQuery ]), expecting: SearchReponse.self, completion: completion)
        
                
    }
    public func news( type: NewsViewController._Type, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        
        switch type {
        case .topStories:
            let url  = url(endpoint: .topStories, queryParams: ["category": "general"])
            
            request(url: url, expecting: [NewsStory].self, completion: completion)
        case .company(symbol: let symbol):
            let today = Date().addingTimeInterval(-(Constants.day ))
            let oneMonthBacK = today.addingTimeInterval(-(Constants.day * 30))
            let url  = url(endpoint: .companyNews, queryParams: ["symbol": symbol, "from" :  DateFormatter.newsDateFormatter.string(from: oneMonthBacK), "to" :  DateFormatter.newsDateFormatter.string(from: today),])
            
            request(url: url, expecting: [NewsStory].self, completion: completion)
        }

    }
  public func marketData(symbol : String, numberOfDays: Int, completion: @escaping (Result<MarketDataReponse, Error>) -> Void) {
      let today = Date()
      let prior = today.addingTimeInterval(-(Constants.day * Double(numberOfDays)))
      let url  = url(endpoint: .marketData, queryParams: ["symbol": symbol, "resolution" : "1", "from" :  "\(Int(prior.timeIntervalSince1970))", "to" :  "\(Int(today.timeIntervalSince1970))",])
      
      request(url: url, expecting: MarketDataReponse.self, completion: completion)
      
    }
    public func financialMetrics(symbol: String , completion: @escaping (Result<FinancialMetricsReponse, Error>) -> Void) {
        let url  = url(endpoint: .finanicalMetrics, queryParams: ["symbol": symbol, "metric" : "all"])
        
        request(url: url, expecting: FinancialMetricsReponse.self, completion: completion)
    }
    private func url(endpoint: EndPoint, queryParams: [String : String] = [:]) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        var queryItems = [URLQueryItem]()
        
      
        for (name , value ) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        queryItems.append(.init(name: "token", value: Constants.apiKey))
    
        urlString += "?" + queryItems.map {"\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        print(urlString)
        return URL(string: urlString)
    }
    private enum APIError: Error {
        case noDataRecieved
        case invalidURL
        
    }
    private func request<T: Codable>(
        url: URL?,
     expecting: T.Type,
     completion: @escaping (Result<T, Error>) -> Void) {
         guard let url = url else {
             
             //Invalid URL
             
             return
         }
         let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
             
         
             guard let data = data , error == nil else {
                 if let error = error {
                     completion(.failure(error))
                 } else {
//                     completion(.failure(error))
                 }
                 return
             }
             do {
                 let result = try JSONDecoder().decode(expecting, from: data)
                 completion(.success(result))
                 
             } catch {
                 completion(.failure(APIError.invalidURL))
             }
         })
         task.resume()
    }
}
