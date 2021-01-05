import Foundation
import UIKit

extension UserDefaults {
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
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
                         style: UIAlertAction.Style,
                         secure: Bool,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
            textField.isSecureTextEntry = secure
            let actionOne = UIAlertAction(title: actionTitle, style: style, handler: { (action:UIAlertAction) in
                guard let textField = alert.textFields?.first else {
                    actionHandler?(nil)
                    return
                }
                actionHandler?(textField.text)
            })
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: {_ in                                            let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount >= 6
                actionOne.isEnabled = textIsNotEmpty
})
            alert.addAction(actionOne)
            actionOne.isEnabled = false
            
        }
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

extension UIViewController {
    func saveImage(image: UIImage) -> String? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        let fileName = UUID().uuidString
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return nil}
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

extension Notification.Name {
    static let buttonPressed = Notification.Name("buttonPressed")
    static let deletePressed = Notification.Name("deletePressed")
}

extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var chosenImage = UIImage()
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = image
        }
        savePickedImage(chosenImage)
        picker.dismiss(animated: true, completion: nil)
    }
    func savePickedImage(_ image: UIImage) {
        guard let name = self.saveImage(image: image) else { return }
        let picture = Picture(name)
        let indexPath = IndexPath(item: self.galleryImagesArray.count, section: 0)
        self.galleryImagesArray.append(picture)
        UserDefaults.standard.set(encodable: galleryImagesArray, forKey: "saved")
        self.collectionView.insertItems(at: [indexPath])
        checkCount()
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

extension GalleryViewController: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ commentField: UITextField) -> Bool {
        commentField.resignFirstResponder()
    }
}

extension UIImageView {
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
    }
    
    @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
