import UIKit

@IBDesignable
class AfterOneSecondTextField: UITextField {
    
    @IBInspectable var delayValue : Double = 1.0
    var timer:Timer?
    
    var actionClosure : (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(changedTextFieldValue), for: .editingChanged)
    }
    
    @objc func changedTextFieldValue(){
        timer?.invalidate()
        //setup timer
        timer = Timer.scheduledTimer(timeInterval: delayValue, target: self, selector: #selector(self.executeAction), userInfo: nil, repeats: false)
    }
    
    @objc func executeAction(){
        actionClosure?()
    }
    
}
