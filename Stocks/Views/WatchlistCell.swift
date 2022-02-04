import UIKit

class WatchlistCell : UITableViewCell {
    static let identifier = "WatchlistCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
    }
    let symbolLabel = UILabel()
    let typeLabel = UILabel()
    let descriptionLabel = UILabel()
    let latestCloseLabel = UILabel()
    let percentageDropLabel = UILabel()
    
    func configureCell(searchViewModel: SearchViewModel) {
        self.contentView.addSubview(symbolLabel)
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -10).isActive = true
        symbolLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        symbolLabel.text = searchViewModel.searchResult.symbol
        symbolLabel.textColor = .white
        symbolLabel.font = .boldSystemFont(ofSize: 15)
        
        self.contentView.addSubview(typeLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 10).isActive = true
        typeLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        typeLabel.text = searchViewModel.searchResult.type
        typeLabel.textColor = .systemGray3
        typeLabel.font = .systemFont(ofSize: 12)
        
        self.contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: symbolLabel.trailingAnchor, constant: 10).isActive = true
        descriptionLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -10).isActive = true
        descriptionLabel.text = searchViewModel.searchResult.description
        descriptionLabel.textColor = .systemGray3
        descriptionLabel.font = .systemFont(ofSize: 12)
        
        self.contentView.addSubview(latestCloseLabel)
        latestCloseLabel.translatesAutoresizingMaskIntoConstraints = false
        latestCloseLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
        latestCloseLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        latestCloseLabel.textColor = .white
        latestCloseLabel.font = .boldSystemFont(ofSize: 15)
        latestCloseLabel.text = getLatestClosingPrice(data: searchViewModel.candleStrick)
        
        self.contentView.addSubview(percentageDropLabel)
        percentageDropLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageDropLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 10).isActive = true
        percentageDropLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        percentageDropLabel.textColor = .white
        percentageDropLabel.font = .boldSystemFont(ofSize: 15)
        percentageDropLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        percentageDropLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        let value = Double(latestCloseLabel.text!)! - (Double(latestCloseLabel.text!)! * getChangePercentage(data: searchViewModel.candleStrick))
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
        
    }
    func getLatestClosingPrice( data: [CandleStick] ) -> String {
         let closingPrice = data.first?.close
       
        return "\(closingPrice ?? 0)"
        
    }
    func getChangePercentage(data: [CandleStick]) ->  Double {
 
        let priorDate = Date().addingTimeInterval(-((3600 * 24) * 2))
        print(priorDate)
        
        let latestClose = data.first!.close
        
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
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
