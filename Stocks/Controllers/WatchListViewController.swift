import UIKit

class WatchListViewController: UIViewController, ReloadWatchlist {
    func viewDismissed() {
        print("Dismissed")
    }
    
    func reload() {

        fetchData()
        tableView.reloadData()
    }
    
    var protocolVar : ReloadWatchlist?
    var tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
 
        
        fetchData()
        
 
        
        setupTableView()
        
        setupWatchlistLabel()
        

    }
    var symbols = [SearchResult]()
    var model  = [SearchResult]()
    var finalModel = [SearchViewModel]()
   public func fetchData() {
        print("Fetch Data Launched")
      symbols = [SearchResult]()
      model  = [SearchResult]()
      finalModel = [SearchViewModel]()
        symbols = CoreDataManager.shared.fetchSymbols()
        if symbols.count > 0 {
            self.watchListLabel.alpha = 0
            self.watchListSubLabel.alpha = 0
            let group = DispatchGroup()
            
            finalModel = [SearchViewModel]()
            
            for index in 0...symbols.count - 1 {
                
                group.enter()
                APICaller.shared.marketData(symbol: symbols[index].symbol, numberOfDays: 7, completion: {
                    result in
                    defer {
                        group.leave()
                    }
                    switch result {
                    case .success(let marketResponse):
                        self.finalModel.append(SearchViewModel(searchResult: SearchResult(description: self.symbols[index].description, displaySymbol: self.symbols[index].displaySymbol, symbol: self.symbols[index].symbol, type: self.symbols[index].type), candleStrick: marketResponse.candleSticks))
                    case .failure(let error):
                        print(error)
                    }
                })
            }
            group.notify(queue: .main, execute: {
             
                self.tableView.reloadData()
            })
        } else {
            print("Is Empty")
            self.watchListLabel.alpha = 1
            self.watchListSubLabel.alpha = 1
        }
    }
    func setupTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.register(WatchlistCell.self, forCellReuseIdentifier: WatchlistCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        
    }
    
    let watchListLabel = UILabel()
    let watchListSubLabel = UILabel()

    
    func setupWatchlistLabel() {
        self.view.addSubview(watchListLabel)
        watchListLabel.translatesAutoresizingMaskIntoConstraints = false
        watchListLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100).isActive = true
        watchListLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        watchListLabel.text = "Watchlist Is Empty..."
        watchListLabel.textColor = .white
        watchListLabel.font = .systemFont(ofSize: 20)
        watchListLabel.textAlignment = .center
     
        self.view.addSubview(watchListSubLabel)
        watchListSubLabel.translatesAutoresizingMaskIntoConstraints = false
        watchListSubLabel.centerYAnchor.constraint(equalTo: self.watchListLabel.bottomAnchor, constant: 10).isActive = true
        watchListSubLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        watchListSubLabel.text = "Search For Stock To Add To list"
        watchListSubLabel.textColor = .systemGray3
        watchListSubLabel.font = .systemFont(ofSize: 15)
        watchListSubLabel.textAlignment = .center
        
        
        
       
    }
}
extension WatchListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WatchlistCell.identifier, for: indexPath) as! WatchlistCell
        cell.configureCell(searchViewModel: finalModel[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var isPartOfWatchList = false
        if CoreDataManager.shared.fetchSymbols().count > 0 {
            
        
        for index in 0...CoreDataManager.shared.fetchSymbols().count - 1 {
            if CoreDataManager.shared.fetchSymbols()[index].symbol == finalModel[indexPath.row].searchResult.symbol {
                isPartOfWatchList = true
            }
        }
        }
        let vc = FinancialViewController(symbol: finalModel[indexPath.row].searchResult, isPartOfWatchlist: isPartOfWatchList)
        vc.protocolVar = self
        
        self.present(vc, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataManager.shared.deleteSymbol(symbol: finalModel[indexPath.row].searchResult)
            finalModel.remove(at: indexPath.row)
          
            self.protocolVar?.reload()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalModel.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
