import UIKit

class NewsCell: UITableViewCell {
    
    static let identifer = "NewsCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let image = CustomImageView()
    let sourceLabel = UILabel()
    let mainLabel = UILabel()
    let dateLabel = UILabel()
    func configure(newsStore: NewsStory) {
        self.contentView.addSubview(sourceLabel)
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        sourceLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        sourceLabel.text = newsStore.source
        sourceLabel.textColor = .white
        sourceLabel.font = .boldSystemFont(ofSize: 10)
        self.contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        dateLabel.text = "\(Date.init(timeIntervalSince1970: Double(newsStore.datetime)))"
        dateLabel.textColor = .white
        
        self.contentView.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalToConstant: 120).isActive = true
        image.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        image.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        image.loadImage(with: newsStore.image)
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        
        self.contentView.addSubview(mainLabel)
        self.mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.text = newsStore.summary
        mainLabel.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 10).isActive = true
        mainLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        mainLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -10).isActive = true
        mainLabel.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -10).isActive = true
        mainLabel.numberOfLines = .max
        mainLabel.textColor = .white
        mainLabel.font = .boldSystemFont(ofSize: 15)
     
    }
}
