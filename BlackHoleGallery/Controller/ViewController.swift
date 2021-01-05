import UIKit
import LocalAuthentication
import SwiftyKeychainKit

class ViewController: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var faceIDButton: UIButton!
    
    //MARK: - VAR/LET
        var userPincode = ""
    let keychain = Keychain(service: "com.swifty.keychain")
    let accessTokenKey = KeychainKey<String>(key: "accessToken")
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpController()
    }
    //MARK: - Actions
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
        showInputDialog(title: "Enter your password", subtitle: "Password contains at least 6 symbols", actionTitle: "Enter", cancelTitle: "Cancel", inputPlaceholder: "Your number password", style: .default, secure: true, inputKeyboardType: .numberPad, cancelHandler: nil) { (input:String?) in
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
            if input == self.userPincode {
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.alert(message: "Please try again. If you foget your password — delete this app and install again", title: "Wrong password", buttonOne: "Back", style: .default)
            }
        }
    }
    
    @IBAction func createNewButtonPressed(_ sender: UIButton) {
        showInputDialog(title: "Create your password", subtitle: "Password must contain at least 6 symbols", actionTitle: "Set", cancelTitle: "Cancel", inputPlaceholder: "example: 123456", style: .default, secure: true, inputKeyboardType: .numberPad, cancelHandler: nil) { (input:String?) in
            guard let text = input else { return }
            if text.count >= 6 {
                self.userPincode = text
                try? self.keychain.set("\(self.userPincode)", for : self.accessTokenKey)
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
    
    func setUpController() {
        changeIcons()
        loginButton.isHidden = true
        mainView.addParalaxEffect()
        faceIDButton.isHidden = true
        loginButton.cornerRadius()
        createButton.cornerRadius()
        loadDefaults()
    }
    
    func changeIcons() {
        if !LoginManager.shared.faceIDAvailable() {
            faceIDButton.setImage(UIImage(systemName: "touchid"), for: .normal)
        }
    }
    
    func loadDefaults() {
        guard let value = try? keychain.get(accessTokenKey) else { return }
        userPincode = value
        if value != "nil" {
            createButton.isHidden = true
            loginButton.isHidden = false
            faceIDButton.isHidden = false
        } else {
            createButton.isHidden = false
            loginButton.isHidden = true
            faceIDButton.isHidden = true
        }
    }
}
