import UIKit
protocol DragViewState {
    func dragViewState(state: String)
    func didBeginDragging()
    func didEndDragging()
}
class DragView : UIView {
    var delegate : DragViewState?
    var dragState = 0
    var state = "bottom"
 var bar = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        bar.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        bar.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 6).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        bar.backgroundColor = .systemGray3
        bar.layer.cornerRadius = 2.5
        self.backgroundColor = .init(rbg: 30, green: 30, blue: 30, alpha: 1)
        lastPointY = UIScreen.main.bounds.height - 100
        let panGest = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        self.gestureRecognizers = [
        panGest
        ]
         
        self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 40, width: 0, height: 0)
        self.layer.cornerRadius = 10
        

    }
    var lastPointY : CGFloat = 0
    var translationY = CGFloat()
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        print(translation.y)
        print("Frame Y \(self.frame.origin.y)")
      print( "\(self.frame.origin.y + translation.y)" )
        print(state)
        //MARK: - Top
        delegate?.didBeginDragging()
        if self.frame.origin.y <  0 + UIScreen.main.bounds.height / 4  && self.frame.origin.y > 0 + UIScreen.main.bounds.height / 8 {
            print("Top Point")
            state = "top"
            delegate?.dragViewState(state: state)
        } else {
            print("Not Top Point")
        }
        //MARK: - Mid
       
        if self.frame.origin.y <  UIScreen.main.bounds.height - UIScreen.main.bounds.height / 8  && self.frame.origin.y > 0 + UIScreen.main.bounds.height / 2 {
            print("Mid Point")
            state = "middle"
            delegate?.dragViewState(state: state)
        } else {
            print("Not Mid Point")
        }
        //MARK: - Bottom
       
        if self.frame.origin.y <  UIScreen.main.bounds.height  && self.frame.origin.y > UIScreen.main.bounds.height - UIScreen.main.bounds.height / 3 {
            print("Bottom Point")
            state = "bottom"
            delegate?.dragViewState(state: state)
        } else {
            print("Not Bottom Point")
        }
       
         
        
    
        if sender.state == .changed {
          
            self.transform = .init(translationX: 0, y: translation.y  + lastPointY + (-UIScreen.main.bounds.height + 100) )
            delegate?.dragViewState(state: state)
        }
        if sender.state == .began {
     
        }
        if sender.state == .ended {
           
          
        
            if state == "top" {
                UIView.animate(withDuration: 0.5, animations: {
                    
//
                self.transform = .init(translationX: 0, y:     (-UIScreen.main.bounds.height + 100) + UIScreen.main.bounds.height / 8)
                }, completion: nil)
            } else if state == "middle" {
                UIView.animate(withDuration: 0.5, animations: {
//
                self.transform = .init(translationX: 0, y:      (-UIScreen.main.bounds.height + 100) + UIScreen.main.bounds.height / 2)
            
            
                
                }, completion: nil)
            } else if state == "bottom" {
                UIView.animate(withDuration: 0.5, animations: {
                    self.transform = .identity
                }, completion: nil)
                self.delegate?.didEndDragging()
            }
       
            lastPointY = self.frame.origin.y
            print(lastPointY)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
