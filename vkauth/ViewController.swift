//
//  ViewController.swift
//  vkauth
//
//  Created by Mikhail Rymarev on 03.08.17.
//  Copyright © 2017 Mikhail Rymarev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //move to test
//        let user = User(id: 6936416, name: "mikhail", image: nil)
//        VK().sendMessage(to: user, text: "hello", image: UIImage(named: "camera")) { error, response in
//            if let err = error {
//                print(err)
//            }
//            if let messageId = response as? Int64 {
//                 print("delivered")
//            }
//            
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if VK.isAuthorized() {
            if let mainVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MainVC") as? MainController {
                self.present(mainVC, animated: true, completion: nil)
            }
        } else {
            if let loginVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginController {
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

