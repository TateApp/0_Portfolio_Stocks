import UIKit

protocol NewsCellPressed {
    func newsCellPressed(url: String)
    
}
class NewsViewController: UIViewController {
    var protocolVar : NewsCellPressed?
    let tableView = UITableView()
    
    enum _Type {
        case topStories
    case company(symbol: String)
        var title: String {
        switch self {
        case .topStories:
            return "Top Stories"
        case .company(symbol: let symbol):
            return symbol.uppercased()
        }
        }
    }
    
    var stories = [NewsStory]()
    var _type : _Type?
    init(type: _Type) {
        
        super.init(nibName: nil, bundle: nil)
        _type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        setupTableView()
        
        fetchNews()
        
    }
    func setupTableView () {
        
    
    self.view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifer)
        tableView.backgroundColor = .clear
}
    func open(url: URL) {
        
    }
    func fetchNews() {
        APICaller.shared.news(type: .topStories, completion: { result in

            switch result {
            case .success(let newsStory):
                DispatchQueue.main.async {
                    self.stories = newsStory
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print(error)

            }

        })

    }
    func getLatestClosingPrice( data: [CandleStick] ) -> String {
         let closingPrice = data.first?.close
       
        return "\(closingPrice)"
        
    }
    func getChangePercentage(data: [CandleStick]) ->  Double {
 
        let priorDate = Date().addingTimeInterval(-((3600 * 24) * 2))
        print(priorDate)
        
        let latestClose = data.first!.close
        var priorClose = data[1].close
        
        print("Current: \(latestClose) | Prior: \(priorClose)")
        print("Percentage Difference: \(latestClose / priorClose)")
        if latestClose / priorClose > 1.0 {
            print("Should be green")
        } else {
            print("Should be red")
        }
        return latestClose / priorClose
    }
    
}
extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
        
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        protocolVar?.newsCellPressed(url: stories[indexPath.row].url)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifer, for: indexPath) as! NewsCell
        cell.configure(newsStore: stories[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    
}
