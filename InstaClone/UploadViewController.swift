//
//  UploadViewController.swift
//  InstaClone
//
//  Created by Berk Gülşen on 1.09.2023.
//

import UIKit
import PhotosUI
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func chooseImage() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1 // Bir resim seçme sınırlaması

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true, completion: nil)
    }

    @IBAction func uploadButtonClicked(_ sender: Any) {
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        
        let mediaFolder = storageReferance.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            let imageReferance = mediaFolder.child("image.jpg")
            imageReferance.putData(data,metadata: nil) { metadata, error in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                } else {
                    imageReferance.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            print(imageUrl ?? "")
                        }
                    }
                }
            }
        }
    }
}

extension UploadViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard let selectedImage = results.first?.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return  // Hata olduğunda çıkış yap
            } else if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }) else {
            print("Could not load image")
            return  // Yüklenemeyen durumda çıkış yap
        }
    }
}
