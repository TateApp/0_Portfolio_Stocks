import UIKit

class NewsHeaderView : UITableViewHeaderFooterView {
    static let identifier = "NewsHeaderView"
    static let preferredHeight : CGFloat = 70
    
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    let label = UILabel()
    let button = UIButton(type: .system)
    public func configure(viewModel: ViewModel) {
        self.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        label.text = viewModel.title
        
        self.contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        button.setTitle("+ WatchList", for: .normal)
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.isHidden = viewModel.shouldShowAddButton
        button.addTarget(self, action: #selector(buttonpressed(sender:)), for: .touchUpInside)
    }
    @objc func buttonpressed(sender: UIButton) {
        
    }
}
