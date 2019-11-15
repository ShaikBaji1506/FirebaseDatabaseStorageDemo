//
//  ViewController.swift
//  FirebaseChatDemo
//
//  Created by Shaik Baji on 12/10/19.
//  Copyright © 2019 smartitventures.com. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


class oneCell:UITableViewCell
{
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    
    var chatModal:ChatModal?
    {
        didSet
        {
            name.text = chatModal?.name
            age.text = chatModal?.age
            img.sd_setImage(with: URL(string:(chatModal?.profileImageUrl)!), placeholderImage: UIImage(named: "dp.jpg"))
        }
    }
}

class ViewController: UIViewController
{
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var imageObj: UIImageView!
    @IBOutlet weak var tableObj: UITableView!
    
    var ref = DatabaseReference.init()  //Get the Database reference in which we can know where data exist to easily identify
    
    let imagePicker = UIImagePickerController()
    
    var chatArray = [ChatModal]()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.ref = Database.database().reference().child("chat") // after getting reference we will initialize our ref to child with their path name namely as room name or id
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(openGallery(tapGesture:)))
        imageObj.isUserInteractionEnabled = true
        imageObj.addGestureRecognizer(tapGesture)
        
        getAllFIRData()
        
    }
    
    @objc func openGallery(tapGesture:UITapGestureRecognizer)
    {
        setImageFromGallery()
    }

    @IBAction func saveBtnTapped(_ sender: UIButton)
    {
        self.saveFIRData()
        getAllFIRData()
    }
    @IBAction func nextBtnTapped(_ sender: UIButton)
    {
        
    }
    
    func saveFIRData()
    {
        self.uploadImage(self.imageObj.image!) { url in
            
            self.saveImage(name: self.nameTF.text!, ProfileUrl: url!){ success in
                
                if success != nil
                {
                    print("Yes image saved in firebaseStorage")
                }
                
            }
        }
    }
    
    func getAllFIRData()  // will be used for retrieving all the data which is stored in firebase database table
    {
       self.ref.queryOrderedByKey().observe(.value) { (snapshot) in
            self.chatArray.removeAll()
            if let snapShotObj = snapshot.children.allObjects as? [DataSnapshot]
            {
                for snap in snapShotObj
                {
                    if let mainDict = snap.value as? [String:AnyObject]
                    {
                        let id = mainDict["id"] as? String
                        let name = mainDict["name"] as? String
                        let age = mainDict["age"] as? String
                        let profileURL = mainDict["profileURL"] as? String
                        self.chatArray.append(ChatModal(id: id!, name: name!, profileImgURL: profileURL!, age: age!))
                        DispatchQueue.main.async {
                            self.tableObj.reloadData()
                            let indexPath = NSIndexPath(item: self.chatArray.count - 1, section: 0)
                            
                            if(self.chatArray.count > 1)
                            {
                                self.tableObj.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                            }
                         }
                     }
                }
            }
            
        }
        
    }
}


extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    
    func setImageFromGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageObj.image = image
        self.dismiss(animated:true, completion: nil)
    }
    
}

extension ViewController
{
    func uploadImage(_ image:UIImage,completion:@escaping((_ url:URL?) -> ()))
    {
        let storageRef = Storage.storage().reference().child("myimage.png")
        let imgData = imageObj.image?.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageRef.putData(imgData!, metadata:metaData) { (metaData, error) in
            
            if error == nil
            {
                print("Success")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            }
            else
            {
                print("error occured")
                completion(nil)
            }
        }
        
    }
    
    func saveImage(name:String,ProfileUrl:URL,completion:@escaping((_ url:URL?) -> ()))
    {
        let key = self.ref.childByAutoId().key
        let dict = ["id":key!,"name":nameTF.text!,"age":ageTF.text!,"profileURL":ProfileUrl.absoluteString] as [String:Any]
        self.ref.child(key!).setValue(dict)
    }
    
}


extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableObj.dequeueReusableCell(withIdentifier:"oneCell", for:indexPath) as! oneCell
        cell.chatModal = chatArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       //getting the selected artist
        let artist  = chatArray[indexPath.row]
        
        //building an alert
        let alertController = UIAlertController(title: artist.name, message: "Give new values to update ", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting artist id
            let id = artist.id
            let profileURL = artist.profileImageUrl
            
            
            //getting new values
            let name = alertController.textFields?[0].text
            let age = alertController.textFields?[1].text
            
            //calling the update method to update artist
            self.updateArtist(id: id!, name: name!, age: age!, url:profileURL!)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
            
        }
        //the delete action deleting records
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            
            self.deleteRecord(id: artist.id!)
        }
        
        //adding two textfields to alert
        alertController.addTextField { (textField) in
            textField.text = artist.name
        }
        alertController.addTextField { (textField) in
            textField.text = artist.age
        }
        
        //adding action
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        //presenting dialog
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    //MARK:- Update the row in database
    func updateArtist(id:String, name:String, age:String, url: String)
    {
        let dict = ["id":id,"name":name,"age":age,"profileURL":url]
        self.ref.child(id).setValue(dict)
     }
    
     //MARK:- Delete the row in database
    func deleteRecord(id:String)
    {
        self.ref.child(id).setValue(nil)
        
    }
}
