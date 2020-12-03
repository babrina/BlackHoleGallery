import UIKit

class GalleryViewController: UIViewController {
    @IBOutlet weak var viewButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextField!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var bottomMenu: UIView!
    
    //MARK: - VAR
    var photoAlbum: [Picture] = []
    let photoAlbumKey = "saved"
    var indexPicture = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomMenu.cornerRadius()
        imageView.cornerRadius()
        bottomMenu.dropShadow()
        // Load photoalbum custom class
        self.loadPhotoAlbum()
        
        // TAP Recognizer
        let removeKeyBoard = UITapGestureRecognizer(target: self, action: #selector(tapRecognized(_:)))
        
        // Check if stop writing text
        commentTextView.addTarget(self, action: #selector(GalleryViewController.textFieldDidChange(_:)), for: .editingChanged)
        // Keyboard notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(processNotification), name: Notification.Name.buttonPressed, object: nil)
        registerForKeyboardNotifications()
        //
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupPicture()
        imageView.dropShadow()

    }
    
    
    
    @IBAction func processNotification() {
        //        self.label.text = "Notification recieved"
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        downIndexPicture()
        setupPicture()
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        upIndexPicture()
        setupPicture()
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let comment = commentTextView.text else {return}
        photoAlbum[self.indexPicture].comment = comment
    }
    
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set(encodable: photoAlbum, forKey: photoAlbumKey)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected == true {
            photoAlbum[indexPicture].like = 1
        } else {
            photoAlbum[indexPicture].like = 0
        }
    }
    

    //MARK: - Func
    func setupPicture() {
        loadPicture()
        loadComment()
        loadLike()
    }
    
    func loadLike() {
        if photoAlbum[indexPicture].like == 1 {
            likeButton.isSelected = true
        } else {
            likeButton.isSelected = false
            
        }
    }
    
    func loadComment() {
        if let comment = photoAlbum[indexPicture].comment as? String {
            commentTextView.text = comment
        }
    }
    
    
    func loadPicture() {
        if let image = self.loadSave(fileName: self.photoAlbum[self.indexPicture].name) {
            imageView.image = image
        }
        
    }
    
    func loadPhotoAlbum() {
        if let photoAlbum = UserDefaults.standard.value([Picture].self, forKey: photoAlbumKey) {
            self.photoAlbum = photoAlbum
        }
    }
    
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            print("Keyboard dismissed")
            viewButtomConstraint.constant = 0
        } else {
            viewButtomConstraint.constant = keyboardScreenEndFrame.height
            print("Keyboard shown")
            
        }
        
        view.needsUpdateConstraints()
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func upIndexPicture() {
        if self.indexPicture == self.photoAlbum.count - 1 {
            self.indexPicture = 0
        } else {
            self.indexPicture += 1
        }
    }
    
    func downIndexPicture() {
        if self.indexPicture == 0 {
            self.indexPicture = self.photoAlbum.count - 1
        } else {
            self.indexPicture -= 1
        }
    }
}




//MARK: - Extensions
extension GalleryViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ commentField: UITextField) -> Bool {
        commentField.resignFirstResponder()
        
    }
}

extension Notification.Name {
    static let buttonPressed = Notification.Name("buttonPressed")
}
