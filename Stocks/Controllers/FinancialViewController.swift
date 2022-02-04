import UIKit
import Charts
protocol ReloadWatchlist {
    func reload()
    func viewDismissed()
}

class FinancialViewController : UIViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        protocolVar?.viewDismissed()
    }
    var protocolVar : ReloadWatchlist?
    var _symbol : SearchResult?
    var _isPartOfWatchlist = false
    init(symbol: SearchResult, isPartOfWatchlist: Bool){
        
        super.init(nibName: nil, bundle: nil)
        _isPartOfWatchlist = isPartOfWatchlist
        _symbol = symbol
    }
    var metric : Metrics?
    func fetchData() {
        let group = DispatchGroup()
        group.enter()
        APICaller.shared.financialMetrics(symbol: _symbol!.symbol, completion: { result in
            defer{
                group.leave()
            }
            switch result {
            case.success(let reponse):
                print(reponse)
                self.metric = reponse.metric
            case .failure(let error):
                print(error)
            }
            
        })
        group.enter()
        APICaller.shared.marketData(symbol: _symbol!.symbol, numberOfDays: 7, completion: { result in
            defer{
                group.leave()
            }
            switch result {
            case.success(let reponse):
                print(reponse)
                self.candleStick = reponse.candleSticks
            case .failure(let error):
                print(error)
            }
            
        })
        group.enter()
        APICaller.shared.news(type: .company(symbol: _symbol!.symbol), completion: { result in
            defer{
                group.leave()
            }
            switch result  {
            case .success(let success):
                self.stories = success
            case .failure(let failure):
                print(failure)
            }
        })
        
        group.notify(queue: .main, execute: {
            self.setupView()
        })
    }
    
   
    var candleStick = [CandleStick]()
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .init(rbg: 41, green: 41, blue: 41, alpha: 1)
        
        fetchData()

    }
    let cancelButton = UIButton(type: .system)
    let mainTitle = UILabel()
    let midTitle = UILabel()
    let subTitle = UILabel()
    let seperator = UIView()
    
    let latestCloseLabel = UILabel()
    let percentageDropLabel = UILabel()
    
    var addButton = UIButton()
   
    
    let open = UILabel()
    let openValue = UILabel()
    
    let high = UILabel()
    let highValue = UILabel()
    
    let low = UILabel()
    let lowValue = UILabel()
    
    let leftSeperator = UIView()
    
    let FiftyTwoWeekHigh = UILabel()
    let FiftyTwoWeekHighValue = UILabel()
    
    let FiftyTwoWeekLow = UILabel()
    let FiftyTwoWeekLowValue = UILabel()
    
    let warning = UILabel()
    let companyNews = UILabel()
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    var stories = [NewsStory]()
    
    var chartView = LineChartView()
    func setupView() {
        
 print(candleStick)
       
        var dataSet = [Double]()
        if candleStick.count > 0 {
            
        
        for index in 0...candleStick.count - 1 {
            dataSet.append(candleStick[index].close)
        }
        }
        self.view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cancelButton.layer.cornerRadius = 15
        cancelButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitle("X", for: .normal)
        cancelButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        cancelButton.backgroundColor = .init(rbg: 50, green: 50, blue: 50, alpha: 1)
        cancelButton.layer.shadowOpacity = 0.5
        cancelButton.layer.shadowRadius = 1
        cancelButton.layer.shadowOffset = .zero
        cancelButton.addTarget(self, action: #selector(closeButtonPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(mainTitle)
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
        mainTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        mainTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        mainTitle.text = _symbol?.symbol
        mainTitle.font = .boldSystemFont(ofSize: 25)
        mainTitle.textColor = .white
        
       
        
        self.view.addSubview(subTitle)
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.bottomAnchor.constraint(equalTo: mainTitle.bottomAnchor).isActive = true
        subTitle.leadingAnchor.constraint(equalTo: self.mainTitle.trailingAnchor, constant: 10).isActive = true
        subTitle.text = _symbol?.description
        subTitle.textColor = .systemGray3
        subTitle.font = .systemFont(ofSize: 12)
        
        self.view.addSubview(midTitle)
        midTitle.translatesAutoresizingMaskIntoConstraints = false
        midTitle.leadingAnchor.constraint(equalTo: subTitle.trailingAnchor, constant: 10).isActive = true
        midTitle.centerYAnchor.constraint(equalTo: self.subTitle.centerYAnchor).isActive = true
        midTitle.text = _symbol?.type
        midTitle.textColor = .systemGray3
        midTitle.font = .systemFont(ofSize: 12)
        
        self.view.addSubview(seperator)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.topAnchor.constraint(equalTo: subTitle.bottomAnchor, constant: 20).isActive = true
        seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        seperator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        seperator.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        seperator.backgroundColor = .white
        
        
        self.view.addSubview(latestCloseLabel)
        latestCloseLabel.translatesAutoresizingMaskIntoConstraints = false

        latestCloseLabel.textColor = .white
        latestCloseLabel.font = .boldSystemFont(ofSize: 15)
        latestCloseLabel.text = getLatestClosingPrice(data: candleStick)
        
        self.view.addSubview(percentageDropLabel)
        percentageDropLabel.translatesAutoresizingMaskIntoConstraints = false

        percentageDropLabel.textColor = .white
        percentageDropLabel.font = .boldSystemFont(ofSize: 15)
        percentageDropLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        percentageDropLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        let value = Double(latestCloseLabel.text!)! - (Double(latestCloseLabel.text!)! * getChangePercentage(data: candleStick))
        
        percentageDropLabel.layer.cornerRadius = 12.5
        percentageDropLabel.layer.masksToBounds = true
        percentageDropLabel.textAlignment = .center
        percentageDropLabel.text = "\(round(value * 100) / 100.0)"
        if value > 0 {
            percentageDropLabel.backgroundColor = .green
        } else if value == 0   {
            percentageDropLabel.backgroundColor = .white
            percentageDropLabel.textColor = .black
          
        } else {
            percentageDropLabel.backgroundColor = .red
        }
        self.view.addSubview(latestCloseLabel)
        latestCloseLabel.translatesAutoresizingMaskIntoConstraints = false
        latestCloseLabel.topAnchor.constraint(equalTo: self.seperator.bottomAnchor, constant: 20).isActive = true
        latestCloseLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        
        self.view.addSubview(percentageDropLabel)
        percentageDropLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageDropLabel.topAnchor.constraint(equalTo: self.seperator.bottomAnchor, constant: 20).isActive = true
        percentageDropLabel.leadingAnchor.constraint(equalTo: self.latestCloseLabel.trailingAnchor, constant: 20).isActive = true
        
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        if _isPartOfWatchlist == false {
            addButton.setTitle("+ Add", for: .normal)
            addButton.backgroundColor = .systemBlue
        } else {
            addButton.setTitle("- Remove", for: .normal)
            addButton.backgroundColor = .red
        }
        addButton.addTarget(self, action: #selector(addButtonPressed(sender:)), for: .touchUpInside)
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        addButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addButton.layer.cornerRadius = 10
        addButton.centerYAnchor.constraint(equalTo: self.percentageDropLabel.centerYAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        var entries = [ChartDataEntry]()
        for index in 0...candleStick.count - 1 {
            entries.append(.init(x: Double(index), y: candleStick[index].close))
        }
        let dataSet_ = LineChartDataSet(entries: entries, label: "7 Day Close")
        dataSet_.fillColor = percentageDropLabel.backgroundColor!
        dataSet_.colors = [percentageDropLabel.backgroundColor!]
        dataSet_.drawFilledEnabled = true
        dataSet_.drawIconsEnabled  = false
        dataSet_.drawValuesEnabled = false
        dataSet_.drawCirclesEnabled = false
    
        dataSet_.lineWidth = 1
     let data = LineChartData(dataSet: dataSet_)
        chartView.data = data
        
        self.view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10).isActive = true
        chartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        chartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        chartView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 4).isActive = true
        
        chartView.pinchZoomEnabled = true
        chartView.setScaleEnabled(true)
        chartView.xAxis.enabled = false
        chartView.xAxis.labelTextColor = .white
        chartView.drawGridBackgroundEnabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelTextColor = .white
        chartView.rightAxis.enabled = true
        chartView.rightAxis.labelTextColor = .white
        chartView.legend.enabled = true
        chartView.legend.textColor = .white
        self.view.addSubview(open)
        open.translatesAutoresizingMaskIntoConstraints = false
        open.topAnchor.constraint(equalTo: self.chartView.bottomAnchor, constant: 10).isActive = true
        open.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        open.text = "Open"
        open.textColor = .white
        open.font = .systemFont(ofSize: 15)
        
        self.view.addSubview(high)
        high.translatesAutoresizingMaskIntoConstraints = false
        high.topAnchor.constraint(equalTo: self.open.bottomAnchor, constant: 10).isActive = true
        high.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        high.text = "Hight"
        high.textColor = .white
        high.font = .systemFont(ofSize: 15)
        
        self.view.addSubview(low)
        low.translatesAutoresizingMaskIntoConstraints = false
        low.topAnchor.constraint(equalTo: self.high.bottomAnchor, constant: 10).isActive = true
        low.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        low.text = "Low"
        low.textColor = .white
        low.font = .systemFont(ofSize: 15)
        
        self.view.addSubview(openValue)
        openValue.translatesAutoresizingMaskIntoConstraints = false
        openValue.centerYAnchor.constraint(equalTo: self.open.centerYAnchor).isActive = true
        openValue.leadingAnchor.constraint(equalTo: self.open.trailingAnchor, constant: 10).isActive = true
        if candleStick.count > 0 {
            openValue.text = "\(candleStick[0].open.self)"
        } else {
            openValue.text = "No Open Data"
        }
     
        openValue.textColor = .white
        openValue.font = .boldSystemFont(ofSize: 15)
        
        self.view.addSubview(highValue)
        highValue.translatesAutoresizingMaskIntoConstraints = false
        highValue.centerYAnchor.constraint(equalTo: self.high.centerYAnchor).isActive = true
        highValue.leadingAnchor.constraint(equalTo: self.high.trailingAnchor, constant: 10).isActive = true
        if candleStick.count > 0 {
        highValue.text = "\(candleStick[0].high.self)"
        } else {
            highValue.text = "No High Data"
        }
        highValue.textColor = .white
        highValue.font = .boldSystemFont(ofSize: 15)
        
        self.view.addSubview(lowValue)
        lowValue.translatesAutoresizingMaskIntoConstraints = false
        lowValue.centerYAnchor.constraint(equalTo: self.low.centerYAnchor).isActive = true
        lowValue.leadingAnchor.constraint(equalTo: self.low.trailingAnchor, constant: 10).isActive = true
        if candleStick.count > 0 {
        lowValue.text = "\(candleStick[0].low.self)"
        } else {
            lowValue.text = "No Low Data"
        }
        lowValue.textColor = .white
        lowValue.font = .boldSystemFont(ofSize: 15)
        
        
    
        
        
        self.view.addSubview(leftSeperator)
        leftSeperator.translatesAutoresizingMaskIntoConstraints = false
        leftSeperator.topAnchor.constraint(equalTo: open.topAnchor).isActive = true
        leftSeperator.bottomAnchor.constraint(equalTo: low.bottomAnchor).isActive = true
        leftSeperator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        leftSeperator.leadingAnchor.constraint(equalTo: open.trailingAnchor, constant: 70).isActive = true
        
        leftSeperator.backgroundColor = .white
        
        self.view.addSubview(FiftyTwoWeekHigh)
        FiftyTwoWeekHigh.translatesAutoresizingMaskIntoConstraints = false
        FiftyTwoWeekHigh.topAnchor.constraint(equalTo: self.chartView.bottomAnchor, constant: 10).isActive = true
        FiftyTwoWeekHigh.leadingAnchor.constraint(equalTo: self.leftSeperator.leadingAnchor, constant: 10).isActive = true
        FiftyTwoWeekHigh.text = "52 Wk High"
        FiftyTwoWeekHigh.textColor = .white
        FiftyTwoWeekHigh.font = .systemFont(ofSize: 15)
        
        self.view.addSubview(FiftyTwoWeekLow)
        FiftyTwoWeekLow.translatesAutoresizingMaskIntoConstraints = false
        FiftyTwoWeekLow.topAnchor.constraint(equalTo: self.FiftyTwoWeekHigh.bottomAnchor, constant: 10).isActive = true
        FiftyTwoWeekLow.leadingAnchor.constraint(equalTo: self.leftSeperator.leadingAnchor, constant: 10).isActive = true
        FiftyTwoWeekLow.text = "52 Wk Low"
        FiftyTwoWeekLow.textColor = .white
        FiftyTwoWeekLow.font = .systemFont(ofSize: 15)
        
     
        self.view.addSubview(warning)
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.topAnchor.constraint(equalTo: self.FiftyTwoWeekLow.bottomAnchor, constant: 10).isActive = true
        warning.leadingAnchor.constraint(equalTo: self.leftSeperator.leadingAnchor, constant: 10).isActive = true
        warning.text = "Warning, This Data is indicative"
        warning.textColor = .red
        warning.font = .systemFont(ofSize: 15)
        warning.numberOfLines = .max
       
        self.view.addSubview(FiftyTwoWeekHighValue)
        FiftyTwoWeekHighValue.translatesAutoresizingMaskIntoConstraints = false
        FiftyTwoWeekHighValue.centerYAnchor.constraint(equalTo: self.FiftyTwoWeekHigh.centerYAnchor).isActive = true
        FiftyTwoWeekHighValue.leadingAnchor.constraint(equalTo: self.FiftyTwoWeekHigh.trailingAnchor, constant: 10).isActive = true
        FiftyTwoWeekHighValue.text = "\(metric?.AnnualWeekHigh ?? 0.0)"
        FiftyTwoWeekHighValue.textColor = .white
        FiftyTwoWeekHighValue.font = .boldSystemFont(ofSize: 15)
        
        self.view.addSubview(FiftyTwoWeekLowValue)
        FiftyTwoWeekLowValue.translatesAutoresizingMaskIntoConstraints = false
        FiftyTwoWeekLowValue.centerYAnchor.constraint(equalTo: self.FiftyTwoWeekLow.centerYAnchor).isActive = true
        FiftyTwoWeekLowValue.leadingAnchor.constraint(equalTo: self.FiftyTwoWeekLow.trailingAnchor, constant: 10).isActive = true
        FiftyTwoWeekLowValue.text = "\(metric?.AnnualWeekLow ?? 0.0)"
        FiftyTwoWeekLowValue.textColor = .white
        FiftyTwoWeekLowValue.font = .boldSystemFont(ofSize: 15)
        
        self.view.addSubview(companyNews)
        companyNews.translatesAutoresizingMaskIntoConstraints = false
        companyNews.topAnchor.constraint(equalTo: self.lowValue.bottomAnchor, constant: 10).isActive = true
        companyNews.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        companyNews.text = "Company News"
        companyNews.font = .boldSystemFont(ofSize: 20)
        companyNews.textColor = .white
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: companyNews.bottomAnchor, constant: 20).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifer)
        tableView.backgroundColor = .clear
        
    }
    @objc func addButtonPressed(sender: UIButton) {
        if _isPartOfWatchlist == false {
            _isPartOfWatchlist = true
            CoreDataManager.shared.appendSymbol(symbol: _symbol!)
        } else {
            _isPartOfWatchlist = false
            CoreDataManager.shared.deleteSymbol(symbol: _symbol!)
        }
        
        if _isPartOfWatchlist == false {
            addButton.setTitle("+ Add", for: .normal)
            addButton.backgroundColor = .systemBlue
        } else {
            addButton.setTitle("- Remove", for: .normal)
            addButton.backgroundColor = .red
        }
        protocolVar?.reload()
    }
    @objc func closeButtonPressed(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func getLatestClosingPrice( data: [CandleStick] ) -> String {
         let closingPrice = data.first?.close
       
        return "\(closingPrice ?? 0)"
        
    }
    func getChangePercentage(data: [CandleStick]) ->  Double {
 
        let priorDate = Date().addingTimeInterval(-((3600 * 24) * 2))
      
        
        let latestClose = data.first?.close ?? 0.0
        
        var priorClose =  0.0
        if data.count > 1 {
            priorClose = data[1].close
        }
        
 
        
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

extension FinancialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
        
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        protocolVar?.newsCellPressed(url: stories[indexPath.row].url)
        
        let vc = WebViewController(url: stories[indexPath.row].url)
        self.present(vc, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifer, for: indexPath) as! NewsCell
        cell.configure(newsStore: stories[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    
}
