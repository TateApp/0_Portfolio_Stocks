//
//  ViewController.swift
//  Stocks
//
//  Created by Tate Wrigley on 30/01/2022.
//

import UIKit
struct SearchViewModel {
    var searchResult: SearchResult
    var candleStrick : [CandleStick]
}
class MainViewController: UIViewController, UISearchBarDelegate, DragViewState , NewsCellPressed ,ReloadWatchlist{
    func reload() {
        self.vc.fetchData()
        self.vc.tableView.reloadData()
    }
    func viewDismissed() {
       
     
    }
    func newsCellPressed(url: String) {
        let vc = WebViewController(url: url)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    let activityView = UIActivityIndicatorView()
    
    func dragViewState(state: String) {
        if state == "top" {
            UIView.animate(withDuration: 0.5, animations: {
                self.searchBar.alpha = 0
                
            })
            _state = state
        }
        if state == "middle" {
            UIView.animate(withDuration: 0.5, animations: {
                self.searchBar.alpha = 1
               
            })
            _state = state
        }
        if state == "bottom" {
            UIView.animate(withDuration: 0.5, animations: {
                self.searchBar.alpha = 1
            
            })
            _state = state
        }
    }
    func didBeginDragging() {
        UIView.animate(withDuration: 0.5, animations: {

            self.newsViewController.view.alpha = 1
        })
        if _state != "bottom" {
            topStories.text = "Top Stories"
        } else {
            topStories.text = "Business News"
        }
    }
    func didEndDragging() {
        if _state != "bottom" {
            topStories.text = "Top Stories"
        } else {
            topStories.text = "Business News"
        }
        if _state == "bottom" {
            UIView.animate(withDuration: 0.5, animations: {

                self.newsViewController.view.alpha = 0
            })
        }
       
    }
    var _state = ""
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            UIView.animate(withDuration: 0.5, animations: {
                self.vc.view.alpha = 0
                self.tableView.alpha = 1
                self.activityView.alpha = 1
                self.activityView.startAnimating()
            })
            finalModel = [SearchViewModel]()
            tableView.reloadData()
            searchTimer?.invalidate()
            
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
                APICaller.shared.search(query: searchText, completion: { result in
                    switch result {
                    case.success(let response ):
                        print(response.result)
                     
                        DispatchQueue.main.async {
                            self.model = response.result
                            self.fetchData()
                        }
                    case.failure(let error):
                        print(error)
                    }
                })
            })
        } else {
            self.model = [SearchResult]()
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.5, animations: {
                self.vc.view.alpha = 1
                self.tableView.alpha = 0
            })
         
        }
       
      
    }
    var finalModel = [SearchViewModel]()
    func fetchData() {
        activityView.alpha = 1
        activityView.startAnimating()
        let group = DispatchGroup()
        finalModel = [SearchViewModel]()
        for index in 0...model.count - 1 {
            
            group.enter()
            APICaller.shared.marketData(symbol: model[index].symbol, numberOfDays: 7, completion: {
                result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let marketResponse):
                    self.finalModel.append(SearchViewModel(searchResult: self.model[index], candleStrick: marketResponse.candleSticks))
                case .failure(let error):
                    print(error)
                }
            })
        }
        group.notify(queue: .main, execute: {
            self.activityView.alpha = 0
            self.activityView.stopAnimating()
            self.tableView.reloadData()
        })
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.5, animations: {
            searchBar.showsCancelButton = true
            self.vc.view.alpha = 0
            self.tableView.alpha = 1
            
        })

    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.5, animations: {
        searchBar.showsCancelButton = false
            searchBar.text = ""
            self.vc.view.alpha = 1
            self.tableView.alpha = 0
        })
    }
    var model  = [SearchResult]()
    var candleSticks = [[CandleStick]]()
    var searchTimer  : Timer?
    let searchBar = UISearchBar()
    let cancelButton = UIButton(type: .system)
    let dragView = DragView()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .black
        
        setupViews()
        
        setupSearchBar()
        
        setupWatchList()
        
        setupTableView()
        
        setupDragView()
        
       
        self.view.addSubview(activityView)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityView.color = .white
        
        print(CoreDataManager.shared.persistentContainer)
     
    }
  
    let stocksLabel = UILabel()
    
    let dateLabel = UILabel()
    
    func setupViews() {
//        Calendar.current.dateComponents([.day, .year, .month], from: date)
        
        self.view.addSubview(stocksLabel)
        stocksLabel.translatesAutoresizingMaskIntoConstraints = false
        stocksLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        stocksLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        stocksLabel.text = "Stocks"
        stocksLabel.textColor = .white
        stocksLabel.font = .boldSystemFont(ofSize: 20)
        
        self.view.addSubview(dateLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.topAnchor.constraint(equalTo: self.stocksLabel.bottomAnchor, constant: 10).isActive = true
        
        dateLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        
     
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        let nameOfMonth = dateFormatter.string(from: now)
  
        dateLabel.text = "\(nameOfMonth)"
        
        dateLabel.textColor = .systemGray3
        
        dateLabel.font = .boldSystemFont(ofSize: 20)
    }
    let vc = WatchListViewController()
    let watchListLabel = UILabel()
    
    func setupWatchList() {
        self.view.addSubview(watchListLabel)
        watchListLabel.translatesAutoresizingMaskIntoConstraints = false
        watchListLabel.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 10).isActive = true
        watchListLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        watchListLabel.text = "Watch List"
        watchListLabel.textColor = .white
        watchListLabel.font = .boldSystemFont(ofSize: 25)
        
        self.addChild(vc)
        vc.didMove(toParent: self)
        self.view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: self.watchListLabel.bottomAnchor).isActive = true
        vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        vc.protocolVar = self
        
    }
    func setupSearchBar() {
        self.view.addSubview(searchBar)
        searchBar.delegate = self
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: self.dateLabel.safeAreaLayoutGuide.bottomAnchor, constant: 10).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 70).isActive = true
        searchBar.backgroundColor = .black
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = false
        searchBar.searchTextField.backgroundColor = .init(rbg: 30, green: 30, blue: 30, alpha: 1)
        searchBar.searchTextField.textColor = .white
    }
    let tableView = UITableView(frame: .zero, style: .plain)
    func setupTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.identifier)
        tableView.backgroundColor = .black
        tableView.alpha = 0
    }
    let newsViewController = NewsViewController(type: .topStories)
    let topStories = UILabel()
    
    func setupDragView() {
        self.view.addSubview(dragView)
        dragView.frame = .init(x: 0, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        dragView.delegate = self
    
        self.dragView.addSubview(topStories)
        topStories.translatesAutoresizingMaskIntoConstraints = false
        topStories.topAnchor.constraint(equalTo: dragView.topAnchor, constant: 20).isActive = true
        topStories.leadingAnchor.constraint(equalTo: dragView.leadingAnchor, constant: 10).isActive = true
        topStories.text = "Business News"
        topStories.font = .boldSystemFont(ofSize: 20)
        topStories.textColor = .white
        self.addChild(newsViewController)
        newsViewController.didMove(toParent: self)
        self.dragView.addSubview(newsViewController.view)
        newsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        newsViewController.view.topAnchor.constraint(equalTo: dragView.topAnchor,constant: 50).isActive = true
        newsViewController.view.leadingAnchor.constraint(equalTo: self.dragView.leadingAnchor).isActive = true
        newsViewController.view.trailingAnchor.constraint(equalTo: self.dragView.trailingAnchor).isActive = true
        newsViewController.view.bottomAnchor.constraint(equalTo: self.dragView.bottomAnchor).isActive = true
        self.newsViewController.view.alpha = 0
        newsViewController.protocolVar = self
    }


}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath) as! SearchCell
        cell.configureCell(searchViewModel: finalModel[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalModel.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
