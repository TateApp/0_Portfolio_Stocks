import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastImgUrlUsedToLoadImage: String?
    
    var activity = UIActivityIndicatorView(style: .medium)
    func loadImage(with urlString: String) {
        
        self.addSubview(activity)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.topAnchor.constraint(equalTo: self.topAnchor, constant: -10).isActive = true
   
        activity.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -10).isActive = true
   
        activity.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10).isActive = true
   
        activity.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
   
        
        activity.startAnimating()
        // set image to nil
        self.image = nil
        
        // set lastImgUrlUsedToLoadImage
        lastImgUrlUsedToLoadImage = urlString
        
        // check if image exists in cache
     
            if let cachedImage = imageCache[urlString] {
                self.image = cachedImage
                self.activity.removeFromSuperview()
                self.activity.alpha = 0
                return
            }
       
        
        
        // url for image location
        guard let url = URL(string: urlString) else { return }
        
        // fetch contents of URL
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // handle error
            if let error = error {
                print("Failed to load image with error", error.localizedDescription)
            }
            
            if self.lastImgUrlUsedToLoadImage != url.absoluteString {
                return
            }
            
            // image data
            guard let imageData = data else { return }
            
            // create image using image data
            let photoImage = UIImage(data: imageData)
            
            // set key and value for image cache
            imageCache[url.absoluteString] = photoImage
            
            // set image
            DispatchQueue.main.async {
                self.image = photoImage
                self.activity.stopAnimating()
                UIView.animate(withDuration: 0.5, animations: {
                    self.activity.alpha = 0
                    self.activity.removeFromSuperview()
                })
            }
            }.resume()
    }
}
