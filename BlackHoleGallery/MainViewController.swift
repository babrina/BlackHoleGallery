import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuView: UIView!
    
    
    var galleryImagesArray: [Picture] = []
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView.cornerRadius()
        loadDefaults()
    }
    
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        
        self.performImagePicker()
    }
    
    @IBAction func galleryButton(_ sender: UIButton) {
        
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController else {return}
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func loadDefaults() {
        if let galleryImagesArray = UserDefaults.standard.value([Picture].self, forKey: "saved") {
            self.galleryImagesArray = galleryImagesArray
        }
    }
    
  
    private func performImagePicker() {
            
            self.alertThreeButton(title: "Strong Box vorrebbe accedere alle tue foto", message: "We need this so that you can share photos and videos from your photo library.", titleActionOne: "Camera", titleActionTwo: "Photo library", titleCancelAction: "Cancel", style: .actionSheet) { (_) in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
                print("Camera selected")
            } handlerActionTwo: { (_) in
                self.imagePicker.modalPresentationStyle = .overFullScreen
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
                print("Photo selected")
            } handlerCancel: { (_) in
                self.dismiss(animated: true, completion: nil)
            }
        }
    
//    private func performImagePicker() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.modalPresentationStyle = .overFullScreen
//        imagePicker.allowsEditing = true
//        imagePicker.sourceType = .photoLibrary
//
//        present(imagePicker, animated: true, completion: nil)
//    }
    
}



extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var chosenImage = UIImage()
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = image
            
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = image
        }
        
        // Save picked image
        savePickedImage(chosenImage)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func savePickedImage(_ image: UIImage) {
        
        guard let name = self.saveImage(image: image) else {return}
        let picture = Picture(name)
        let indexPath = IndexPath(item: self.galleryImagesArray.count, section: 0)
        self.galleryImagesArray.append(picture)
        UserDefaults.standard.set(encodable: galleryImagesArray, forKey: "saved")
        
        self.collectionView.insertItems(at: [indexPath])
    }
}

extension UIViewController {
    func saveImage(image: UIImage) -> String? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        
        let fileName = UUID().uuidString
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return nil}
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch let error {
            print("error saving file with error", error)
            return nil
        }
    }
    
    func loadSave(fileName:String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
            
        }
        return nil
    }
}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: galleryImagesArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let side = collectionView.frame.size.width / 2 - 0.5
        
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController else {
            return
        }
        controller.indexPicture = indexPath.item
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
}

