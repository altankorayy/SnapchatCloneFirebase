//
//  UploadVC.swift
//  SnapChatClone
//
//  Created by Altan on 25.05.2023.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uploadImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        uploadImageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func uploadClicked(_ sender: Any) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data) { metadata, error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    
                    //Fotoğrafı storage'a attıktan sonra downloadUrl yaparak url adresini firebase'e kaydedeceğiz
                    imageReference.downloadURL { url, error in
                        let imageUrl = url?.absoluteString
                        let fireStore = Firestore.firestore()
                        
                        //Şuanki kullanıcı snap attıysa whereField ile filtreleyip verileri çektik
                        fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { snapshot, error in
                            if error != nil {
                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                            } else {
                                if snapshot?.isEmpty == false && snapshot != nil {
                                    for document in snapshot!.documents {
                                        //Aynı document'lerin içine image yükleyeceğimiz için document id aldık
                                        let documentId = document.documentID
                                        
                                        //Document'ları aldık
                                        if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                            imageUrlArray.append(imageUrl!)
                                            
                                            //Aldığımız document'ları dictionary şeklinde kaydettik.
                                            let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String : Any]
                                            
                                            //En son sözlüğümüzü firebase'e ekledik.
                                            fireStore.collection("Snaps").document(documentId).setData(additionalDictionary, merge: true) { error in //Merge true yani eski veriyi silmeden üzerine ekle
                                                if error != nil {
                                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                                } else {
                                                    self.tabBarController?.selectedIndex = 0
                                                    self.uploadImageView.image = UIImage(named: "upload")
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    //Snapshot yoksa yani kullanıcı hiç snap atmamışsa
                                    let snapDictionary = ["imageUrlArray" : [imageUrl!], "snapOwner" : UserSingleton.sharedUserInfo.username,"date" : FieldValue.serverTimestamp()] as! [String : Any]
                                    fireStore.collection("Snaps").addDocument(data: snapDictionary) { error in
                                        if error != nil {
                                            self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                        } else {
                                            self.tabBarController?.selectedIndex = 0 //Snap attıktan sonra tabbarın ilk indexine dönme
                                            self.uploadImageView.image = UIImage(named: "upload")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func makeAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert,animated: true)
    }
    
}
