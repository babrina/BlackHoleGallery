import UIKit
import LocalAuthentication


class ViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var faceIDButton: UIButton!
    
    
    var userPincode = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeIcons()
        loginButton.isHidden = true
        mainView.addParalaxEffect()
        faceIDButton.isHidden = true
        
        loginButton.cornerRadius()
        createButton.cornerRadius()
        
        loadDefaults()
    }
    
    
    
    
    
    
    
    @IBAction func useBiometrics(sender: UIButton) {
        let context = LAContext()
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
        
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please authenticate to proceed.") { (success, error) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(controller, animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    guard let error = error else { return }
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        showInputDialog(title: "Enter your password", subtitle: "Password contains at least 6 symbols", actionTitle: "Enter", cancelTitle: "Cancel", inputPlaceholder: "Your number password", inputKeyboardType: .numberPad, cancelHandler: nil) { (input:String?) in
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
            if input == self.userPincode {
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.alert(message: "Please try again. If you foget your password — delete this app and install again", title: "Wrong password", buttonOne: "Back", style: .default)
            }
        }
        
    }
    @IBAction func createNewButtonPressed(_ sender: UIButton) {
        showInputDialog(title: "Create your password", subtitle: "Password must contain at least 6 symbols", actionTitle: "Set", cancelTitle: "Cancel", inputPlaceholder: "example: 123456", inputKeyboardType: .numberPad, cancelHandler: nil) { (input:String?) in
            
            if input!.count >= 6 {
                self.userPincode = input!
                UserDefaults.standard.set(self.userPincode, forKey: "pincode")
                
                UIView.animate(withDuration: 0.3) {
                    self.loginButton.isHidden = false
                    self.faceIDButton.isHidden = false
                    self.createButton.isHidden = true
                    self.loginButtonBottomConstraint.constant = 0
                }
            } else {
                self.alert(message: "Password must contain at least 6 symbols", buttonOne: "Ok", style: .default)
            }
        }
    }
    
    func changeIcons() {
        if !faceIDAvailable() {
            faceIDButton.setImage(UIImage(systemName: "touchid"), for: .normal)
        }
    }
    
    
    func faceIDAvailable() -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            return (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) && context.biometryType == .faceID)
        }
        return false
    }
    
    
    func loadDefaults() {
        guard let password = UserDefaults.standard.object(forKey: "pincode") as? String else {return}
        self.userPincode = password
        loginButton.isHidden = false
        faceIDButton.isHidden = false
        createButton.isHidden = true
        self.loginButtonBottomConstraint.constant = 0
    }
}


extension UIView {
    func cornerRadius(_ radius: Int = 20) {
        self.layer.cornerRadius = CGFloat(radius)
    }
    
    func dropShadow() {
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        
        layer.shadowRadius = 10
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
    }
}

extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
            
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alert(message: String, title: String = "", buttonOne: String, style: UIAlertAction.Style) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstAction = UIAlertAction(title: buttonOne, style: style)
        alertController.addAction(firstAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func alertThreeButton(title: String,
                          message: String,
                          titleActionOne: String,
                          titleActionTwo: String,
                          titleCancelAction: String,
                          style: UIAlertController.Style,
                          handlerActionOne: @escaping ((UIAlertAction) -> Void),
                          handlerActionTwo: @escaping ((UIAlertAction) -> Void),
                          handlerCancel: @escaping ((UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let actionOne = UIAlertAction(title: titleActionOne, style: .default, handler: handlerActionOne)
        let actionTwo = UIAlertAction(title: titleActionTwo, style: .default, handler: handlerActionTwo)
        let cancelAction = UIAlertAction(title: titleCancelAction, style: .cancel, handler: handlerCancel)
        
        alert.addAction(actionOne)
        alert.addAction(actionTwo)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension UIView {
    func addParalaxEffect(amount: Int = 20) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        addMotionEffect(group)
    }
}
