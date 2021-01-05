import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var galleryButtonImage: UIButton!
    
    var galleryImagesArray: [Picture] = []
    var indexPicture = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView.cornerRadius()
        loadDefaults()
        checkCount()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollection), name: Notification.Name.deletePressed, object: nil)
    }
    
    @IBAction func updateCollection() {
        if let galleryImagesArray = UserDefaults.standard.value([Picture].self, forKey: "saved") {
            self.galleryImagesArray = galleryImagesArray
        }
        if let indexpath = UserDefaults.standard.object(forKey: "index") as? Int {
            self.indexPicture = indexpath
        }
        Timer.scheduledTimer(withTimeInterval: TimeInterval(0.2), repeats: false) { (_) in
            UIView.animate(withDuration: 0.3) {
                self.collectionView.deleteItems(at: [IndexPath(row: self.indexPicture, section: 0)])
                self.collectionView.reloadData()
            }
        }
        checkCount()
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        self.performImagePicker()
    }
    
    @IBAction func galleryButton(_ sender: UIButton) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController else {return}
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func checkCount(){
        if galleryImagesArray.count >= 1 {
            galleryButtonImage.isUserInteractionEnabled = true
        } else {
            galleryButtonImage.isUserInteractionEnabled = false
        }
    }
    
    func loadDefaults() {
        if let galleryImagesArray = UserDefaults.standard.value([Picture].self, forKey: "saved") {
            self.galleryImagesArray = galleryImagesArray
        }
    }
    
    private func performImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.alertThreeButton(title: "Add photos to secured storage", message: "You can add bank cards, secret photos", titleActionOne: "Camera", titleActionTwo: "Photo library", titleCancelAction: "Cancel", style: .actionSheet) { (_) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
            print("Camera selected")
        } handlerActionTwo: { (_) in
            imagePicker.modalPresentationStyle = .overFullScreen
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            print("Photo selected")
        } handlerCancel: { (_) in
            self.dismiss(animated: true, completion: nil)
        }
    }
}
