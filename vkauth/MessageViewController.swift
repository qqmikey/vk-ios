//
//  MessageViewController.swift
//  vkauth
//
//  Created by Mikhail Rymarev on 03.08.17.
//  Copyright © 2017 Mikhail Rymarev. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User? = nil

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var attachedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(sender: )))
        attachedImageView.isUserInteractionEnabled = true
        attachedImageView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleLabel.text = user?.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSendClick(_ sender: UIButton) {
        let message = messageTextView.text
        
        if let to = user {
            var image = attachedImageView.image
            if UIImage(named: "camera") == image {
                image = nil
            }
            
            if message != "" || image != nil {
                VK().sendMessage(to: to, text: message, image: image) { error, response in
                    if let err = error {
                        print(err)
                    }
                    if let messageId = response as? Int64 {
                        print("delivered \(messageId)")
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            }
            
        }
        
    }
    
    
    func imageTapped(sender: UITapGestureRecognizer)
    {
        if let imageView = sender.view as? UIImageView {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if let popoverPresentationController = alertController.popoverPresentationController {
                popoverPresentationController.sourceView = imageView
                popoverPresentationController.sourceRect = imageView.bounds
            }
            
            
            let camera = UIAlertAction(title: "Сделать фото", style: .default, handler: { (action) -> Void in
                imagePickerController.sourceType = .camera
                if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
                {
                    let popOver = UIPopoverController(contentViewController: imagePickerController)
                    popOver.present(from: imageView.bounds, in: imageView, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
                }
                else
                {
                    self.present(imagePickerController, animated: true, completion: nil)
                }
            })
            
            let library = UIAlertAction(title: "Выбрать из галереи", style: .default, handler: { (action) -> Void in
                imagePickerController.sourceType = .photoLibrary
                if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
                {
                    let popOver = UIPopoverController(contentViewController: imagePickerController)
                    popOver.present(from: imageView.bounds, in: imageView, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
                }
                else
                {
                    self.present(imagePickerController, animated: true, completion: nil)
                }
                
            })
            
            let  cancel = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
            
            alertController.addAction(camera)
            alertController.addAction(library)
            alertController.addAction(cancel)
            
            present(alertController, animated: true, completion: nil)
            
        }

    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.attachedImageView.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
